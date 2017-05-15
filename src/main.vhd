library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity main is
  port( clk	                : in 	std_logic;      -- system clock
	 rst                    : in 	std_logic;      -- reset
	 Hsync	                : out 	std_logic;      -- horizontal sync
	 Vsync	                : out 	std_logic;      -- vertical sync
	 vgaRed	                : out 	std_logic;   	-- VGA red
	 vgaGreen               : out 	std_logic;     	-- VGA green
	 vgaBlue	        : out 	std_logic);     -- VGA blue

end main;

architecture Behavioral of main is

component graphic is
  port(clk	              : in 	std_logic;      -- system clock
       rst                    : in 	std_logic;      -- reset
	 Hsync	              : out 	std_logic;      -- horizontal sync
	 Vsync	              : out 	std_logic;      -- vertical sync
	 vgaRed	              : out 	std_logic;   	-- VGA red
	 vgaGreen             : out 	std_logic;     	-- VGA green
	 vgaBlue	      : out 	std_logic);     -- VGA blue 
end component;

component proj is
  port(clk      : in std_logic;
       rst      : in std_logic);
end component;
begin  -- Behavioral of main is

U1: proj port map(clk=>clk, rst=>rst);
U2: graphic port map(clk=>clk,rst=>rst,Hsync=>Hsync,Vsync=>Vsync,vgaRed=>vgaRed,vgaGreen=>vgaGreen,vgaBlue=>vgaBlue); 
  

end Behavioral;
