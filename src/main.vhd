library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity main is
  port( clk	                        : in 	std_logic;      -- system clock
	 rst                            : in 	std_logic;      -- reset
	 Hsync	                        : out 	std_logic;      -- horizontal sync
	 Vsync	                        : out 	std_logic;      -- Vertical sync
	 vgaRed	                        : out 	std_logic;   	-- VGA red
	 vgaGreen                       : out 	std_logic;     	-- VGA green
	 vgaBlue	                : out 	std_logic;     --  VGA blue

         an                             : out std_logic_vector(3 downto 0);  	--Anode 7seg                                                                   
         seg                            : out std_logic_vector(7 downto 0);  	--Segments
         PS2KeyboardCLK                 : in STD_LOGIC;  			--keyboardclk
         PS2KeyboardData                : in STD_LOGIC;  			--keyboardkey
         bang                           : out std_logic);
  
end main;

architecture Behavioral of main is

component graphic is
  port(clk	              : in 	std_logic;      -- system clock
       rst                    : in 	std_logic;      -- reset
       tile                   : in      unsigned(3 downto 0);
       index                  : in      unsigned(15 downto 0);
       Hsync	              : out 	std_logic;      -- horizontal sync
       Vsync	              : out 	std_logic;      -- vertical sync
       vgaRed	              : out 	std_logic;   	-- VGA red
       vgaGreen               : out 	std_logic;     	-- VGA green
       vgaBlue	              : out 	std_logic);     -- VGA blue 
end component;

component proj is
  port(clk      : in std_logic;
       rst      : in std_logic;
       key      : in unsigned(7 downto 0);
       
       score    : out unsigned(15 downto 0);
       beep_en  : out std_logic;
       tile     : out unsigned(3 downto 0);
       index    : out unsigned(15 downto 0));
end component;

component sevensegment
  port(clk      : in STD_LOGIC;
       rst      : in STD_LOGIC;
       data     : in unsigned(15 downto 0);
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

component beep
  port(clk      : in std_logic;
       bang     : out std_logic;
       beep_en: in std_logic
       );
end component;



--intermediate signal
signal tile_s : unsigned(3 downto 0);
signal index_s : unsigned(15 downto 0);

signal data_s : std_logic_vector(7 downto 0);
signal key : unsigned(7 downto 0);

signal we_s  : std_logic;
signal beep_en_s : std_logic;

signal score_s : unsigned(15 downto 0);

begin  -- Behavioral of main is

key <= unsigned(data_s);

U1: proj port map(clk=>clk, rst=>rst, tile=>tile_s, index=>index_s, beep_en=>beep_en_s, key=>key, score=>score_s);
U2: graphic port map(clk=>clk,rst=>rst,Hsync=>Hsync,Vsync=>Vsync,vgaRed=>vgaRed, vgaGreen=>vgaGreen, vgaBlue=>vgaBlue, tile=>tile_s, index=>index_s); 
U3: KBD_ENC port map(clk=>clk, rst=>rst, PS2KeyboardCLK=>PS2KeyboardCLK, PS2KeyboardData=>PS2KeyboardData, data=>data_s, we=>we_s);
U4: sevensegment port map(clk=>clk, rst=>rst, an=>an, seg=>seg, data=>score_s);
U5: beep port map(clk=>clk, bang=>bang, beep_en=>beep_en_s);
--U3: main_kbd port map(clk=>clk, rst=>rst, PS2KeyboardCLK=>PS2KeyboardCLK, PS2KeyboardData=>PS2KeyboardCLK, an=>an, seg=>seg);
--component main_kbd is
--  port(clk                     : in STD_LOGIC;
--       rst                     : in STD_LOGIC;
--       PS2KeyboardCLK          : in STD_LOGIC;
--       PS2KeyboardData         : in STD_LOGIC;
--
--       an                      : out STD_LOGIC_VECTOR(3 downto 0);
--       seg                     : out STD_LOGIC_VECTOR(7 downto 0));
--end component;


end Behavioral;
