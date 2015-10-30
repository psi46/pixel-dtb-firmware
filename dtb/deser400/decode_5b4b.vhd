library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity DECODE_5b4b is
   port (IN_5b_i :       in   std_logic_vector(4 downto 0) ;
         clk:         in std_logic;
         OUT_4b_o :       out  std_logic_vector(3 downto 0) );
end DECODE_5b4b;

architecture Behaviorial of DECODE_5b4b is

signal q_4b: std_logic_vector(3 downto 0);

begin

q_4b <= "0000" when IN_5b_i ="11110" else
				"0001" when IN_5b_i ="01001" else
				"0010" when IN_5b_i ="10100" else
				"0011" when IN_5b_i ="10101" else
				"0100" when IN_5b_i ="01010" else
				"0101" when IN_5b_i ="01011" else
				"0110" when IN_5b_i ="01110" else
				"0111" when IN_5b_i ="01111" else
				"1000" when IN_5b_i ="10010" else
				"1001" when IN_5b_i ="10011" else
				"1010" when IN_5b_i ="10110" else
				"1011" when IN_5b_i ="10111" else
				"1100" when IN_5b_i ="11010" else
				"1101" when IN_5b_i ="11011" else
				"1110" when IN_5b_i ="11100" else
				"1111" when IN_5b_i ="11101" else
				"0000";
                               

process (clk)
begin
	if (rising_edge(clk)) then
	
	OUT_4b_o<=q_4b;
                               
		
	end if;
end process;


	  

end Behaviorial;
  
    
		
    
    