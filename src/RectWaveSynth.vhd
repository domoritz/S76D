----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:36:14 07/14/2011 
-- Design Name: 
-- Module Name:    RectWaveSynth - Behavioral 
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

entity RectWaveSynth is
    Port ( tone : in  STD_LOGIC_VECTOR (5 downto 0);
			  clk : in STD_LOGIC;
           audio : out  STD_LOGIC);
end RectWaveSynth;

architecture Behavioral of RectWaveSynth is

signal clkDiv : Integer range 0 to 2500000 := 56818;
signal newClkDiv : Integer range 0 to 2500000 := 56818;
signal innerClk : STD_LOGIC := '0';
signal audioOut : STD_LOGIC := '0';
signal disable : STD_LOGIC := '1';

begin

audioteiler : entity Work.ClockDivisor Port Map (clkDiv, clk, innerClk);
	
	ToneGenerator : process (innerClk, clk, disable)
	begin
		if disable = '1' then
			audioOut <= '0';
		else
			if clk = '1' and clk'event then
				clkDiv <= newClkDiv;
			end if;
			if innerClk = '1' and innerClk'event then
				audioOut <= not audioOut;
			end if;
		end if;
	end process ToneGenerator;
	
	ToneOutput : process (audioOut)
	begin
				audio <= audioOut;
	end process ToneOutput;
	
	DetermineDivisor : process (tone, clk)
	begin

		if clk = '1' and clk'event then

if tone = "000000" then
        disable <= '1';
        newClkDiv <= 2;

elsif tone = "000001" then -- Tone: A0
        disable <= '0';
        newClkDiv <= 113636;

elsif tone = "000010" then -- Tone: AIS0
        disable <= '0';
        newClkDiv <= 107258;

elsif tone = "000011" then -- Tone: H0
        disable <= '0';
        newClkDiv <= 101238;

elsif tone = "000100" then -- Tone: C1
        disable <= '0';
        newClkDiv <= 95556;

elsif tone = "000101" then -- Tone: CIS1
        disable <= '0';
        newClkDiv <= 90193;

elsif tone = "000110" then -- Tone: D1
        disable <= '0';
        newClkDiv <= 85131;

elsif tone = "000111" then -- Tone: DIS1
        disable <= '0';
        newClkDiv <= 80353;

elsif tone = "001000" then -- Tone: E1
        disable <= '0';
        newClkDiv <= 75843;

elsif tone = "001001" then -- Tone: F1
        disable <= '0';
        newClkDiv <= 71586;

elsif tone = "001010" then -- Tone: FIS1
        disable <= '0';
        newClkDiv <= 67568;

elsif tone = "001011" then -- Tone: G1
        disable <= '0';
        newClkDiv <= 63776;

elsif tone = "001100" then -- Tone: GIS1
        disable <= '0';
        newClkDiv <= 60196;

elsif tone = "001101" then -- Tone: A1
        disable <= '0';
        newClkDiv <= 56818;

elsif tone = "001110" then -- Tone: AIS1
        disable <= '0';
        newClkDiv <= 53629;

elsif tone = "001111" then -- Tone: H1
        disable <= '0';
        newClkDiv <= 50619;

elsif tone = "010000" then -- Tone: C2
        disable <= '0';
        newClkDiv <= 47778;

elsif tone = "010001" then -- Tone: CIS2
        disable <= '0';
        newClkDiv <= 45096;

elsif tone = "010010" then -- Tone: D2
        disable <= '0';
        newClkDiv <= 42565;

elsif tone = "010011" then -- Tone: DIS2
        disable <= '0';
        newClkDiv <= 40176;

elsif tone = "010100" then -- Tone: E2
        disable <= '0';
        newClkDiv <= 37921;

elsif tone = "010101" then -- Tone: F2
        disable <= '0';
        newClkDiv <= 35793;

elsif tone = "010110" then -- Tone: FIS2
        disable <= '0';
        newClkDiv <= 33784;

elsif tone = "010111" then -- Tone: G2
        disable <= '0';
        newClkDiv <= 31888;

elsif tone = "011000" then -- Tone: GIS2
        disable <= '0';
        newClkDiv <= 30098;

elsif tone = "011001" then -- Tone: A2
        disable <= '0';
        newClkDiv <= 28409;

elsif tone = "011010" then -- Tone: AIS2
        disable <= '0';
        newClkDiv <= 26814;

elsif tone = "011011" then -- Tone: H2
        disable <= '0';
        newClkDiv <= 25309;

elsif tone = "011100" then -- Tone: C3
        disable <= '0';
        newClkDiv <= 23889;

else
        disable <= '1';
        newClkDiv <= 2;
end if;

		end if;

	end process DetermineDivisor;

end Behavioral;

