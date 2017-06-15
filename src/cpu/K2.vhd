library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- K2 interface
entity K2 is
  port (
    modd : in unsigned(3 downto 0);
    K2_adress : out unsigned(7 downto 0));
end K2;

architecture Behavioral of K2 is

-- K2 Memory
type K2_mem_t is array (0 to 3) of unsigned(7 downto 0);
constant K2_mem_c : K2_mem_t :=
  (x"2B",                               --:0 Direct
   x"2C",                               --:1 Indirect
   x"2E",                               --:2 immediate
   x"4A"                               --:3 Inception
   );

signal K2_sig : K2_mem_t := K2_mem_c;

begin -- behavioral

  K2_adress <= K2_sig(to_integer(modd));

end Behavioral;
