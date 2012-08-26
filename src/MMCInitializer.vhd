----------------------------------------------------------------------------------
-- Company: Hasso Plattner Institute (HPI) Potsdam
-- Engineer:  Dominik Moritz, Kai Fabian
-- 
-- Create Date:    00:32:56 07/21/2011 
-- Design Name: 
-- Module Name:    MMCInitializer - Behavioral 
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
--		might be interesting http://stackoverflow.com/questions/2365897/initializing-sd-card-in-spi-issues
--		simple: http://www.nawattlabs.com/index.php?option=com_content&view=article&id=26%3Asd-mmc-programming&catid=9%3Ablog&Itemid=5&showall=1
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MMCInitializer is
    Port ( clk : in  STD_LOGIC;
           mmc_mosi : out  STD_LOGIC;
           mmc_miso : in  STD_LOGIC;
           mmc_cs : out  STD_LOGIC;
			  mmc_clk : in  STD_LOGIC;
			  work_clk : in  STD_LOGIC;
			  ready : out STD_LOGIC;
			  fast_clock : out STD_LOGIC;
			  
			  current_state : out STD_LOGIC_VECTOR(7 downto 0);
			  status : out STD_LOGIC_VECTOR(7 downto 0)
			  );
end MMCInitializer;

architecture Behavioral of MMCInitializer is

type mmc_state_type is (mmcs_init_wait, mmcs_cmd0, mmcs_cmd0_response, mmcs_cmd1, mmcs_cmd1_wait, mmcs_cmd16_prepare, mmcs_cmd16, mmcs_cmd16_response, mmcs_ready, mmcs_error);
signal mmc_state : mmc_state_type := mmcs_init_wait;
signal mmc_new_state : mmc_state_type := mmcs_init_wait;

signal mmc_receive_rt : STD_LOGIC_VECTOR (7 downto 0) := (others => '1');

signal mmc_cmd0 : STD_LOGIC_VECTOR (48 downto 0) := (others => '1');
signal mmc_cmd1 : STD_LOGIC_VECTOR (48 downto 0) := (others => '1');
signal mmc_cmd1_wait : STD_LOGIC_VECTOR (7 downto 0) := (others => '1');
signal mmc_cmd16_wait : STD_LOGIC_VECTOR (15 downto 0) := (others => '1');
signal mmc_cmd16 : STD_LOGIC_VECTOR (48 downto 0) := (others => '1');

signal mmc_init_wait_counter : Integer Range 0 to 4095 := 200;

signal debug : STD_LOGIC;

begin
	
	
	initializing_updater : Process (clk, mmc_state)
	begin
		if rising_edge(clk) then
			if mmc_state = mmcs_ready then
				ready <= '1';
			else
				ready <= '0';
			end if;
			
			case mmc_state is
				when mmcs_init_wait => current_state <= "00000001";
				when mmcs_cmd0 => current_state <= "00000010";
				when mmcs_cmd0_response => current_state <= "00000100";
				when mmcs_cmd1 => current_state <= "00001000";
				when mmcs_cmd1_wait => current_state <= "00010000";
				when mmcs_cmd16_prepare => current_state <= "00100000";
				when mmcs_cmd16 => current_state <= "01000000";
				when mmcs_cmd16_response => current_state <= "10000000";
				when mmcs_ready => current_state <= "10000001";
				when mmcs_error => current_state <= mmc_receive_rt; -- zeige error an
				when others => current_state <= (others => '1');
			end case;
		end if;
	end process initializing_updater;
	
