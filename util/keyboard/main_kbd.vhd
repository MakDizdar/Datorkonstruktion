-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Main test file of keyboard and LED
entity main_kbd is
  
  PORT( clk                     : in STD_LOGIC;
        rst                     : in STD_LOGIC;
        PS2KeyboardCLK          : in STD_LOGIC;
        PS2KeyboardData         : in STD_LOGIC;

        an                      : out STD_LOGIC_VECTOR(3 downto 0);
        seg                     : out STD_LOGIC_VECTOR(7 downto 0));
end main_kbd;

architecture Behavioral of main_kbd is
component sevensegment
  port(clk      : in STD_LOGIC;
       rst      : in STD_LOGIC;
       data     : out STD_LOGIC_VECTOR(7 downto 0);
       seg      : out STD_LOGIC_VECTOR(7 downto 0);
       an       : out STD_LOGIC_VECTOR(3 downto 0));
end component;

component KBD_ENC
    port ( clk		        : in std_logic;				-- system clock
	   rst		        : in std_logic;				-- reset signal
	   PS2KeyboardCLK       : in std_logic;				-- PS2 clock
	   PS2KeyboardData      : in std_logic;				-- PS2 data
	   data		        : out std_logic_vector(7 downto 0);	-- tile data
	   we			: out std_logic);	                -- write enable
  end component;
  
-- intermediate signals between KBD_ENC and sevensegment
  signal        data_s	        : std_logic_vector(7 downto 0);         -- data
  signal	we_s		: std_logic;                            -- write enable
  
begin  -- Behavioral
-- keyboard encoder component connection
U0 : KBD_ENC port map(clk=>clk, rst=>rst, PS2KeyboardCLK=>PS2KeyboardCLK, PS2KeyboardData=>PS2KeyboardData, data=>data_s, we=>we_s);
-- LED seven segment digits
U1 : sevensegment port map(clk=>clk, rst=>rst, an=>an, seg=>seg, data=>data_s);
  

end Behavioral;
