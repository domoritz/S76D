--------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Dominik Moritz, Kai Fabian
--
-- Create Date:   13:34:35 07/15/2011
-- Design Name:   
-- Module Name:   Testbench_KeyboardController.vhd
-- Project Name:  VHDLProjekt
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: KbEingabe
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY Testbench_KeyboardController IS
END Testbench_KeyboardController;
 
ARCHITECTURE behavior OF Testbench_KeyboardController IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT KeyboardController
    PORT(
         kbclk : IN  std_logic;
         kbdata : IN  std_logic;
         reset : IN  std_logic;
         clk : IN  std_logic;
         scancode : OUT  std_logic_vector(7 downto 0);
			break : OUT std_logic;
			extend : OUT std_logic;
         ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal kbclk : std_logic := '0';
   signal kbdata : std_logic := '0';
   signal reset : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal scancode : std_logic_vector(7 downto 0);
   signal ready : std_logic;
   signal break : std_logic;
   signal extend : std_logic;

   -- Clock period definitions
   constant kbclk_period : time := 10 ns;
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: KeyboardController PORT MAP (
          kbclk => kbclk,
          kbdata => kbdata,
          reset => reset,
          clk => clk,
          scancode => scancode,
			 break => break,
			 extend => extend,
          ready => ready
        );

   -- Clock process definitions
--   kbclk_process :process
--   begin
--		kbclk <= '0';
--		wait for kbclk_period/2;
--		kbclk <= '1';
--		wait for kbclk_period/2;
--   end process;
 
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 20 us;	

      kbclk <= '1';
		
		wait for 100ns;
		
		-- send char STARTBIT = 0
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char D0
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char: ODD PARITY
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char: STOPBIT
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 50ns;
		
		
		
		
		
		-- send char STARTBIT = 0
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char D0
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char: ODD PARITY
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char: STOPBIT
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 50ns;
		
		
		
		
		
		-- send char STARTBIT = 0
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char D0
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char: ODD PARITY
		kbdata <= '0';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 10ns;
		
		-- send char: STOPBIT
		kbdata <= '1';
		wait for 10ns;
		
		kbclk <= '0';
		wait for 10us;
		
		kbclk <= '1';
		wait for 50ns;
		
		
		
		
		
      wait;
   end process;

END;
