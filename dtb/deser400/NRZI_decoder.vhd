
library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity NRZI_decoder is
   port (clk: 	 	in  std_logic;
		 reset: 	in  std_logic;
		 enable: 	in  std_logic;
		 IN_NRZI_i :in  std_logic_vector(4 downto 0);
		 LastBit_i :in  std_logic;
         OUT_5b_o :out  std_logic_vector(4 downto 0); 
		 error:    out  std_logic);
end NRZI_decoder;

architecture Behaviorial of NRZI_decoder is

begin



process (clk, reset)
begin
	
	if (reset = '1') then
		OUT_5b_o <= "00000";
	
	elsif (rising_edge(clk)) then
		if (enable = '1') then
		
		 case LastBit_i is
		
		  when '0' =>
		       if IN_NRZI_i = "10100" then OUT_5b_o <= "11110"; error <= '0';			
			elsif IN_NRZI_i = "01110" then OUT_5b_o <= "01001"; error <= '0';
			elsif IN_NRZI_i = "11000" then OUT_5b_o <= "10100"; error <= '0';
			elsif IN_NRZI_i = "11001" then OUT_5b_o <= "10101"; error <= '0';
		    elsif IN_NRZI_i = "01100" then OUT_5b_o <= "01010"; error <= '0';
			elsif IN_NRZI_i = "01101" then OUT_5b_o <= "01011"; error <= '0';
			elsif IN_NRZI_i = "01011" then OUT_5b_o <= "01110"; error <= '0';
			elsif IN_NRZI_i = "01010" then OUT_5b_o <= "01111"; error <= '0';
			elsif IN_NRZI_i = "11100" then OUT_5b_o <= "10010"; error <= '0';
			elsif IN_NRZI_i = "11101" then OUT_5b_o <= "10011"; error <= '0';
			elsif IN_NRZI_i = "11011" then OUT_5b_o <= "10110"; error <= '0';				
		    elsif IN_NRZI_i = "11010" then OUT_5b_o <= "10111"; error <= '0';				
			elsif IN_NRZI_i = "10011" then OUT_5b_o <= "11010"; error <= '0';				
			elsif IN_NRZI_i = "10010" then OUT_5b_o <= "11011"; error <= '0';
			elsif IN_NRZI_i = "10111" then OUT_5b_o <= "11100"; error <= '0';				
			elsif IN_NRZI_i = "10110" then OUT_5b_o <= "11101"; error <= '0';
			elsif IN_NRZI_i = "11111" then OUT_5b_o <= "10110"; error <= '0';
			 else error	<= '1'; end if;
				
		 when '1' => 
			   if IN_NRZI_i = "01011" then OUT_5b_o <= "11110"; error <= '0';
			elsif IN_NRZI_i = "10001" then OUT_5b_o <= "01001"; error <= '0';
			elsif IN_NRZI_i = "00111" then OUT_5b_o <= "10100"; error <= '0';
			elsif IN_NRZI_i = "00110" then OUT_5b_o <= "10101"; error <= '0';
			elsif IN_NRZI_i = "10011" then OUT_5b_o <= "01010"; error <= '0';
			elsif IN_NRZI_i = "10010" then OUT_5b_o <= "01011"; error <= '0';
			elsif IN_NRZI_i = "10100" then OUT_5b_o <= "01110"; error <= '0';
			elsif IN_NRZI_i = "10101" then OUT_5b_o <= "01111"; error <= '0';
			elsif IN_NRZI_i = "00011" then OUT_5b_o <= "10010"; error <= '0';
			elsif IN_NRZI_i = "00010" then OUT_5b_o <= "10011"; error <= '0';
			elsif IN_NRZI_i = "00100" then OUT_5b_o <= "10110"; error <= '0';					
			elsif IN_NRZI_i = "00101" then OUT_5b_o <= "10111"; error <= '0';				
			elsif IN_NRZI_i = "01100" then OUT_5b_o <= "11010"; error <= '0';					
			elsif IN_NRZI_i = "01101" then OUT_5b_o <= "11011"; error <= '0';
			elsif IN_NRZI_i = "01000" then OUT_5b_o <= "11100"; error <= '0';				
			elsif IN_NRZI_i = "01001" then OUT_5b_o <= "11101"; error <= '0';
			elsif IN_NRZI_i = "00000" then OUT_5b_o <= "10110"; error <= '0';
			 else error	<= '1'; end if;
		
		end case;		
		
		
			
		end if; --enable
	end if;
end process;


end Behaviorial;