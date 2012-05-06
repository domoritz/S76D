--------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Dominik Moritz, Kai Fabian
--
-- Create Date:   10:45:12 09/12/2011
-- Design Name:   
-- Module Name:   Testbench_mmccontroller.vhd
-- Project Name:  S76D
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MMCController
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
 
ENTITY Testbench_mmccontroller IS
END Testbench_mmccontroller;
 
ARCHITECTURE behavior OF Testbench_mmccontroller IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MMCController
    PORT(
         clk : IN  std_logic;
         mmc_cs : OUT  std_logic;
         mmc_miso : IN  std_logic;
         mmc_mosi : OUT  std_logic;
         mmc_clock : OUT  std_logic;
         led_out : OUT  std_logic_vector(7 downto 0);
         reset : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal mmc_miso : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal mmc_cs : std_logic;
   signal mmc_mosi : std_logic;
   signal mmc_clock : std_logic;
   signal led_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MMCController PORT MAP (
          clk => clk,
          mmc_cs => mmc_cs,
          mmc_miso => mmc_miso,
          mmc_mosi => mmc_mosi,
          mmc_clock => mmc_clock,
          led_out => led_out,
          reset => reset
        );

   -- Clock process definitions
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
      wait for 100 ns;
		
		wait for 600 us;
		mmc_miso <= '1';
		
		wait for 430 us;
		
		mmc_miso <= '0';		
		wait for 5 us;
		mmc_miso <= '1';

      wait;
   end process;

END;
