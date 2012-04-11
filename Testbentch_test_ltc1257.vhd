--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:54:13 09/09/2011
-- Design Name:   
-- Module Name:   F:/DropboxVHDL/S76D/Testbentch_test_ltc1257.vhd
-- Project Name:  S76D
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ScancodeTonecodeConverter
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
 
ENTITY Testbentch_test_ltc1257 IS
END Testbentch_test_ltc1257;
 
ARCHITECTURE behavior OF Testbentch_test_ltc1257 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ScancodeTonecodeConverter
    PORT(
         scancode : IN  std_logic_vector(7 downto 0);
         tonecode : OUT  std_logic_vector(5 downto 0);
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal scancode : std_logic_vector(7 downto 0) := (others => '0');
   signal clk : std_logic := '0';

 	--Outputs
   signal tonecode : std_logic_vector(5 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ScancodeTonecodeConverter PORT MAP (
          scancode => scancode,
          tonecode => tonecode,
          clk => clk
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

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
