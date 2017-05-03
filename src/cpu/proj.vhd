library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--CPU interface
entity proj is
  port(clk: in std_logic;
	     rst: in std_logic);
end proj ;

architecture Behavioral of proj is


  -- micro Memory component
  component uMem
    port(uAddr : in unsigned(7 downto 0);
         uData : out unsigned(24 downto 0));
  end component;

  -- program Memory component
  component pMem
    port(pAddr : in unsigned(31 downto 0);
         pData : out unsigned(31 downto 0));
  end component;

  -- K1 memory component
  component K1
    port(operand: in unsigned(3 downto 0);
         K1_adress: out unsigned(7 downto 0));
  end component;

  -- K1 memory component
  signal K1_reg : unsigned(7 downto 0);  -- K1 memory output
  -- micro memory signals
  signal uM : unsigned(24 downto 0); -- micro Memory output
  signal uPC : unsigned(7 downto 0); -- micro Program Counter
  --signal uPCsig : std_logic; -- (0:uPC++, 1:uPC=uAddr)
  signal uAddr : unsigned(7 downto 0); -- micro Address
  signal TB : unsigned(2 downto 0); -- To Bus field
  signal FB : unsigned(2 downto 0); -- From Bus field
  signal ALU : unsigned(3 downto 0); -- ALU for arithmetical/logical operations
  signal LC : unsigned(1 downto 0) ; -- loop counter
  signal SEQ : unsigned(3 downto 0); -- uPC contidion setter

  -- program memory signals
  signal PM : unsigned(31 downto 0); -- Program Memory output
  signal PC : unsigned(31 downto 0); -- Program Counter
  signal Pcsig : std_logic; -- 0:PC=PC, 1:PC++
  signal ASR : unsigned(31 downto 0); -- Address Register
  signal IR : unsigned(31 downto 0); -- Instruction Register
  signal DATA_BUS : unsigned(31 downto 0); -- Data Bus
  signal AR : unsigned(32 downto 0); -- stores alu operated values
  signal GRx : unsigned(3 downto 0) ; -- grx part in pm
  signal OP : unsigned(3 downto 0); -- Oeration part in pm
  signal GRx0 : unsigned(31 downto 0); 		
  signal GRx1 : unsigned(31 downto 0); 	
  signal GRx2 : unsigned(31 downto 0); 	
  signal GRx3 : unsigned(31 downto 0); 	
  signal LC_REG : unsigned(7 downto 0); -- register holding loop value
  signal L , N, Z, O, C : std_logic := '0';    -- flags
  signal HALT : std_logic := '1';       -- flag for halting PC
  signal PM_ADR : unsigned(15 downto 0);  -- adress part of PM
  signal AR_TEMP : std_logic :='0';  -- temporary value for MSB in AR

