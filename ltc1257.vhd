----------------------------------------------------------------------------------
-- Company:   
-- Engineer: 
-- 
-- Create Date:	15:37:15 07/08/2011 
-- Design Name: 
-- Module Name:	ltc1257 - Behavioral 
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

entity ltc1257 is
	Port (	chipclk	: in   STD_LOGIC;
			dacdata	: in   STD_LOGIC_VECTOR (11 downto 0);
			load	: in   STD_LOGIC;
			ready	: out  STD_LOGIC;
			ic_load	: out  STD_LOGIC;
			ic_clk	: out  STD_LOGIC;
			ic_data	: out  STD_LOGIC);
end ltc1257;

architecture Behavioral of ltc1257 is

	signal readyout	 : STD_LOGIC := '1';
	signal work_clk	 : STD_LOGIC;
	signal send_zustand : STD_LOGIC_VECTOR (1 downto 0) := "00";

	signal send_word	: STD_LOGIC_VECTOR (12 downto 0) := "0111111111111";
	
	signal work_clk_detection : STD_LOGIC := '0';

begin

	work_teiler : entity Work.ClockDivisor port map (20, chipclk, work_clk); -- Arbeitstakt = 4 * SPI-Takt

	prepareSend : process (chipclk, load, send_word, work_clk, send_zustand, work_clk_detection)
	begin
		
		if rising_edge(chipclk) then
			work_clk_detection <= work_clk;
			
			--if load = '1' then
			if readyout = '1' then
			readyout <= '0';
				send_word <= dacdata & "0";
				send_zustand <= "00";
			elsif work_clk = '1' and not (work_clk_detection = work_clk) then
				readyout <= '1';
				
				if not (send_zustand = "00") or not (send_word = "0111111111111") then
					if (send_zustand = "11") and (send_word = "0111111111111") then
						ic_load <= '0';
					else
						ic_load <= '1';
					end if;
					
					readyout <= '0';
					
					case send_zustand is
						when "00" =>
							ic_clk <= '0';
							ic_data <= send_word(12);
							send_word <= send_word;
							send_zustand <= "01";
						when "01" =>
							ic_clk <= '1';
							send_word <= send_word(11 downto 0) & "1";
							send_zustand <= "10";
						when "10" =>
							ic_clk <= '1';
							send_zustand <= "11";
						when others =>
							-- dummy state for waiting...
							ic_clk <= '0';
							ic_data <= '0';
							send_zustand <= "00";
					end case;
				else
					send_zustand <= "00";
					ic_clk <= '0';
					ic_data <= '0';
					ic_load <= '1';
					readyout <= '1';
				end if;
			end if;
		end if;
		
		if falling_edge(chipclk) then
		end if;
	end process prepareSend;


	ready <= readyout;

end Behavioral;

