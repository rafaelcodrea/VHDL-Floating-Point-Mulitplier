
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FPMultiplicator is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           y : in STD_LOGIC_VECTOR (31 downto 0);
           underflow,overflow: out std_logic;
           rez : out STD_LOGIC_VECTOR (31 downto 0));
end FPMultiplicator;

architecture Behavioral of FPMultiplicator is


signal sign_x : std_logic; --semn op 1
signal sign_y : std_logic; --semn op 2

signal exponent_x : std_logic_vector( 7 downto 0);  --exponent op1
signal exponent_y : std_logic_vector(7 downto 0);  --exponent op2

signal mantissa_x: std_logic_vector(24 downto 0); --mantissa op1
signal mantissa_y : std_logic_vector(24 downto 0); --mantisa op2
signal bias_neg : std_logic_vector(7 downto 0) := "10000001";   -- (-127)
signal bias : std_logic_vector(7 downto 0) := "01111111";       -- (127)

signal mantissaProduct : std_logic_vector(47 downto 0); --mantise

signal unbiasedExponent_x : std_logic_vector(7 downto 0);
signal unbiasedExponent_y : std_logic_vector(7 downto 0); 
signal unbiasedExponent : std_logic_vector(7 downto 0);
-- exponent ne normalizat
signal exponent_temp : std_logic_vector(7 downto 0); --pt calcul
signal normalized : std_logic_vector(7 downto 0); 


signal rez_sign: std_logic;  --semn final
signal rez_exponent : std_logic_vector(7 downto 0); --exponent final
signal rez_mantissa : std_logic_vector( 22 downto 0); --mantissa final

--componenta pentru inmultirea mantissei operanzilor
component multiplierComponent is
    Port ( x : in STD_LOGIC_VECTOR (24 downto 0);
           y : in STD_LOGIC_VECTOR (24 downto 0);
           rez : out STD_LOGIC_VECTOR (47 downto 0));
end component;

---componenta pentru adunarea exponentilor operanzilor
component adderComponent is
    Port ( x : in STD_LOGIC_VECTOR (7 downto 0);
           y : in STD_LOGIC_VECTOR (7 downto 0);
           Cout : out std_logic;
           s : out STD_LOGIC_VECTOR (7 downto 0));
end component;

signal Cout_1, Cout_2 : std_logic := '0';

begin

--extract components
sign_x <= x(31);
sign_y <= y(31);

exponent_x <= x(30 downto 23);
exponent_y <= y(30 downto 23);

mantissa_x <= "01" & x(22 downto 0);
mantissa_y <= "01" & y(22 downto 0);

mul_component: multiplierComponent PORT MAP ( x =>  mantissa_x, y => mantissa_y, rez => mantissaProduct);


normalization_check: process(mantissaProduct)
begin
    if mantissaProduct(47) = '1' then  
        --normalizam mantisa        
        rez_mantissa <= mantissaProduct(46 downto 24);
    else
        -- nu e nevoie de normalizare
        rez_mantissa <= mantissaProduct(45 downto 23);
    end if;
end process;

-- normalizam in functie de primul bit al mantisei
normalized <= "0000000" &  mantissaProduct(47);

--exponentii:


--exponent1 - bias:
reduce_bias1: adderComponent PORT MAP( x => exponent_x, y => bias_neg, s => unbiasedExponent_x);     

--exponent2 - bias
reduce_bias2: adderComponent PORT MAP( x => exponent_y, y => bias_neg, s => unbiasedExponent_y);

-- exponent1 + exponent2    
add_exp: adderComponent PORT MAP( x => unbiasedExponent_x, y => unbiasedExponent_y, s => unbiasedExponent); 

--suma exponentilor + bias
add_bias: adderComponent PORT MAP(x => unbiasedExponent, y => bias, cout => Cout_1, s => exponent_temp);

-- normalize final exponent
--normalizare finala
add_normalization : adderComponent PORT MAP (x => exponent_temp, y => normalized, cout => Cout_2, s => rez_exponent);

--semnul rezultatului:
rez_sign <= sign_x xor sign_y;




--cazuri particulare:
specialCases: process(rez_sign, rez_exponent, rez_mantissa)
begin

-- x*0=0
if x = "00000000000000000000000000000000" or y = "00000000000000000000000000000000" then rez <= "00000000000000000000000000000000";

---0 * x= 0
elsif x = "10000000000000000000000000000000" or y = "10000000000000000000000000000000" then rez <= "10000000000000000000000000000000";

-- +infinit ori 
elsif x = "01111111100000000000000000000000" then
    -- +infinit
    if x = "01111111100000000000000000000000" and y = "01111111100000000000000000000000" then
    --da NAN
    rez <= "01111111110000000000000000000000";
    -- +infinit * NAN = NAN
    elsif x = "01111111100000000000000000000000" and y = "01111111110000000000000000000000" then rez <= "01111111110000000000000000000000";
    else
    -- +infinit * x = +infinit
    rez <= "01111111100000000000000000000000";
    end if;

-- -infinit ori
elsif x = "11111111100000000000000000000000" then
    -- -infinit * -infinit = NAN
    if x = "11111111100000000000000000000000" and y = "11111111100000000000000000000000" then
    rez <= "01111111110000000000000000000000";
    --  -infint * NAN = NAN
    elsif x = "11111111100000000000000000000000" and y = "01111111110000000000000000000000" then
    rez <= "01111111110000000000000000000000";
    else
    -- -infint * x = -infit
    rez <= "11111111100000000000000000000000";
    end if;


-- NAN * x = NAN
elsif x = "01111111110000000000000000000000" or y = "01111111110000000000000000000000" then rez <= "01111111110000000000000000000000";

else 
 rez <= rez_sign & rez_exponent & rez_mantissa; --nu avm exceptie
end if;
end process;

-- handle overflow and underflow problems
handle_cases: process(exponent_temp, rez_exponent, Cout_1, Cout_2, rez_sign, rez_mantissa)
begin
    if (x /= "01111111110000000000000000000000" and y /= "01111111110000000000000000000000") and (x /= "01111111100000000000000000000000" and y /= "01111111100000000000000000000000") and (x /= "11111111100000000000000000000000" and y /= "11111111100000000000000000000000") and ( x /= "00000000000000000000000000000000" and y /= "00000000000000000000000000000000") and ( x /= "10000000000000000000000000000000" and y /= "10000000000000000000000000000000") and (Cout_1 = '1' or Cout_2 = '1') then
        if rez_exponent(7) = '0'  then
            overflow <= '1';   
            underflow <= '0'; 
          
              
       else
            overflow <= '0';    
            underflow <= '1';  
        end if;
    else
        overflow <= '0';
        underflow <= '0';
    end if;
end process;

end Behavioral;
