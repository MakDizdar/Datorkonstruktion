--####################### CLK_1khz #############################################
--The system clock is too fast for the multiplexing of the 7segment displays
--We generate a 1 khz clock with the freq divider process, one period for such
--a clock lasts f_main_clk / wanted_clk periods. Thus a positive edge  for slow
--clock is generated every (100*e6 / e3) / 2 = 50e3 period. In other words
--A 1khz period last for 100e3 mhz periods.
--##############################################################################
--
--
--###################### Seven Segment on the nexys 3 ##########################
--                             +---------------- +
--                             |  \     A     /  |
--                             |   +---------+   |
--                             |   |         |   |
--                             |F  |         |B  |
--                             |   |         |   |
--                             |   +---------+   |
--                             |  /           \  |
--                             +--      G      --+
--                             |  \           /  |
--                             |   +---------+   |
--                             |   |         |   |
--                             | E |         | C |
--                             |   |         |   |
--                             |   +-- ------+   |
--                             |  /    D      \  |
--                             +-----------------+
--The an signal is a 4-bit vector which stands for anode. The an signal
--decides what digit will be enabled.You enable with a logic zero,
--the left most 7seg is enabled by letting anode be "0111".
--Enabling all four is done with an <= "0000". Keep in mind they
--that they all share the same segments that's why multiplexing
--is needed.
--See the UCF-file for PIN names.
--
--The seg signal for the nexys3 spartan6 is a 8-bit vector where logic zeroes
--enables the segments. The most significant bit stand for decimal point. In
--that following order A stands for segment A and so on where the least
--significant bit stands for segment G. See the UCF-file for PIN details.
--###################################################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sevensegment is
  PORT(clk      : in STD_LOGIC;
       rst      : in STD_LOGIC;
       data     : in STD_LOGIC_VECTOR(7 downto 0);
       seg      : out STD_LOGIC_VECTOR(7 downto 0);
       an       : out STD_LOGIC_VECTOR(3 downto 0));
end sevensegment;

architecture Behavioral of sevensegment is

signal counter_r : integer range 0 to 5000000;
signal clk_1kHz : std_logic;
signal counter : unsigned(1 downto 0) := "00";
signal segments : std_logic_vector(6 downto 0):= "0000000";

signal key : std_logic_vector(6 downto 0) := "0001111";  --The seg value for key pressed

begin  -- Behavioral
--Combinatorial processes
seg <= ('1' & segments);                --logic 1 to disable decimal point


with data select
  key <=
        "0111000" when x"00",   --Space pressed, F out
        "0000001" when x"01",   --A pressed, 0 out
        "1001111" when x"02",   -- B pressed, 1 out
        "0010010" when x"03",   -- C pressed, 2 out
        "0000110" when x"04",   -- D, 3 out
        "1001100" when x"05",   -- E, 4 out
        "0100100" when x"06",   -- F, 5 out
        "0100000" when x"07",   -- G, 6 out
        "0001111" when x"08",   -- H, 7 out
        "0000000" when x"09",   -- I, 8 out
        "0000100" when x"0A",    -- J, 9 out                       
        "0111000" when others;
  
       
--Synchronized processes
freq_divider:process(clk) begin         --Divides the 100 mhz sys_clk to 1000hz
  if rising_edge(clk) then
    if (counter_r = 50000) then
      clk_1khz <= not(clk_1khz);
      counter_r <= 0;
    else
      counter_r <= counter_r + 1;
    end if;
  end if;
end process;

process(clk) begin
 if rising_edge(clk) then
  if rising_edge(clk_1khz) then
    counter <= counter + 1;
  end if;
  case counter is
    when "00" => an <= "1110"; segments <= key;
    when "01" => an <= "1101"; segments <= "0000011";
    when "10" => an <= "1011"; segments <= "0000111";
    when others => an <= "0111";segments <="0001111";
  end case;
 end if;
end process;




end Behavioral;
