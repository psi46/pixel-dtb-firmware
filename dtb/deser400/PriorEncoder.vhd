library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity PriorEncode is
   port (IN_Xor :       in   std_logic_vector(7 downto 0) ;
         OUT_sel :       out  std_logic_vector(2 downto 0) );
end PriorEncode;

architecture Behaviorial of PriorEncode is

begin

	OUT_sel <= "000" when IN_Xor ="00000001" else
	           "001" when IN_Xor ="00000010" else
	           "010" when IN_Xor ="00000100" else
	           "011" when IN_Xor ="00001000" else
	           "100" when IN_Xor ="00010000" else
	           "101" when IN_Xor ="00100000" else
	           "110" when IN_Xor ="01000000" else
	           "111" when IN_Xor ="10000000" ;
	                        

end Behaviorial;
  
    
		
    
    