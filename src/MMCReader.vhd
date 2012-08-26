----------------------------------------------------------------------------------
-- Company: Hasso Plattner Institute (HPI) Potsdam
-- Engineer:  Dominik Moritz, Kai Fabian
-- 
-- Create Date:    00:32:56 07/21/2011 
-- Design Name: 
-- Module Name:    MMCReader - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.007 - File Created
-- Additional Comments: 
-- 	interesting: 
-- 	http://www.mikrocontroller.net/articles/MMC-_und_SD-Karten
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in  this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MMCReader is
    Port ( clk : in  STD_LOGIC;
           mmc_mosi : out STD_LOGIC;
           mmc_miso : in  STD_LOGIC;
           mmc_cs : out STD_LOGIC;
           mmc_clk : in STD_LOGIC;
			  work_clk : in  STD_LOGIC;
           --data : out STD_LOGIC_VECTOR (127 downto 0);
           --data_ready : out STD_LOGIC;
           enabled : in STD_LOGIC;
			  start_address :  in STD_LOGIC_VECTOR(31 downto 0);
			  -- default := "00000000" & "00000000" & "01111110" & "00000000"; - 0x00 00 7E 00, default data address of MMC
           
           fifo_full : in  STD_LOGIC;
           fifo_prog_full : in  STD_LOGIC;
           fifo_din  : out STD_LOGIC_VECTOR (15 downto 0);
           fifo_wr_en : out STD_LOGIC;
           fifo_wr_clk : out STD_LOGIC;
           
           current_state : out STD_LOGIC_VECTOR(7 downto 0);
			  status : out STD_LOGIC_VECTOR(15 downto 0);
			  
			  reset : in STD_LOGIC
			  );
end MMCReader;

architecture Behavioral of MMCReader is

constant CRC_WIDTH : Integer := 16;

constant BITS_PER_BYTE : Integer := 8;

constant MMC_BLOCK_BYTES : Integer := 512; -- 512
constant MMC_BLOCK_WIDTH : Integer := MMC_BLOCK_BYTES * BITS_PER_BYTE; -- 4096
constant MMC_SEGMENT_WIDTH : Integer := 2 * BITS_PER_BYTE; -- 16
constant MMC_SEGMENTS_TO_READ : Integer := MMC_BLOCK_WIDTH / MMC_SEGMENT_WIDTH; -- 256

constant MMC_CRC_WIDTH : Integer := 16;

constant MMC_BLOCK_SEGMENT_READ_WIDTH : Integer := 16;
constant MMC_START_BIT_WIDTH : Integer := 1;

constant MMC_BLOCK_READ_WIDTH : Integer := MMC_BLOCK_WIDTH + MMC_CRC_WIDTH + MMC_START_BIT_WIDTH; -- 4113


type mmc_state_type is (
	mmcs_reset,
	mmcs_wait,
	mmcs_cmd17,
	mmcs_receive_rt,
	mmcs_wait_for_start_byte,
	mmcs_receive_segments,
	mmcs_receive_crc,
	mmcs_error
);

type fifo_state_type is (
	fifo_wait,
	fifo_data_prepare,
	fifo_write,
	fifo_stop_writing
);

signal reset_request : STD_LOGIC := '0';
signal reset_reset : STD_LOGIC := '0';

signal mmc_state : mmc_state_type := mmcs_reset;
signal mmc_new_state : mmc_state_type := mmcs_reset;

signal receive_counter : Integer := 0;

signal mmc_clk_divider : Integer := 400 / 2; -- keep the /2, you're gonna need it!
signal mmc_work_clock : STD_LOGIC := '1';

signal mmc_cmd17 : STD_LOGIC_VECTOR (48 downto 0) := (others => '1');
signal mmc_receive_rt : STD_LOGIC_VECTOR (7 downto 0) := (others => '1');
signal mmc_receive_bk : STD_LOGIC_VECTOR (MMC_SEGMENT_WIDTH - 1 downto 0) := (others => '1');

signal mmc_receive_segment : STD_LOGIC_VECTOR (MMC_SEGMENT_WIDTH downto 0) := (others => '1');
signal mmc_receive_segment_push_to_fifo : STD_LOGIC_VECTOR (MMC_SEGMENT_WIDTH - 1 downto 0) := (others => '1');
signal mmc_segments_read : Integer Range 0 to MMC_SEGMENTS_TO_READ := 0;

