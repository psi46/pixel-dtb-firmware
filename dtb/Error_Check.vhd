-- Error_Check.vhd
-- Function: Makes sure that the selected address isn't nearing the edge 
--					of possible samples
-- David Gier
-- PSI, PIRE Program, University of Kansas
-- 24/6/2013

library IEEE;                           
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;                     


entity error_Check is
    Port ( Address : in STD_logic_vector(4 downto 0);	
				Error : out std_logic);
end error_Check;

architecture Behavioral of error_Check is

begin

Error_Check:Process(Address)

begin
	IF (Address = "10000" OR Address = "01111") THEN
		Error <= '1';
	ELSE
		Error <= '0';
	END IF;
	
End Process Error_Check;

end behavioral;
