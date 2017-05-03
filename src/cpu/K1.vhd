library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- K1 interface
entity K1 is
  port (
    operand : in unsigned(3 downto 0);
    K1_adress : out unsigned(7 downto 0));
end K1;

architecture Behavioral of K1 is

-- K1 Memory
type K1_mem_t is array (0 to 15) of unsigned(7 downto 0);
constant K1_mem_c : K1_mem_t :=
  (x"03",                               --:00 LOAD
   x"05",                               --:01 HALT
   x"07",                               --:02 STORE
   x"09",                               --:03 ADD
   x"0D",                               --:04 SUB
   x"11",                               --:05 AND
   x"15",                               --:06 BRA
   x"17",                               --:07 CMP
   x"1A",                               --:08 BNE
   x"1E",                               --:09 BGE
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00");

signal K1_sig : K1_mem_t := K1_mem_c;

begin -- behavioral

  K1_adress <= K1_sig(to_integer(operand));

end Behavioral;