begin

  -- mPC : micro Program Counter
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1' or SEQ = "0011") then
        uPC <= (others => '0');
      elsif (SEQ ="0101") then
        uPC <= uAddr;
      elsif (SEQ = "0000") then
        uPC <= uPC + 1;
      elsif (SEQ="0001") then
        uPC <= K1_reg;                      
      elsif (SEQ = "1000" and Z='1') then
        uPC <= uAddr;
      elsif (SEQ = "1001" and N='1') then
        uPC <= uAddr;
      elsif (SEQ = "1100" and L='1') then
        uPC <= uAddr;
      elsif (SEQ ="1010" and C = '1') then
        uPC <= uAddr;
      elsif (SEQ="1011" and O = '1') then
        uPC <= uAddr;
      elsif (SEQ = "1111") then
        HALT <= '0';
      else
        uPC <= uPC + 1;
      end if;
    end if;
  end process;
	
  -- PC : Program Counter
  process(clk)
  begin
    if (HALT ='1') then  
      if rising_edge(clk) then
        if (rst = '1') then
          PC <= (others => '0');
        elsif (FB = "011") then
          PC <= DATA_BUS;
        elsif (PCsig = '1') then
          PC <= PC + 1;
        end if;
      end if;
    end if;
  end process;
	
  -- IR : Instruction Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        IR <= (others => '0');
      elsif (FB = "001") then
        IR <= DATA_BUS;
      end if;
    end if;
  end process;
	
  -- ASR : Address Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        ASR <= (others => '0');
      elsif (FB = "100") then
        ASR <= DATA_BUS;
      end if;
    end if;
  end process;

  -- GRx: general register
  process(clk)
  begin
    if rising_edge(clk) then 
      if (rst ='1') then
	GRx0 <= (others => '0');
	GRx1 <= (others => '0');
	GRx2 <= (others => '0');
	GRx3 <= (others => '0');
      elsif (FB = "110") then
	if (GRx = 0) then
	   GRx0 <= DATA_BUS;
	elsif (GRx = 1) then
	   GRx1 <= DATA_BUS;
	elsif (GRx = 2) then
	   GRx2 <= DATA_BUS;
        elsif (GRx = 3) then
    	   GRx3 <= DATA_BUS;
	end if;
      end if;
    end if;
  end process;	
 

  -- LC: LC counter
  process(clk)
  begin
     if rising_edge(clk) then
	if (rst ='1') then
	  LC_REG <= (others => '0');
          L <= '0';
	elsif (LC = "01") then 
	  LC_REG <= LC_REG - 1;
          if (LC_REG = 0 ) then
            L <= '1';
          else
            L <= '0';
          end if;
          
	elsif (LC = "10") then
	  LC_REG <= DATA_BUS(7 downto 0);
          if (LC_REG = 0 ) then
            L <= '1';
          else
            L <= '0';
          end if;
          
	elsif (LC = "11") then
	  LC_REG <= uAddr;
          if (LC_REG = 0 ) then
            L <= '1';
          else
            L <= '0';
          end if;
	end if;
     end if;
  end process;

 -- ALU  
 process(clk)
 begin
    if rising_edge(clk) then
        if (rst ='1' or ALU = "0011") then
  	  AR <= (others => '0');
          Z <= '1';
          N <= '0';
 	elsif (ALU= "0001") then
	  AR <= ('0' & DATA_BUS);
          if (signed(AR) < 0) then
            N <= '1';
          elsif (AR = 0) then
            Z <= '1';
          else
            N <= '0';
            Z <= '0';
          end if;
        
	elsif (ALU ="0100") then
          AR_TEMP <= AR(31);
	  AR <= AR + ('0' & DATA_BUS);
          if ((AR(31)/=AR_TEMP) and (AR(31)/= DATA_BUS(31))) then
            O <= '1';
          else
            O <= '0';
          end if;
          if (AR(32)='1') then
            C <='1';
          else
            C <= '0';
          end if;
          if (signed(AR) < 0) then
            N <= '1';
          elsif (AR = 0) then
            Z <= '1';
          else
            N <= '0';
            Z <= '0';
          end if;
          
	elsif (ALU ="0101") then
	  AR <= AR - ('0' & DATA_BUS);
          if (AR(32)='1') then
            C <='1';
          else
            C <= '0';
          end if;
          if (signed(AR) < 0) then
            N <= '1';
          elsif (AR = 0) then
            Z <= '1';
          else
            N <= '0';
            Z <= '0';
          end if;
          
	elsif (ALU = "0110") then
          O <= '0';                     -- ???? checka senare om rätt
          C <= '0';
	  AR <= AR and ('0' & DATA_BUS);
          if (signed(AR) < 0) then
            N <= '1';
          elsif (AR = 0) then
            Z <= '1';
          else
            N <= '0';
            Z <= '0';
          end if;
            
	elsif (ALU = "0111") then
          O <= '0';
          C <='0';
	  AR <= AR or ('0' & DATA_BUS);
          if (signed(AR) < 0) then
            N <= '1';
          elsif (AR = 0) then
            Z <= '1';
          else
            N <= '0';
            Z <= '0';
          end if;
        end if; 
    end if;
 end process;

  -- micro memory component connection
  U0 : uMem port map(uAddr=>uPC, uData=>uM);

  -- program memory component connection
  U1 : pMem port map(pAddr=>ASR, pData=>PM);

  -- K1 memory component connection
  U2 : K1 port map(operand => OP, K1_adress => K1_reg);



  
  -- micro memory signal assignments
  
  uAddr <= uM(7 downto 0);
  SEQ <= uM(11 downto 8);
  LC <= uM(13 downto 12);
  PCsig <= uM(14);
  FB <= uM(17 downto 15);
  TB <= uM(20 downto 18);
  ALU <= uM(24 downto 21);       
  	
  -- primary memory signal assignment
  GRx <= pM(27 downto 24);
  OP <= pM(31 downto 28);
  PM_ADR <= pM(15 downto 0);
  -- data bus assignment
  DATA_BUS <= IR when (TB = "001") else
    PM when (TB = "010") else
    PC when (TB = "011") else
    ASR when (TB = "100") else
    GRx0 when (TB ="110" and GRx = 0) else
    GRx1 when (TB ="110" and GRx = 1) else
    GRx2 when (TB ="110" and GRx = 2) else
    GRx3 when (TB ="110" and GRx = 3) else
    (others => '0');

end Behavioral;
