library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity demux_4to2 is
   port (
			input_ab  :       in   std_logic_vector(3 downto 0) ;
			ena		 :			in	  std_logic ;			
         output_a  :       out  std_logic_vector(1 downto 0) ;
			output_b  :       out  std_logic_vector(1 downto 0)
			);
end demux_4to2;

architecture Behaviorial of demux_4to2 is
begin
	output_a(1) <= ena and input_ab(3);
	output_a(0) <= ena and input_ab(1);
	output_b(1) <= ena and not input_ab(2);
	output_b(0) <= ena and not input_ab(0);
end Behaviorial;   
    