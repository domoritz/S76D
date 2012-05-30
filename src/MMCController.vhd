----------------------------------------------------------------------------------
-- Company: Hasso Plattner Institute (HPI) Potsdam
-- Engineer:  Dominik Moritz, Kai Fabian
-- 
-- Create Date:    14:06:10 09/09/2011 
-- Design Name: 
-- Module Name:    MMCController - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MMCController is
    Port ( clk : in STD_LOGIC;
           
			  mmc_cs : out STD_LOGIC;
           mmc_miso : in  STD_LOGIC;
           mmc_mosi : out STD_LOGIC;
           mmc_clock : out STD_LOGIC;
			  
			  message : out STD_LOGIC_VECTOR(15 downto 0);
			  status : out STD_LOGIC_VECTOR(7 downto 0);
			  
			  reset : in STD_LOGIC;
			  
			  start_address : in STD_LOGIC_VECTOR(31 downto 0);
           
           fifo_full : in  STD_LOGIC;
           fifo_prog_full : in  STD_LOGIC;
           fifo_din  : out STD_LOGIC_VECTOR (15 downto 0);
           fifo_wr_en : out STD_LOGIC;
           fifo_wr_clk : out STD_LOGIC
	);
end MMCController;

architecture Behavioral of MMCController is

subtype STATE_T is STD_LOGIC_VECTOR(0 downto 0);
  constant STATE_T_INITIALIZING : STATE_T := "0";
  constant STATE_T_READY : STATE_T := "1";

signal state : STATE_T := STATE_T_INITIALIZING;
signal next_state : STATE_T := STATE_T_INITIALIZING;

signal initializer_ready : STD_LOGIC := '0';
signal initializer_current_state : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal initializer_status : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

signal reader_enabled : STD_LOGIC := '0';
signal reader_current_state : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal reader_status : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
-- signal reader_start_address : STD_LOGIC_VECTOR(31 downto 0) :=  "00000000" & "00000000" & "01111110" & "00000000";

signal work_clk : STD_LOGIC := '0';
signal int_mmc_clk : STD_LOGIC := '0';
signal mmc_clk_divider : Integer := 400 / 2; -- keep the /2, you're gonna need it!

signal fast_clock : STD_LOGIC := '0';

signal initializer_mmc_cs : STD_LOGIC := 'Z';
signal initializer_mmc_mosi : STD_LOGIC := 'Z';
signal reader_mmc_cs : STD_LOGIC := 'Z';
signal reader_mmc_mosi : STD_LOGIC := 'Z';

--signal fifo_rst : STD_LOGIC;
--signal fifo_wr_clk : STD_LOGIC;
--signal fifo_din : STD_LOGIC_VECTOR(15 DOWNTO 0);
--signal fifo_wr_en : STD_LOGIC;
--signal fifo_full : STD_LOGIC;
--signal fifo_wr_data_count : STD_LOGIC_VECTOR(13 DOWNTO 0);
--signal fifo_prog_full : STD_LOGIC;

signal pcm_word : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal wave_word : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

begin

	MMCClockDivider : entity Work.ClockDivisor Port Map (mmc_clk_divider, clk, work_clk);

	initializer : entity Work.MMCInitializer Port Map (
		clk => clk,
		mmc_mosi => initializer_mmc_mosi,
		mmc_cs   => initializer_mmc_cs,
		mmc_miso => mmc_miso,
		mmc_clk => int_mmc_clk,
		work_clk => work_clk,
		ready => initializer_ready,
		current_state => initializer_current_state,
		status => initializer_status,
		fast_clock => fast_clock
	);

	reader : entity Work.MMCReader Port Map (
		clk => clk,
		mmc_mosi => reader_mmc_mosi,
		mmc_cs   => reader_mmc_cs,
		mmc_miso => mmc_miso,
		mmc_clk => int_mmc_clk,
		work_clk => work_clk,
		current_state => reader_current_state,
		status => reader_status,
		enabled => reader_enabled,
		start_address => start_address,
		
		fifo_full => fifo_full,
      fifo_prog_full => fifo_prog_full,
      fifo_din => fifo_din,
      fifo_wr_en => fifo_wr_en,
      fifo_wr_clk => fifo_wr_clk,
		
		reset => reset
	);
	
	mmc_clock <= int_mmc_clk;
	
	mmc_clk_generator : Process (work_clk, fast_clock)
	begin
		if fast_clock = '1' then
			mmc_clk_divider <= 6 / 2;
		else
			mmc_clk_divider <= 400 / 2;
		end if;
	
		if rising_edge(work_clk) then
			int_mmc_clk <= not int_mmc_clk;
		end if;
	
	end process mmc_clk_generator;

	initializer_process : Process (clk)
	begin
		
		if rising_edge(clk) then
	
			--message <= X"FFFF";
		
			case state is

				when STATE_T_INITIALIZING =>
					mmc_mosi <= initializer_mmc_mosi;
					mmc_cs <= initializer_mmc_cs;
					
					status <= initializer_current_state;
					----state2 <= not initializer_status;
					--message <= "00000000" & initializer_status;
				
					if initializer_ready = '1' then
						next_state <= STATE_T_READY;						
					end if;
					reader_enabled <= '0';

				
				when STATE_T_READY =>
					mmc_mosi <= reader_mmc_mosi;
					mmc_cs <= reader_mmc_cs;
					
					status <= reader_current_state;
					--message <= reader_status;
					
					-- reader_start_address <= "00000000" & "00000000" & X"7E" & X"00";
					reader_enabled <= '1';
				
				when others =>
					-- ???
			
			end case;
		
		end if;
		
		if falling_edge(clk) then
			state <= next_state;
		end if;
		
	end process initializer_process;

end Behavioral;

