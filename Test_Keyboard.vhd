----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:33:50 09/09/2011 
-- Design Name: 
-- Module Name:    Test_Keyboard - Behavioral 
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

entity Test_Keyboard is
    Port ( PS2D : in  STD_LOGIC;
           PS2C : in  STD_LOGIC;
			  RESET : in STD_LOGIC;
			  CLOCK : in STD_LOGIC;
           LEDS : out  STD_LOGIC_VECTOR (7 downto 0));
end Test_Keyboard;

architecture Behavioral of Test_Keyboard is

signal scancode : STD_LOGIC_VECTOR (7 downto 0);
signal break : STD_LOGIC;
signal extend : STD_LOGIC;
signal ready : STD_LOGIC;

begin

--Keyboard : entity Work.KeyboardInput Port Map (
--	kbdata => PS2D,
--	kbclk => PS2C,
--	reset => RESET,
--	clk => CLOCK,
--	scancode => scancode,
--	ready => ready
--);

Keyboard : entity Work.KeyboardController Port Map (
	kbdata => PS2D,
	kbclk => PS2C,
	reset => RESET,
	clk => CLOCK,
	scancode => scancode,
	break => break,
	extend => extend,
	ready => ready
);

Display_Test : Process (CLOCK)
begin

	if rising_edge(ready) then
		if break = '1' then
			LEDS <= (others => '0');
		else
			LEDS <= scancode;
		end if;
	end if;

end process Display_Test;

end Behavioral;

