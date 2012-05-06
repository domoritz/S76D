----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:58:50 03/25/2012 
-- Design Name: 
-- Module Name:    MusicPlayer - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MusicPlayer is
    Port ( clk : in STD_LOGIC;
			  mmc_cs : out STD_LOGIC;
           mmc_miso : in  STD_LOGIC;
           mmc_mosi : out STD_LOGIC;
           mmc_clock : out STD_LOGIC;
			  
			  leds : out STD_LOGIC_VECTOR(7 downto 0); -- = LED7..LED0, not inverted ("as you would read it")
			  segment_data : out STD_LOGIC_VECTOR(7 downto 0);
			  segment_addr : out STD_LOGIC_VECTOR(3 downto 0);
			  
			  switches : in STD_LOGIC_VECTOR(7 downto 0);
			  
			  kbclk : in  STD_LOGIC;
           kbdata : in  STD_LOGIC;
			  
			  reset : in STD_LOGIC;
			  
--			  read_fifo : in STD_LOGIC;
--			  mode_fifo1 : in STD_LOGIC;
--			  mode_fifo2 : in STD_LOGIC;
			  
			  dacclk : out STD_LOGIC;
			  dacdata : out STD_LOGIC;
			  dacload : out STD_LOGIC
	);
end MusicPlayer;

architecture Behavioral of MusicPlayer is

signal fifo_rst : STD_LOGIC;
signal fifo_wr_clk : STD_LOGIC;
signal fifo_rd_clk : STD_LOGIC;
signal fifo_din : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal fifo_wr_en : STD_LOGIC;
signal fifo_rd_en : STD_LOGIC;
signal fifo_dout : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal fifo_full : STD_LOGIC;
signal fifo_empty : STD_LOGIC;
signal fifo_rd_data_count : STD_LOGIC_VECTOR(13 DOWNTO 0);
signal fifo_wr_data_count : STD_LOGIC_VECTOR(13 DOWNTO 0);
signal fifo_prog_full : STD_LOGIC;

signal read_fifo_catcher : STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');
signal fifo_dbg_clk : STD_LOGIC := '0';

signal dac_load : STD_LOGIC := '0';
signal dac_data : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal audio_clk : STD_LOGIC := '0';

signal wave_word : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal pcm_word : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

signal seg_num : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

signal mmc_status : STD_LOGIC_VECTOR(7 downto 0);
signal mmc_message : STD_LOGIC_VECTOR(15 downto 0);
signal mmc_reset : STD_LOGIC;

signal kb_scancode : STD_LOGIC_VECTOR(7 downto 0);
signal kb_break : STD_LOGIC;
signal kb_extend : STD_LOGIC;
signal kb_ready : STD_LOGIC;
signal kb_ready_flankenfaenger : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal kb_debug : STD_LOGIC_VECTOR(7 downto 0);

signal moebius_clk : STD_LOGIC;
signal moebius_disp : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

signal song_number : STD_LOGIC_VECTOR(7 downto 0) := X"00";

type player_state is (
	ps_paused,
	ps_playing
);

signal state : player_state := ps_playing;
signal new_state : player_state := ps_playing;
signal is_playing : STD_LOGIC;

