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
  (x"03",                               --:0 LOAD
   x"05",                               --:1 HALT
   x"07",                               --:2 STORE
   x"09",                               --:3 ADD
   x"0D",                               --:4 SUB
   x"33",                               --:5 BRA_PLUS
  -- x"11",                               --:5 AND
   x"15",                               --:6 BRA
   x"17",                               --:7 CMP
   x"1A",                               --:8 BEQ
   x"1E",                               --:9 BGE
   x"24",                               --:A MULU      
   x"30",                               --:B TRA
   x"3D",                               --:C BNE
   x"40",                               --:D BL
   x"45",                               --:E BEEP
   x"37"                                --:F BRA_MINUS
   );

signal K1_sig : K1_mem_t := K1_mem_c;

begin -- behavioral

  K1_adress <= K1_sig(to_integer(operand));

end Behavioral;
