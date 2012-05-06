----------------------------------------------------------------------------------
-- Company:    High Professional Inventions (HPI)
-- Engineer:   Dr. Fritz Walther
-- 
-- Create Date:    10:01:27 07/08/2011 
-- Design Name:    Clock divisor
-- Module Name:    ClockDivisor - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: allgemeiner Taktteiler
--
-- Dependencies: keine
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

entity ClockDivisor is
    Port (
			  div    : in INTEGER range 1 to 50000000;
           refclk : in STD_LOGIC;
           outclk : out STD_LOGIC);
end ClockDivisor;

architecture Behavioral of ClockDivisor is

	signal zaehler : INTEGER;

begin

	zaehle : process	( refclk, zaehler )
	begin
		if refclk = '1' and refclk'event then
			if zaehler = 0 or zaehler >= div then
				outclk <= '1';
				zaehler <= div - 1;
			else
				outclk <= '0';
				zaehler <= zaehler - 1;
			end if;
		end if;
	end process zaehle;

end Behavioral;

