----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:32:29 07/08/2011 
-- Design Name: 
-- Module Name:    KeyboardInput - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Input module for keyboard
--
-- Dependencies: none
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: untested!
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

entity KeyboardInput is
    Port ( kbclk : in  STD_LOGIC;
           kbdata : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           scancode : out  STD_LOGIC_VECTOR (7 downto 0);
           ready : out  STD_LOGIC);
end KeyboardInput;

architecture Behavioral of KeyboardInput is
	-- keyboard clock
	signal qclk : STD_LOGIC_VECTOR(1 downto 0);
	signal dclk : STD_LOGIC_VECTOR(1 downto 0);
	
	-- scan code
	signal qscan : STD_LOGIC_VECTOR(10 downto 0);
	signal dscan : STD_LOGIC_VECTOR(10 downto 0);
	
	-- signale zwischen opw und stw
	signal X 	: STD_LOGIC_VECTOR(1 downto 0);
	signal Y 	: STD_LOGIC_VECTOR(1 downto 0);

begin

opw : process(clk,reset,kbclk,qclk,Y,qscan,kbdata)
begin
	-- flankenfaenger
	dclk <= kbclk & qclk(1);
	X(0) <= (not qclk(1)) and qclk(0);
	
	-- shifter
	case Y is
		when "00" =>
			-- halten
			dscan <= qscan;
		when "10" =>
			-- reinshiften
			dscan <= kbdata & qscan(10 downto 1); --qscan(9 downto 0) & kbdata;
		when others => -- auch u. v. a. "01"
			-- reset, init
			dscan <= "11111111111";
--		when others =>
--			dscan <= dscan;
	end case;
	
	-- erkenner
	if qscan(0) = '0' then
		-- sobald ganz rechts die 0 angekommen ist, ist der gesamte code drin
		X(1) <= '1';
	else
		X(1) <= '0';
	end if;
	
	-- ausgabe
	scancode <= qscan(8 downto 1);
	-- scancode <= qscan(2 to 9);
	
	-- hier alles, was mit dem takt zu tun hat (register)
	if reset = '1' then
		qclk <= kbclk & kbclk;
		qscan <= "11111111111";
		X(1) <= '0';
	elsif clk = '1' and clk'event then
		qclk <= dclk;
		qscan <= dscan;
	else
		qscan <= qscan;
	end if;
	
end process opw;

stw : process (X)
begin
	Y(0) <= X(1); -- reset, init bei ready
	Y(1) <= X(0); -- shiften bei kbclk
	ready <= X(1); -- X(1) = ready signal
end process stw;

end Behavioral;

