--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:28:18 09/09/2011
-- Design Name:   
-- Module Name:   F:/DropboxVHDL/S76D/Testbench_ltc1257.vhd
-- Project Name:  S76D
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ltc1257
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
 
ENTITY Testbench_ltc1257 IS
END Testbench_ltc1257;
 
ARCHITECTURE behavior OF Testbench_ltc1257 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ltc1257
    PORT(
         chipclk : IN  std_logic;
         dacdata : IN  std_logic_vector(11 downto 0);
         load : IN  std_logic;
         ready : OUT  std_logic;
         ic_load : OUT  std_logic;
         ic_clk : OUT  std_logic;
         ic_data : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal chipclk : std_logic := '0';
   signal dacdata : std_logic_vector(11 downto 0) := (others => '0');
   signal load : std_logic := '0';

 	--Outputs
   signal ready : std_logic;
   signal ic_load : std_logic;
   signal ic_clk : std_logic;
   signal ic_data : std_logic;

   -- Clock period definitions
   constant chipclk_period : time := 10 ns;
   constant ic_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ltc1257 PORT MAP (
          chipclk => chipclk,
          dacdata => dacdata,
          load => load,
          ready => ready,
          ic_load => ic_load,
          ic_clk => ic_clk,
          ic_data => ic_data
        );

   -- Clock process definitions
   chipclk_process :process
   begin
		chipclk <= '0';
		wait for chipclk_period/2;
		chipclk <= '1';
		wait for chipclk_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for chipclk_period*10;

      -- insert stimulus here 
		
		dacdata <= "101001011001";
		load <= '1';
		
		wait for 20 ns;
		
		load <= '0';

      wait;
   end process;

END;
