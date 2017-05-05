library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- pMem interface
entity pMem is
  port(
    pAddr : in unsigned(31 downto 0);
    pData : out unsigned(31 downto 0));
end pMem;

architecture Behavioral of pMem is

-- program Memory
type p_mem_t is array (0 to 500) of unsigned(31 downto 0);
constant p_mem_c : p_mem_t :=
  (x"00000002",                         --load 10 in gr0
   x"00000000",                         -- subtract 4 from gr0
   x"00000001",                         --add 3 to gr1
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   others => (others => '0'));

  signal p_mem : p_mem_t := p_mem_c;


begin  -- pMem
  pData <= p_mem(to_integer(pAddr));

end Behavioral;
