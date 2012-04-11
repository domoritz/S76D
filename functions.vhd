--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package functions is

function FourBitToDisp(signal din : in STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR;

-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

end functions;

package body functions is


function FourBitToDisp (signal din : in STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
   variable dout : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	begin
	  case din is
		 when "0000" => dout := "00000011";
		 when "0001" => dout := "10011111";
		 when "0010" => dout := "00100101";
		 when "0011" => dout := "00001101";
		 
		 when "0100" => dout := "10011001";
		 when "0101" => dout := "01001001";
		 when "0110" => dout := "01000001";
		 when "0111" => dout := "00011111";
		 
		 
		 when "1000" => dout := "00000001";
		 when "1001" => dout := "00001001";
		 when "1010" => dout := "00010001";
		 when "1011" => dout := "11000001";
		 
		 when "1100" => dout := "01100011";
		 when "1101" => dout := "10000101";
		 when "1110" => dout := "01100001";
		 when "1111" => dout := "01110001";
		 
		 when others => dout := "11111110";
	  end case;
	  
	  return dout;
	end FourBitToDisp;
	
---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end functions;