signal mmc_receive_crc : STD_LOGIC_VECTOR (CRC_WIDTH downto 0) := (0 => '1', others => '0');

signal fifo_push : STD_LOGIC := '0';
signal fifo_push_catcher : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal fifo_state : fifo_state_type := fifo_wait;

signal read_address : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

signal read_counter : Integer Range 0 to MMC_BLOCK_READ_WIDTH := 0;
signal rc_is_dividable : STD_LOGIC := '0';

signal debug : STD_LOGIC;
signal debug_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');

begin

    fifo_wr_clk <= clk;
    
    reading_updater : Process (clk, mmc_state)
    begin
        if rising_edge(clk) then
            
            case mmc_state is -- LED7..LED0, not inverted ("as you would read it")
                when mmcs_reset => current_state <= "1000000" & enabled;
                when mmcs_wait => current_state <= "1000001" & enabled;
                when mmcs_cmd17 => current_state <= "1000010" & enabled;
                when mmcs_receive_rt => current_state <= "1000100" & enabled;
					 when mmcs_wait_for_start_byte => current_state <= "1001000" & enabled;
                when mmcs_receive_segments => current_state <= "1010000" & enabled;
					 when mmcs_error => current_state <= "01010101";
                when others => current_state <= (1 => enabled, 0 => mmc_clk, others => '1');
            end case;
        end if;
    end process reading_updater;
    
    reader : Process (clk, mmc_clk, mmc_state)
    begin
		  
        if falling_edge(mmc_clk) then
        
				reset_reset <= '0';
				status <= "0000000000000000";
            
            case mmc_state is
				
               		when mmcs_reset =>
					
						reset_reset <= '1';
					
						debug <= '0';
					
						mmc_mosi <= '1';
						mmc_cs <= '0';
						
						read_address <= start_address;
						
						mmc_new_state <= mmcs_wait;
						
					when mmcs_wait =>
					
						debug <= '0';
					
						mmc_mosi <= '1';
						mmc_cs <= '0';
					
						if reset_request = '0' then
							 if fifo_prog_full = '0' and enabled = '1' then
							 
								  mmc_new_state <= mmcs_cmd17;
								  mmc_cmd17 <= (others => '1');
								  mmc_receive_bk <= (others => '1');
							 elsif not enabled = '1' then
								  mmc_new_state <= mmcs_reset;
							 else
								  mmc_new_state <= mmcs_wait;
							 end if;
							 
						else -- reset is requested
							mmc_new_state <= mmcs_reset;
						end if;
						 
					when mmcs_cmd17 =>
						
						mmc_cs <= '0';
                
						if mmc_cmd17 = "1111111111111111111111111111111111111111111111111" then
							mmc_cmd17 <= "01010001" & -- 0x51
								 read_address &
								 "11111111" & -- DUMMY CRC 0xFF
								 "0"; -- Shift register empty bit
							read_address <= read_address + MMC_BLOCK_BYTES;
						elsif not (mmc_cmd17 = "0111111111111111111111111111111111111111111111111") then
							
							mmc_mosi <= mmc_cmd17(48);
							mmc_cmd17 <= mmc_cmd17(47 downto 0) & '1';

						else
							
							mmc_new_state <= mmcs_receive_rt;
							mmc_receive_rt <= (others => '1');
							
							mmc_cmd17 <= "1111111111111111111111111111111111111111111111111";

						end if;
                    
                when mmcs_receive_rt =>
						-- wait for response token
						mmc_cs <= '0';		
                
						if mmc_receive_rt(7) = '1' then -- wait for first 0 in response token reaching left bound of shift register ==> read completed
							 mmc_receive_rt <= mmc_receive_rt(6 downto 0) & mmc_miso;
						elsif mmc_receive_rt = "00000000" then -- all status bits must be 0, ref. SD SPI docs
							 mmc_new_state <= mmcs_wait_for_start_byte;
							 receive_counter <= 0;
						else
							mmc_new_state <= mmcs_error;
						end if;
						
					 when mmcs_wait_for_start_byte =>
						mmc_cs <= '0';
						if mmc_miso = '0' then
							mmc_new_state <= mmcs_receive_segments;
							mmc_segments_read <= 0;
							mmc_receive_segment <= (0 => '0', others => '1');
							--mmc_new_state <= mmcs_wait_for_start_byte;
						else
							mmc_new_state <= mmcs_wait_for_start_byte;
						end if;
						
						when mmcs_receive_segments =>
								mmc_new_state <= mmcs_receive_segments;
                        
								if mmc_segments_read < MMC_SEGMENTS_TO_READ then
									
									if mmc_receive_segment(MMC_SEGMENT_WIDTH) = '0' then
										-- completed reading word, push to fifo and start over
										mmc_segments_read <= mmc_segments_read + 1;
										mmc_receive_segment_push_to_fifo <= mmc_receive_segment(MMC_SEGMENT_WIDTH - 1 downto 0);
										mmc_receive_segment <= (1 => '0', 0 => mmc_miso, others => '1');
										fifo_push <= '1';
									else
										fifo_push <= '0';
										mmc_receive_segment <= mmc_receive_segment(MMC_SEGMENT_WIDTH - 1 downto 0) & mmc_miso;
									end if;
								
								else
								
									fifo_push <= '0';
									mmc_new_state <= mmcs_receive_crc;
									mmc_receive_crc <= (0 => '1', others => '0');
								
								end if;

					when mmcs_receive_crc =>
						
						if mmc_receive_crc(CRC_WIDTH) = '0' then
							mmc_receive_crc <= mmc_receive_crc(CRC_WIDTH - 1 downto 0) & mmc_miso;
						else
							mmc_new_state <= mmcs_wait;
						end if;

					when mmcs_error =>
						
						mmc_new_state <= mmcs_error;
						status <= "00000000" & mmc_receive_rt;
                    
                when others =>
					 
							mmc_cs <= 'Z';
                
							mmc_new_state <= mmcs_error;
                    
            end case;
            
        end if;
        
    end process reader;
	 
	 is_dividable : process (clk)
	 begin
		if falling_edge(clk) then
			if (read_counter mod 128 = 1) and not (read_counter = 1) then
				rc_is_dividable <=  '1';
			else
				rc_is_dividable <= '0';
			end if;
		end if;
	 end process is_dividable;
	 
	 debug_output : process (clk)
	 begin
		if rising_edge(clk) then
			if rc_is_dividable = '1' then
				debug_data <= mmc_receive_bk(MMC_SEGMENT_WIDTH - 1 downto MMC_SEGMENT_WIDTH - 8);
			end if;
		end if;
	 end process debug_output;
	 
	 resetter : process (clk)
	 begin
		if rising_edge(clk) then
			reset_request <= (reset_request OR reset) AND NOT reset_reset;
		end if;
	 end process resetter;
    
    delta_rk : process (clk)
    begin
        if falling_edge(clk) then
			if enabled = '1' then
				mmc_state <= mmc_new_state;
			else
				mmc_state <= mmcs_wait;
		   end if;
		  end if;
    end process delta_rk;
	 
	 fifo_pusher : process (clk)
	 begin
		if rising_edge(clk) then
			
			case fifo_state is
				
				when fifo_wait =>
					fifo_push_catcher <= fifo_push_catcher(0) & fifo_push;
					
					if (fifo_push_catcher = "10") then
						fifo_state <= fifo_data_prepare;
					else
						fifo_state <= fifo_wait;
					end if;
					
					fifo_wr_en <= '0';
					fifo_din <= (others => '0');
					
				when fifo_data_prepare =>
					
					fifo_wr_en <= '0';
					fifo_din <= mmc_receive_segment_push_to_fifo;
					fifo_state <= fifo_write;
					
				when fifo_write =>
					
					fifo_wr_en <= '1';
					fifo_din <= mmc_receive_segment_push_to_fifo;
					fifo_state <= fifo_stop_writing;
				
				when fifo_stop_writing =>
				
					fifo_wr_en <= '0';
					fifo_din <= mmc_receive_segment_push_to_fifo;
					fifo_state <= fifo_wait;
					
				when others =>
				
					fifo_din <= (others => '0');
					fifo_wr_en <= '0';
					fifo_state <= fifo_wait;
					
			end case;
		end if;
	end process fifo_pusher;

end Behavioral;

