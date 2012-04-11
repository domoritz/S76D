--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:56:01 09/09/2011
-- Design Name:   
-- Module Name:   F:/DropboxVHDL/S76D/Testbench_test_ltc1257.vhd
-- Project Name:  S76D
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Test_ltc1257
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
 
ENTITY Testbench_test_ltc1257 IS
END Testbench_test_ltc1257;
 
ARCHITECTURE behavior OF Testbench_test_ltc1257 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Test_ltc1257
    PORT(
         DACDATA : OUT  std_logic;
         DACLOAD : OUT  std_logic;
         DACCLOCK : OUT  std_logic;
         CLOCK : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLOCK : std_logic := '0';

 	--Outputs
   signal DACDATA : std_logic;
   signal DACLOAD : std_logic;
   signal DACCLOCK : std_logic;

   -- Clock period definitions
   constant DACCLOCK_period : time := 10 ns;
   constant CLOCK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Test_ltc1257 PORT MAP (
          DACDATA => DACDATA,
          DACLOAD => DACLOAD,
          DACCLOCK => DACCLOCK,
          CLOCK => CLOCK
        );

   -- Clock process definitions
 
   CLOCK_process :process
   begin
		CLOCK <= '0';
		wait for CLOCK_period/2;
		CLOCK <= '1';
		wait for CLOCK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for DACCLOCK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
