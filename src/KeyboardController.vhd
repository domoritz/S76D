-------------------------------------------------------------------------------------
--  _  _    _______  _______          _________          _        _______    _  _  --
-- ( )( )  (  ___  )(  ____ \|\     /|\__   __/|\     /|( (    /|(  ____ \  ( )( ) --
-- | || |  | (   ) || (    \/| )   ( |   ) (   | )   ( ||  \  ( || (    \/  | || | --
-- | || |  | (___) || |      | (___) |   | |   | |   | ||   \ | || |        | || | --
-- | || |  |  ___  || |      |  ___  |   | |   | |   | || (\ \) || | ____   | || | --
-- (_)(_)  | (   ) || |      | (   ) |   | |   | |   | || | \   || | \_  )  (_)(_) --
--  _  _   | )   ( || (____/\| )   ( |   | |   | (___) || )  \  || (___) |   _  _  --
-- (_)(_)  |/     \|(_______/|/     \|   )_(   (_______)|/    )_)(_______)  (_)(_) --
--                                                                                 --
--                                                                                 --
-- evaluate ready on rising_edge!                                                  --
-------------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Dominik Moritz, Kai Fabian
-- 
-- Create Date:    10:39:10 07/15/2011 
-- Design Name: 
-- Module Name:    KeyboardController - Behavioral 
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

entity KeyboardController is Port(
			  debug : out STD_LOGIC_VECTOR(7 downto 0);
			  kbclk : in  STD_LOGIC;
           kbdata : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           scancode : out  STD_LOGIC_VECTOR (7 downto 0);
			  break : out STD_LOGIC;
			  extend : out STD_LOGIC;
           ready : out  STD_LOGIC
	);
end KeyboardController;


architecture Behavioral of KeyboardController is

signal f0cache : STD_LOGIC := '0';
signal e0cache : STD_LOGIC := '0';
signal sccache : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal readyoutcache : STD_LOGIC := '1';

signal f0outcache : STD_LOGIC := '0';
signal e0outcache : STD_LOGIC := '0';
signal scoutcache : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

signal int_kbclk : STD_LOGIC;
signal int_kbdata : STD_LOGIC;
signal int_reset : STD_LOGIC;
signal int_clk : STD_LOGIC;
signal int_scancode : STD_LOGIC_VECTOR (7 downto 0);
signal int_ready : STD_LOGIC;

signal current_scancode_is_f0 : STD_LOGIC;
signal current_scancode_is_e0 : STD_LOGIC;

signal cached_scancode_is_f0 : STD_LOGIC;
signal cached_scancode_is_e0 : STD_LOGIC;

signal do_reset_int : STD_LOGIC;

--entity KeyboardInput is
--    Port ( kbclk : in  STD_LOGIC;
--           kbdata : in  STD_LOGIC;
--           reset : in  STD_LOGIC;
--           clk : in  STD_LOGIC;
--           scancode : out  STD_LOGIC_VECTOR (7 downto 0);
--           ready : out  STD_LOGIC);
--end KeyboardInput;

begin

	eingabe : entity Work.KeyboardInput Port Map (kbclk => int_kbclk, kbdata => int_kbdata, reset => int_reset, clk => int_clk, scancode => int_scancode, ready => int_ready);
	clkdiv : entity Work.ClockDivisor Port Map (4, clk, int_clk);

	int_kbclk <= kbclk;
	int_kbdata <= kbdata;
	int_reset <= reset;
	-- int_clk <= clk;
	
	debug <= int_kbclk & int_kbdata & int_reset & int_clk & "0100";
	
	comparator : Process (int_scancode, sccache)
	begin
		
		if int_scancode = "11110000" then
			current_scancode_is_f0 <= '1';
		else
			current_scancode_is_f0 <= '0';
		end if;
		
		if int_scancode = "11100000" then
			current_scancode_is_e0 <= '1';
		else
			current_scancode_is_e0 <= '0';
		end if;
		
		if sccache = "11110000" then
			cached_scancode_is_f0 <= '1';
		else
			cached_scancode_is_f0 <= '0';
		end if;
		
		if sccache = "11100000" then
			cached_scancode_is_e0 <= '1';
		else
			cached_scancode_is_e0 <= '0';
		end if;
		
	end process comparator;
	
	detection : Process (int_ready, clk, reset, do_reset_int, current_scancode_is_e0, current_scancode_is_f0)
	begin
			
		readyoutcache <= int_ready and not (current_scancode_is_e0 or current_scancode_is_f0);
		
		if reset = '0' and do_reset_int = '0' then
			
			if rising_edge(int_ready) then
				
				if current_scancode_is_f0 = '1' then
					f0cache <= '1';
				elsif current_scancode_is_e0 = '1' then
					e0cache <= '1';
				end if;
				sccache <= int_scancode;
				
				-- f0outcache <= f0outcache;
				
			end if;
			
			if falling_edge(int_ready) then
				
				if not (cached_scancode_is_e0 = '1' or cached_scancode_is_f0 = '1') then
					f0outcache <= f0cache;
					e0outcache <= e0cache;
					scoutcache <= sccache;
					do_reset_int <= '1';
				end if;
				
			end if;
		
		else
			-- RESET
		
--				readyoutcache <= '0';
--				f0outcache <= '0';
--				e0outcache <= '0';
--				scoutcache <= (others => '0');
				
				do_reset_int <= '0';
				f0cache <= '0';
				e0cache <= '0';
				sccache <= (others => '0');
		
		end if;
		
	end process detection;
	
	output : process (int_clk, f0outcache, e0outcache, scoutcache, readyoutcache)
	begin
		
		if falling_edge(int_clk) then
			break <= f0outcache;
			extend <= e0outcache;
			scancode <= scoutcache;
		end if;
		
		if rising_edge(int_clk) then
			ready <= not readyoutcache;
		end if;
		
	end process output;

end Behavioral;

