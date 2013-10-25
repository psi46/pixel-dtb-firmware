-- Shifter.vhd
-- Function: Shifts which data is sampled by aligning signal to sample in the 
--					middle of a clock cycle.
-- David Gier
-- PSI, PIRE Program, University of Kansas
-- 24/6/2013

library IEEE;                           
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;                     


entity shifter is
    Port ( CurrentSample: in STD_LOGIC_VECTOR(2 downto 0);
			  Early : in  STD_LOGIC;
           Late : in  STD_LOGIC;
           SelectSample : out  STD_LOGIC_VECTOR(2 downto 0);
			  ShiftRight: out STD_LOGIC;
			  ShiftLeft: out STD_LOGIC;
			  Shifter_Error: out STD_LOGIC);
end shifter;

architecture Behavioral of shifter is



begin

Shift:Process(Early, Late, CurrentSample)

begin
	IF (Early = '1' AND Late = '1') THEN
		Shifter_Error <= '1';
		ShiftRight <= '0';
		ShiftLeft <= '0';
		SelectSample <= CurrentSample;
	ELSIF (Early = '1') THEN
		ShiftRight <= '1';
		ShiftLeft <= '0';
		Shifter_Error <= '0';
		SelectSample <= std_logic_vector((signed(CurrentSample) + 1) mod 8);
	ELSIF (Late = '1') THEN
		ShiftRight <= '0';
		ShiftLeft <= '1';
		Shifter_Error <= '0';
		SelectSample <= std_logic_vector((signed(CurrentSample) - 1) mod 8);
	ELSE 
		ShiftRight <= '0';
		ShiftLeft <= '0';
		Shifter_Error <= '0';
		SelectSample <= CurrentSample;
	END IF;
	
End Process Shift;

end behavioral;
