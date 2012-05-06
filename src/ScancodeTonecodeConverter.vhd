----------------------------------------------------------------------------------
-- Company:  Ha Pe Ieh
-- Engineer: Dominik Moritz, Kai Fabian
-- 
-- Create Date:    17:24:40 07/16/2011 
-- Design Name: 
-- Module Name:    ScancodeTonecodeConverter - Behavioral 
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

entity ScancodeTonecodeConverter is
    Port ( scancode : in  STD_LOGIC_VECTOR (7 downto 0);
           tonecode : out  STD_LOGIC_VECTOR (5 downto 0);
			  clk : in STD_LOGIC);
end ScancodeTonecodeConverter;

architecture Behavioral of ScancodeTonecodeConverter is

begin

	Converter: process (clk)
	begin
	
	if rising_edge(clk) then
		case scancode is
			when "00011010" =>
				tonecode <= "000100";
			when "00011011" =>
				tonecode <= "000101";
			when "00100010" =>
				tonecode <= "000110";
			when "00100011" =>
				tonecode <= "000111";
			when "00100001" =>
				tonecode <= "001000";
			when "00101010" =>
				tonecode <= "001001";
			when "00110100" =>
				tonecode <= "001010";
			when "00110010" =>
				tonecode <= "001011";
			when "00110011" =>
				tonecode <= "001100";
			when "00110001" =>
				tonecode <= "001101";
			when "00111011" =>
				tonecode <= "001110";
			when "00111010" =>
				tonecode <= "001111";
			when "00011101" =>
				tonecode <= "010000";
			when "01000001" =>
				tonecode <= "010000";
			when "01001011" =>
				tonecode <= "010001";
			when "00100110" =>
				tonecode <= "010001";
			when "00100100" =>
				tonecode <= "010010";
			when "01001001" =>
				tonecode <= "010010";
			when "00100101" =>
				tonecode <= "010011";
			when "01001100" =>
				tonecode <= "010011";
			when "00101101" =>
				tonecode <= "010100";
			when "01001010" =>
				tonecode <= "010100";
			when "00101100" =>
				tonecode <= "010101";
			when "00110110" =>
				tonecode <= "010110";
			when "00110101" =>
				tonecode <= "010111";
			when "00111101" =>
				tonecode <= "011000";
			when "00111100" =>
				tonecode <= "011001";
			when "00111110" =>
				tonecode <= "011010";
			when "01000011" =>
				tonecode <= "011011";
			when "01000100" =>
				tonecode <= "011100";
				
			when others =>
				tonecode <= "000000";
		end case;
	end if;
	
	
	end process Converter;

end Behavioral;

