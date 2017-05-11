-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity VGA_MOTOR is
  port ( clk			: in std_logic;
	 rst			: in std_logic;
	 data			: in std_logic_vector(3 downto 0);
	 addr			: out unsigned(12 downto 0);
	 vgaRed		        : out std_logic;
	 vgaGreen	        : out std_logic;
	 vgaBlue		: out std_logic;
	 Hsync		        : out std_logic;
	 Vsync		        : out std_logic;
         blank                  : out std_logic);                    -- blanking signal
end VGA_MOTOR;


-- architecture
architecture Behavioral of VGA_MOTOR is

  signal	Xpixel	        : unsigned(9 downto 0) := B"0000000000"; -- Horizontal pixel counter
  signal	Ypixel	        : unsigned(9 downto 0) := B"0000000000"; -- Vertical pixel counter
  signal	ClkDiv	        : unsigned(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  signal	Clk25		: std_logic;			-- One pulse width 25 MHz signal
  signal        Clk25_q         : std_logic;                   -- Gris
  signal        Clk25_q_plus    : std_logic;                   -- Gris+
  signal        Enpuls_Clk25         : std_logic;                   -- Gris Enpuls
  
  signal 	tilePixel       : std_logic_vector(2 downto 0);	-- Tile pixel data
  signal	tileAddr	: unsigned(7 downto 0);	-- Tile address

	

  -- Tile memory type
  type ram_t is array (0 to 95) of std_logic_vector(2 downto 0);

-- Tile memory
  signal tileMem : ram_t := 
		( "111","111","111","111",	--white(x"0")
		  "111","111","111","111",
		  "111","111","111","111",
		  "111","111","111","111",
		  
		"110","110","110","110",  	--yellow(x"1")
		"110","110","110","110",
		"110","110","110","110",
		"110","110","110","110",
		
		"100","100","100","100",	--red(x"2")
		"100","100","100","100",
		"100","100","100","100",
		"100","100","100","100",
		
		"001","001","001","001",	--blue(x"3")
		"001","001","001","001",
		"001","001","001","001",
		"001","001","001","001",

		"010","010","010","010", 	--green(x"4")
		"010","010","010","010",
		"010","010","010","010",
		"010","010","010","010",
	
		"000","000","000","000", 	--black(x"5")
		"000","000","000","000",
		"000","000","000","000",
		"000","000","000","000"
		);
		  
begin

  -- Clock divisor
  -- Divide system clock (100 MHz) by 4
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
	ClkDiv <= (others => '0');
      else
	ClkDiv <= ClkDiv + 1;
      end if;
    end if;
  end process;
	
  -- 25 MHz clock (one system clock pulse width)
  Clk25 <= '1' when (ClkDiv = 3) else '0';
  
  process(clk)
  begin
    if rising_edge(clk) then
      Clk25_q <= Clk25_q_plus;
    end if;
  end process;

  Clk25_q_plus <= Clk25;
  Enpuls_Clk25 <= (not Clk25_q) and Clk25;
  
  -- Horizontal pixel counter
  -- Xpixel
 
  process(clk)
  begin
    if rising_edge(clk) then
      if Enpuls_Clk25 = '1' then
        if Xpixel >= 799 then
          Xpixel <= "0000000000";
        else
          Xpixel <= Xpixel + 1;
        end if;
      end if;
    end if;
  end process;
  
  -- Horizontal sync
  -- Hsync

  Hsync <= '0' when(Xpixel >= 656 and Xpixel <= 751) else '1';
  
  -- Vertical pixel counter
  -- Ypixel

  process(clk)
  begin
    if rising_edge(clk) then
      if Enpuls_Clk25 = '1' then
        if Ypixel >= 520 and Xpixel >= 799 then
          Ypixel <= "0000000000";
        elsif Xpixel >= 799 then
          Ypixel <= Ypixel + 1;
        end if;
      end if;
    end if;
  end process;	

  -- Vertical sync
  -- Vsync

  Vsync <= '0' when(Ypixel >= 490 and Ypixel <= 491) else '1';
  
  -- Video blanking signal
  -- Blank
  
  blank <= '1' when((Ypixel >= 480 and Ypixel <= 520) or (Xpixel >= 640 and Xpixel <= 799)) else '0';
  

  
  -- Tile memory
  process(clk)
  begin
    if rising_edge(clk) then
      if (blank = '0') then
        tilePixel <= tileMem(to_integer(tileAddr));
      else
        tilePixel <= (others => '0');
      end if;
    end if;
  end process;
	


  -- Tile memory address composite
  tileAddr <= unsigned(data(3 downto 0)) & Ypixel(2 downto 1) & Xpixel(2 downto 1);


  -- Picture memory address composite
  addr <= to_unsigned(80,7)*Ypixel(8 downto 3) + Xpixel(9 downto 3);


  -- VGA generation
  vgaRed 	<= tilePixel(2);
 -- vgaRed(1) 	<= '1';
 -- vgaRed(0) 	<= '0';
  vgaGreen   <= tilePixel(1);
 -- vgaGreen(1)   <= '1';
 --vgaGreen(0)   <= '0';
  vgaBlue 	<= tilePixel(0);
 -- vgaBlue(1) 	<= '0';


end Behavioral;