--	Set card select high
--	Send 80 SPI clock cycles (done by writing 0xFF 10 times)
--	Set card select low
--	Send CMD0 [0x400000000095] and Loop up to 8 times waiting for high bit on response to go low
--	R1 = 0x01 (indicates idle)
	
	initializator : Process (clk, mmc_clk, mmc_state)
	begin
		
		if falling_edge(mmc_clk) then
		
			status <= "10000000";
		
			mmc_cs <= '0';
			fast_clock <= '0';
			
			case mmc_state is
				when mmcs_init_wait =>
					-- wait at least 74 clock cycle units
					
					debug <= '0';
				
					mmc_cs <= '1';
					mmc_mosi <= '1';
				
					if mmc_init_wait_counter = 0 then
						mmc_new_state <= mmcs_cmd0;
						mmc_init_wait_counter <= 200;
					else
						mmc_init_wait_counter <= mmc_init_wait_counter - 1;
					end if;
					
				when mmcs_cmd0 =>
					-- send cmd0 (reset card)
					
					mmc_cs <= '0';
					
					if mmc_cmd0 = "1111111111111111111111111111111111111111111111111" then
						mmc_cmd0 <= "01000000" & -- 0x40
							"00000000" & -- 0x00
							"00000000" & -- 0x00
							"00000000" & -- 0x00
							"00000000" & -- 0x00
							"10010101" & -- 0x95 -- important: use the right crc because the card in not in spi mode yet
							"0"; -- padding so that we can detect end of sending
					elsif not (mmc_cmd0 = "0111111111111111111111111111111111111111111111111") then
						
						mmc_mosi <= mmc_cmd0(48);
						mmc_cmd0 <= mmc_cmd0(47 downto 0) & '1'; -- append 1s
					
					else
						
						mmc_new_state <= mmcs_cmd0_response;
						mmc_receive_rt <= (others => '1');
						
						mmc_cmd0 <= (others => '1');
					
					end if;
					
				when mmcs_cmd0_response =>
					-- wait for and read response
					-- response token hat eine 0 am anfang, auf diese warten
					-- schau hier: http://alumni.cs.ucr.edu/~amitra/sdcard/Additional/sdcard_appnote_foust.pdf
					-- oder in hitachi manual!!!
					-- richtige antwort ist: 00000001 ==  idle (In idle state: The card is in idle state and running the initializing process)
					
					if mmc_receive_rt(7) = '1' then
						 mmc_receive_rt <= mmc_receive_rt(6 downto 0) & mmc_miso;
					elsif mmc_receive_rt = "00000001" then
						 mmc_new_state <= mmcs_cmd1;
					else	
						 mmc_new_state <= mmcs_error;
					end if;
					
				when mmcs_cmd1 =>
					-- send cmd1 (card init process)
					
					debug <= '1';
					
					if mmc_cmd1 = "1111111111111111111111111111111111111111111111111" then
						mmc_cmd1 <= "01000001" & -- 0x41
							"00000000" & -- 0x00
							"00000000" & -- 0x00
							"00000000" & -- 0x00
							"00000000" & -- 0x00
							"11111111" & -- 0xFF ACHTUNG FALSCHER CRC, vmtl. bei CMD1 richtig?
							---- "11111001" & -- 0xF9 RICHTIGER CRC
							"0";
					elsif not (mmc_cmd1 = "0111111111111111111111111111111111111111111111111") then
						
						mmc_mosi <= mmc_cmd1(48);
						mmc_cmd1 <= mmc_cmd1(47 downto 0) & '1';
					
					else						
						mmc_new_state <= mmcs_cmd1_wait;
						mmc_cmd1_wait <= (others => '1');
						
						mmc_cmd1 <= (others => '1');
					
					end if;
					
				when mmcs_cmd1_wait =>
					-- wait until init process is completed
					-- wahrend init: response ist 00000001
					-- wenn fertig:  response ist 00000000
				
					if mmc_cmd1_wait(7) = '1' then				
						mmc_cmd1_wait <= mmc_cmd1_wait(6 downto 0) & mmc_miso;
						
					else					
						if mmc_cmd1_wait = "00000000" then
							fast_clock <= '1';
							mmc_cmd16_wait <= (others => '1');
							
							mmc_new_state <= mmcs_cmd16_prepare;							
							--mmc_new_state <= mmcs_ready; -- skip cmd16
						else
							mmc_new_state <= mmcs_cmd1;
						end if;
					
					end if;
					
			when mmcs_cmd16_prepare =>
				-- sende 8 clock impulse
				