signal start_address : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin
--entity KeyboardController is Port(
--			  kbclk : in  STD_LOGIC;
--           kbdata : in  STD_LOGIC;
--           reset : in  STD_LOGIC;
--           clk : in  STD_LOGIC;
--           scancode : out  STD_LOGIC_VECTOR (7 downto 0);
--			  break : out STD_LOGIC;
--			  extend : out STD_LOGIC;
--           ready : out  STD_LOGIC
--	);
	
	Keyboard : entity Work.KeyboardController Port Map (
		debug => kb_debug,
		
		kbclk => kbclk,
		kbdata => kbdata,
		reset => reset,
		clk => clk,
		scancode => kb_scancode,
		break => kb_break,
		extend => kb_extend,
		ready => kb_ready
	);
	
	DAC : entity Work.ltc1257 Port Map (
		chipclk => clk,
		dacdata => dac_data,
		load => dac_load,
		ic_load => dacload,
		ic_clk => dacclk,
		ic_data => dacdata
	);

	FIFO : entity Work.mmc_fifo Port Map (
		rst => fifo_rst,
		wr_clk => fifo_wr_clk,
		rd_clk => fifo_rd_clk,
		din => fifo_din,
		wr_en => fifo_wr_en,
		rd_en => fifo_rd_en,
		dout => fifo_dout,
		full => fifo_full,
		empty => fifo_empty,
		rd_data_count => fifo_rd_data_count,
		wr_data_count => fifo_wr_data_count,
		prog_full => fifo_prog_full
	);
	
	MMCController: entity Work.MMCController Port Map (
		clk => clk,
		
		mmc_cs => mmc_cs,
		mmc_miso => mmc_miso,
		mmc_mosi => mmc_mosi,
		mmc_clock => mmc_clock,
		
		message => mmc_message,
		status => mmc_status,
		
		reset => mmc_reset,
		
		start_address => start_address,
		
		fifo_full => fifo_full,
      fifo_prog_full => fifo_prog_full,
      fifo_din => fifo_din,
      fifo_wr_en => fifo_wr_en,
      fifo_wr_clk => fifo_wr_clk
	);

	SegmentDriver : entity Work.SegmentDisplay Port Map (
		segnum => seg_num,
		segsel => segment_addr,
		segbus => segment_data,
		chipclk => clk
	);

	AudioClockDivider : entity Work.ClockDivisor Port Map (1134, clk, audio_clk);

	MoebiusClockDivider : entity Work.ClockDivisor Port Map (3125000, clk, moebius_clk);
	
	wave_word <= fifo_dout(7 downto 0) & fifo_dout(15 downto 8);
	pcm_word <= (wave_word + 32768);
	dac_data <= pcm_word(15 downto 4);
	fifo_rd_clk <= not audio_clk;
	fifo_rd_en <= is_playing;
	
	dac_load <= audio_clk;
	
	----seg_num <= X"00" & kb_scancode;
	----leds <= kb_scancode;
	
	debug_output : process (clk, switches)
	begin
		
		if rising_edge(clk) then
			if switches = X"00" then
				seg_num <= X"00" & song_number;
				if (state = ps_playing) then
					leds <= (0 => '1', others => '0');
				else
					leds <= (0 => '0', others => '0');
				end if;
			elsif switches = X"01" then
				seg_num <= fifo_dout;
				leds <= mmc_status;
			elsif switches = X"02" then
				seg_num <= mmc_message;
				leds <= mmc_status;
			elsif switches = X"04" then
				seg_num <= X"00" & kb_scancode;
				leds <= kb_debug(7 downto 2) & kb_extend & kb_break;
			else
				seg_num <= X"AFFE";
				leds <= moebius_disp;
			end if;
		end if;
		
	end process debug_output;
	
	moebius : process (moebius_clk)
	begin
		if rising_edge(moebius_clk) then
			moebius_disp <= moebius_disp(6 downto 0) & not moebius_disp(7);
		end if;
	end process moebius;
	
	player : process (clk, kb_scancode, kb_break)
	begin
		
		if rising_edge(clk) then
		
			kb_ready_flankenfaenger <= kb_ready_flankenfaenger(0) & kb_ready;
		
			case state is
			
				when ps_paused =>
					new_state <= ps_paused;
					
					is_playing <= '0';
					mmc_reset <= '0';
					fifo_rst <= '0';
					
					if kb_ready_flankenfaenger = "01" and kb_break = '1' then
						if kb_scancode = X"76" then
							new_state <= ps_playing;
						elsif kb_scancode = X"05" then
							-- f1 = play song no. 1
							new_state <= ps_playing;
							mmc_reset <= '1';
							fifo_rst <= '1';
							start_address <= X"00000000";
							song_number <= X"01";
						elsif kb_scancode = X"06" then
							-- f2 = play song no. 2
							new_state <= ps_playing;
							mmc_reset <= '1';
							fifo_rst <= '1';
							start_address <= X"04000000";
							song_number <= X"02";
						elsif kb_scancode = X"04" then
							-- f3 = play song no. 3
							new_state <= ps_playing;
							mmc_reset <= '1';
							fifo_rst <= '1';
							start_address <= X"08000000";
							song_number <= X"03";
						elsif kb_scancode = X"0C" then
							-- f4 = play song no. 4
							new_state <= ps_playing;
							mmc_reset <= '1';
							fifo_rst <= '1';
							start_address <= X"0C000000";
							song_number <= X"04";
						elsif kb_scancode = X"03" then
							-- f5 = play song no. 5
							new_state <= ps_playing;
							mmc_reset <= '1';
							fifo_rst <= '1';
							start_address <= X"10000000";
							song_number <= X"05";
						elsif kb_scancode = X"0b" then
							-- f6 = play song no. 6
							new_state <= ps_playing;
							mmc_reset <= '1';
							fifo_rst <= '1';
							start_address <= X"14000000";
							song_number <= X"06";
						elsif kb_scancode = X"83" then
							-- f7 = play song no. 7
							new_state <= ps_playing;
							mmc_reset <= '1';
							fifo_rst <= '1';
							start_address <= X"18000000";
							song_number <= X"07";
						elsif kb_scancode = X"0A" then
							-- f8 = play song no. 8
							new_state <= ps_playing;
							mmc_reset <= '1';
							fifo_rst <= '1';
							start_address <= X"1C000000";
							song_number <= X"08";
						end if;
					end if;
						
					
				when ps_playing =>
					new_state <= ps_playing;
					
					mmc_reset <= '0';
					is_playing <= '1';
					fifo_rst <= '0';
					
					if kb_ready_flankenfaenger = "01" and (kb_break = '1') then
						if kb_scancode = X"76" then
							new_state <= ps_paused;
						end if;
					end if;
					
				when others =>
					new_state <= ps_paused;
			
			end case;
		
		end if;
		
	end process player;
	
	delta_rk : process (clk, new_state)
	begin
		if falling_edge(clk) then
			state <= new_state;
		end if;
	end process delta_rk;

end Behavioral;

