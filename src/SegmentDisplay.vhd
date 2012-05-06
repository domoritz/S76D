----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Dominik Moritz, Kai Fabian
-- 
-- Create Date:    10:11:42 07/08/2011 
-- Design Name: 
-- Module Name:    SegmentDisplay - Behavioral 
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

use functions.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- REQUIRED CONSTRAINTS:
-- NET "chipclk" LOC = T9;
-- NET "segbus[0]" LOC = E14;
-- NET "segbus[1]" LOC = G13;
-- NET "segbus[2]" LOC = N15;
-- NET "segbus[3]" LOC = P15;
-- NET "segbus[4]" LOC = R16;
-- NET "segbus[5]" LOC = F13;
-- NET "segbus[6]" LOC = N16;
-- NET "segbus[7]" LOC = P16;
-- NET "segsel[0]" LOC = D14;
-- NET "segsel[1]" LOC = G14;
-- NET "segsel[2]" LOC = F14;
-- NET "segsel[3]" LOC = E13;

-- OPTIONAL DEBUG CONSTRAINTS:
-- NET "seg0[0]" LOC = K13;
-- NET "seg0[1]" LOC = K14;
-- NET "seg0[2]" LOC = J13;
-- NET "seg0[3]" LOC = J14;
-- NET "seg0[4]" LOC = H13;
-- NET "seg0[5]" LOC = H14;
-- NET "seg0[6]" LOC = G12;
-- NET "seg0[7]" LOC = F12;

entity SegmentDisplay is
    Port ( segnum : in   STD_LOGIC_VECTOR (15 downto 0);
           segsel : out  STD_LOGIC_VECTOR (3 downto 0);
           segbus : out  STD_LOGIC_VECTOR (7 downto 0);
			  
			chipclk : in STD_LOGIC);
end SegmentDisplay;

architecture Behavioral of SegmentDisplay is

	signal disp_clk : STD_LOGIC;
	signal position : STD_LOGIC_VECTOR (1 downto 0);
    
    signal seg0 : STD_LOGIC_VECTOR (3 downto 0);
    signal seg1 : STD_LOGIC_VECTOR (3 downto 0);
    signal seg2 : STD_LOGIC_VECTOR (3 downto 0);
    signal seg3 : STD_LOGIC_VECTOR (3 downto 0);

begin

taktteiler : entity Work.ClockDivisor port map (100000, chipclk, disp_clk);

	zaehle : process (disp_clk)
	begin
		if rising_edge(disp_clk) then
			case position is
				when "00" =>
					position <= "01";
				when "01" =>
					position <= "10";
				when "10" =>
					position <= "11";
				when others =>
					position <= "00";
			end case;
		end if;
	end process zaehle;
	
	multiplexer : process (position, segnum, disp_clk)
	begin
		if falling_edge(disp_clk) and (position = "00") then
			seg0 <= segnum(3 downto 0);
			seg1 <= segnum(7 downto 4);
			seg2 <= segnum(11 downto 8);
			seg3 <= segnum(15 downto 12);
		end if;
		
		case position is
			when "00" =>
				segbus <= FourBitToDisp(seg0);
				segsel <= "1110";
			when "01" =>
				segbus <= FourBitToDisp(seg1);
				segsel <= "1101";
			when "10" =>
				segbus <= FourBitToDisp(seg2);
				segsel <= "1011";
			when "11" =>
				segbus <= FourBitToDisp(seg3);
				segsel <= "0111";
			when others =>
				segbus <= "11111111";
				segsel <= "1111";
		end case;
	end process multiplexer;

end Behavioral;