--				//set MMC_Chip_Select to high (MMC/SD-Karte Inaktiv) 
--				MMC_Disable();
--				//sendet 8 Clock Impulse
--				Write_Byte_MMC(0xFF);
--				//set MMC_Chip_Select to low (MMC/SD-Karte Aktiv)
--				MMC_Enable();
				
				fast_clock <= '1';
				mmc_cs <= '1';
				mmc_mosi <= '1';
				
				if mmc_cmd16_wait = "0000000000000000" then
					mmc_new_state <= mmcs_cmd16;
					mmc_cmd16_wait <= (others => '1');
				else
					mmc_cs <= '0';
					mmc_cmd16_wait <= mmc_cmd16_wait(14 downto 0)&'0';
				end if;
					
			when mmcs_cmd16 =>
				-- sent cmd16 (set block lenght)
					
				mmc_cs <= '0';
				fast_clock <= '1';

-- 			c example code from here: http://ics.nxp.com/support/documents/microcontrollers/pdf/an10406.pdf		
--				/* send MMC CMD16(SET_BLOCKLEN) to set the block length */ 
--				MMCCmd[0] = 0x50; 
--				MMCCmd[1] = 0x00;  /* 4 bytes from here is the block length */ 
--										 /* LSB is first */   
--										 /* 00 00 00 10 set to 16 bytes */ 
--										 /* 00 00 02 00 set to 512 bytes */ 
--				MMCCmd[2] = 0x00; 
--				/* high block length bits - 512 bytes */ 
--				MMCCmd[3] = 0x02; 
--				/* low block length bits */ 
--				MMCCmd[4] = 0x00; 
--				/* checksum is no longer required but we always send 0xFF */ 
--				MMCCmd[5] = 0xFF; 
			
				if mmc_cmd16 = "1111111111111111111111111111111111111111111111111" then
					-- set command
					mmc_cmd16 <= "01010000" & -- 0x50
						"00000000" & -- 0x00
						"00000000" & -- 0x00
						"00000010" & -- 0x02
						"00000000" & -- 0x00 == 512 Byte
						"11111111" & -- 0xFF
						"0";
				elsif not (mmc_cmd16 = "0111111111111111111111111111111111111111111111111") then
					-- sending
					mmc_mosi <= mmc_cmd16(48);
					mmc_cmd16 <= mmc_cmd16(47 downto 0) & '1';
				
				else
					-- finished sending
					mmc_receive_rt <= (others => '1');
					mmc_new_state <= mmcs_cmd16_response;
					
					mmc_cmd16 <= (others => '1');
				
				end if;
				
			when mmcs_cmd16_response =>
					-- wait for and read response
					-- toll waere ein rt: 00000000
				
					if mmc_receive_rt(7) = '1' then
						 mmc_receive_rt <= mmc_receive_rt(6 downto 0) & mmc_miso;
					elsif mmc_receive_rt = "00000000" then
						 mmc_new_state <= mmcs_ready;
					else	
						 mmc_new_state <= mmcs_error;
					end if;					
					
			when mmcs_ready =>
				-- mmc is ready
				
				mmc_cs <= '0';
				fast_clock <= '1';
		
				mmc_new_state <= mmcs_ready;
				
				mmc_mosi <= 'Z';
				mmc_cs <= 'Z';
				
			when mmcs_error =>
				-- error trap state
				
				status <= debug & "1111001";
				
				mmc_new_state <= mmcs_error;
			when others =>

				mmc_mosi <= 'Z';
				mmc_cs <= 'Z';
			
				mmc_init_wait_counter <= 4095;
				mmc_new_state <= mmcs_init_wait;
					
			end case;
			
		end if;
		
	end process initializator;
	
	delta_rk : process (clk)
	begin
		if falling_edge(clk) then
			mmc_state <= mmc_new_state;
		end if;
	end process delta_rk;

end Behavioral;

