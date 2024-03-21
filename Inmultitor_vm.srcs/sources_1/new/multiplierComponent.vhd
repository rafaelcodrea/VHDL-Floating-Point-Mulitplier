library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity multiplierComponent is
    Port ( x : in STD_LOGIC_VECTOR (24 downto 0);
           y : in STD_LOGIC_VECTOR (24 downto 0);
           rez : out STD_LOGIC_VECTOR (47 downto 0));
end multiplierComponent;

architecture Behavioral of multiplierComponent is

begin

 process(x, y)
            variable acc: std_logic_vector(50 downto 0); --acc = A & Q & Q-1
            variable s,temp : std_logic_vector(24 downto 0); 
               begin
               
                   acc := (others => '0');
                   s := y; --M
                   acc(25 downto 1) := x; --A

                   for i in 0 to 24 loop 
                      if(acc(1) = '1' and acc(0) = '0') then 

                         temp := (acc(50 downto 26));
                         acc(50 downto 26) := (temp - s);
                         
                      elsif(acc(1) = '0' and acc(0) = '1') then
                         
                         temp := (acc(50 downto 26));
                         
                         acc(50 downto 26) := (temp + s);
                      end if;
                      
                      acc(49 downto 0) := acc(50 downto 1);
                   end loop;
                   
                   rez <= acc(48 downto 1);--ultima shiftare
               end process;
end Behavioral;
