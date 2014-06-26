library IEEE;
use IEEE.std_logic_1164.all;
 
entity frame_det is port(
I1st: in std_logic;
I2nd: in std_logic;
I3rd: in std_logic;
I4th: in std_logic;
I5th: in std_logic;
I6th: in std_logic;
Q5xf: out std_logic;
Q6xf: out std_logic);
end frame_det;
 
architecture behav of frame_det is
 
begin
Q5xf <= ((I5th and I4th and I3rd and I2nd and I1st) or (not(I5th or I4th or I3rd or I2nd or I1st)));
Q6xf <= not(I6th or I5th or I4th or I3rd or I2nd or I1st); 
 
end behav;