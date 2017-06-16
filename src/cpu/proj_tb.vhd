LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY proj_tb IS
END proj_tb;

ARCHITECTURE behavior OF proj_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT proj
  PORT(clk : IN std_logic;
       rst : IN std_logic;
       key: in unsigned(7 downto 0);
       beep_en:out std_logic;
       tile: out unsigned(3 downto 0);
       index: out unsigned(15 downto 0);
       score : out unsigned(15 downto 0);
	random :in unsigned(12 downto 0));
  END COMPONENT;

  --Inputs
  signal clk : std_logic:= '0';
  signal rst : std_logic:= '0';
  signal key : unsigned(7 downto 0) := x"00";  -- fuck u
  signal beep_en : std_logic := '0';
  signal tile : unsigned(3 downto 0) := x"0";
  signal index : unsigned(15 downto 0) := x"0000";
  signal score : unsigned(15 downto 0) := x"0000";
  signal random : unsigned(12 downto 0) := "0000000000000";

  constant clk_period : time:= 1 us;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut: proj PORT MAP (
    clk => clk,
    rst => rst,
    key => key,
    beep_en =>beep_en,
    tile => tile,
    index => index,
    score => score,
    random =>random
  );
		
  -- Clock process definitions
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

	rst <= '1', '0' after 1.7 us;
END;

