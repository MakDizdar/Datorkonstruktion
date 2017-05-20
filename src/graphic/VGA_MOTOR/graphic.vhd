-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations

-- entity
entity graphic is
  port ( clk	                : in 	std_logic;                         -- system clock
	 rst                    : in 	std_logic;                         -- reset
         tile                   : in    unsigned(3 downto 0);
         index                  : in    unsigned(15 downto 0); 
	 Hsync	                : out 	std_logic;                        -- horizontal sync
	 Vsync	                : out 	std_logic;                        -- vertical sync
	 vgaRed	                : out 	std_logic;   	                  -- VGA red
	 vgaGreen               : out 	std_logic;     	                  -- VGA green
	 vgaBlue	        : out 	std_logic);                       -- VGA blue
end graphic;


-- architecture
architecture Behavioral of graphic is

  -- picture memory component
  component PICT_MEM
    port ( clk			: in std_logic;                         -- system clock
	   blank                : in std_logic;
           index                : in unsigned(15 downto 0);
           tile                 : in unsigned(3 downto 0); 
           addr2		: in unsigned(12 downto 0);            -- address
           data_out2		: out std_logic_vector(3 downto 0));	-- data

  end component;
	
  -- VGA motor component
  component VGA_MOTOR
    port ( clk			: in std_logic;                         -- system clock
           rst			: in std_logic;                         -- reset
           data			: in std_logic_vector(3 downto 0);      -- data
 	   addr			: out unsigned(12 downto 0);		-- addr
           vgaRed		: out std_logic;     			-- VGA red
           vgaGreen	        : out std_logic;     			-- VGA green
           vgaBlue		: out std_logic;     			-- VGA blue
           Hsync		: out std_logic;                        -- horizontal sync
           Vsync		: out std_logic;
           blank_out            : out std_logic);                      
	   
  end component;
	
  -- intermediate signals between PICT_MEM and VGA_MOTOR
  signal	addr2_s		: unsigned(12 downto 0);                -- address
  signal	data_out2_s	: std_logic_vector(3 downto 0);		-- data
  signal        blank_s         : std_logic;

	
begin

  -- picture memory component connection
  U1 : PICT_MEM port map(clk=>clk, data_out2=>data_out2_s, addr2=>addr2_s, blank=>blank_s,tile=>tile,index=>index);
	
  -- VGA motor component connection
  U2 : VGA_MOTOR port map(clk=>clk, rst=>rst, data=>data_out2_s,addr=>addr2_s, vgaRed=>vgaRed, vgaGreen=>vgaGreen, vgaBlue=>vgaBlue, Hsync=>Hsync, Vsync=>Vsync, blank_out=>blank_s);

end Behavioral;

