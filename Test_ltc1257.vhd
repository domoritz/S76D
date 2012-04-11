----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:53:18 09/09/2011 
-- Design Name: 
-- Module Name:    Test_ltc1257 - Behavioral 
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

entity Test_ltc1257 is Port (
	DACDATA : out STD_LOGIC;
	DACLOAD : out STD_LOGIC;
	DACCLOCK : out STD_LOGIC;
	CLOCK : in STD_LOGIC
);
end Test_ltc1257;


architecture Behavioral of Test_ltc1257 is

--    Port ( tone : in  STD_LOGIC_VECTOR (5 downto 0);
--			  clk : in STD_LOGIC;
--           audio : out  STD_LOGIC

signal OUTPUT : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal OUTPUTBIT : STD_LOGIC := '0';
signal TONECODE : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');

begin

synthesizer : entity Work.Synthesizer Port Map (
	clk => CLOCK,
	tone => TONECODE,
	audio => OUTPUTBIT
);

ltc1257 : entity Work.ltc1257 Port Map (
	chipclk => CLOCK,
	ic_data => DACDATA,
	ic_load => DACLOAD,
	ic_clk => DACCLOCK,
	load => '1',
	dacdata => OUTPUT
);

OUTPUT <= (others => OUTPUTBIT);
TONECODE <= "000001";

end Behavioral;

