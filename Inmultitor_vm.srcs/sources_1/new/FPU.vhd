
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FPU is
Port     ( a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           overf, underf: out std_logic;
           r : out STD_LOGIC_VECTOR (31 downto 0));
end FPU;

architecture Behavioral of FPU is

component FPMultiplicator is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           y : in STD_LOGIC_VECTOR (31 downto 0);
          underflow,overflow: out std_logic;
           rez : out STD_LOGIC_VECTOR (31 downto 0));
end component FPMultiplicator;

signal mul_result: std_logic_vector(31 downto 0) := (others => '0');
signal  overflow, underflow: std_logic := '0';

begin

fpu_multiplication: FPMultiplicator PORT MAP(
x => a,
y => b,
overflow => overflow,
underflow => underflow,
rez => mul_result
);


process(mul_result)
begin


    r <= mul_result;
    overf <= overflow;
    underf <= underflow;

end process;



end Behavioral;
