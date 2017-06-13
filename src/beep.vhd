
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity beep is
  port(clk  : in std_logic;
       bang : out std_logic;
       beep_en : in std_logic
    );
end beep;

architecture Behavior of beep is
signal counter_r        : integer range 0 to 5000000;
signal clk_1kHz         : std_logic;
signal khz_counter      : integer range 0 to 999;
signal bang_q           : std_logic;
signal beep_counter     : integer range 0 to 600;
signal beep_timer_en    :std_logic := '0';

                                   
begin  -- Behavioral of beep is

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



process(clk_1kHz) begin
  if rising_edge(beep_en) then
    beep_timer_en <= not(beep_timer_en);
  end if;
  
  if rising_edge(clk_1khz)then
   if beep_timer_en = '1' then
    if (beep_counter = 600) then
      beep_counter <= 0;
      beep_timer_en <= '0';
    else
      beep_counter <= beep_counter + 1;
      bang_q <= not(bang_q);
    end if;
  end if;
end if;
end process;
bang <= bang_q;
end Behavior;
