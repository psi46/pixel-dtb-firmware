library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity PhaseSel is
   port (IN_Xor :       in   std_logic_vector(5 downto 0) ;
         OUT_sel :       out  std_logic_vector(1 downto 0) );
end PhaseSel;

architecture Behaviorial of PhaseSel is

begin
-- 1 => bar
	OUT_sel <= "01" when IN_Xor ="000000" else
	           "01" when IN_Xor ="000001" else
	           "01" when IN_Xor ="000010" else
	           "01" when IN_Xor ="000011" else 
	           "01" when IN_Xor ="000100" else
	           "01" when IN_Xor ="000101" else
	           "01" when IN_Xor ="000110" else
	           "01" when IN_Xor ="000111" else
	           "01" when IN_Xor ="001000" else
	           "01" when IN_Xor ="001001" else
	           "01" when IN_Xor ="001010" else
	           "01" when IN_Xor ="001011" else
	           "01" when IN_Xor ="001100" else
	           "01" when IN_Xor ="001101" else
	           "01" when IN_Xor ="001110" else
	           "01" when IN_Xor ="001111" else
	           "01" when IN_Xor ="010000" else
	           "01" when IN_Xor ="010001" else
	           "01" when IN_Xor ="010010" else
	           "01" when IN_Xor ="010011" else
	           "01" when IN_Xor ="010100" else
	           "01" when IN_Xor ="010101" else
	           "01" when IN_Xor ="010110" else
	           "01" when IN_Xor ="010111" else
	           "01" when IN_Xor ="011000" else
	           "01" when IN_Xor ="011001" else
	           "01" when IN_Xor ="011010" else
	           "01" when IN_Xor ="011011" else
	           "01" when IN_Xor ="011100" else
	           "01" when IN_Xor ="011101" else
	           "01" when IN_Xor ="011110" else
	           "01" when IN_Xor ="011111" else
	           "01" when IN_Xor ="100000" else
	           "10" when IN_Xor ="100001" else --
	           "01" when IN_Xor ="100010" else
	           "00" when IN_Xor ="100011" else
	           "01" when IN_Xor ="100100" else
	           "01" when IN_Xor ="100101" else
	           "01" when IN_Xor ="100110" else
	           "01" when IN_Xor ="100111" else
	           "01" when IN_Xor ="101000" else
	           "01" when IN_Xor ="101001" else
	           "01" when IN_Xor ="101010" else
	           "01" when IN_Xor ="101011" else
	           "01" when IN_Xor ="101100" else
	           "01" when IN_Xor ="101101" else
	           "01" when IN_Xor ="101110" else
	           "01" when IN_Xor ="101111" else
	           "10" when IN_Xor ="110000" else
	           "00" when IN_Xor ="110001" else --
	           "01" when IN_Xor ="110010" else
	           "01" when IN_Xor ="110011" else
	           "01" when IN_Xor ="110100" else
	           "01" when IN_Xor ="110101" else
	           "01" when IN_Xor ="110110" else
	           "01" when IN_Xor ="110111" else
	           "01" when IN_Xor ="111000" else
	           "01" when IN_Xor ="111001" else
	           "01" when IN_Xor ="111010" else
	           "01" when IN_Xor ="111011" else
	           "01" when IN_Xor ="111100" else
	           "01" when IN_Xor ="111101" else
	           "01" when IN_Xor ="111110" else
	           "01" when IN_Xor ="111111" ;
                                 

end Behaviorial;
  
    
		
    
    