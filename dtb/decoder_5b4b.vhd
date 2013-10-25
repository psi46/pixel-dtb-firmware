library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity decoder_5b4b is
   port (input_5b  :       in   std_logic_vector(4 downto 0) ;
         output_4b :       out  std_logic_vector(3 downto 0) ;
			error		 :			out  std_logic
			);
end decoder_5b4b;

architecture Behaviorial of decoder_5b4b is

begin

	process(input_5b)
	begin
	
		case input_5b is
			when "11110" => output_4b <= "0000"; error <= '0';
			when "01001" => output_4b <= "0001"; error <= '0';
			when "10100" => output_4b <= "0010"; error <= '0';
			when "10101" => output_4b <= "0011"; error <= '0';
			when "01010" => output_4b <= "0100"; error <= '0';
			when "01011" => output_4b <= "0101"; error <= '0';
			when "01110" => output_4b <= "0110"; error <= '0';
			when "01111" => output_4b <= "0111"; error <= '0';
			when "10010" => output_4b <= "1000"; error <= '0';
			when "10011" => output_4b <= "1001"; error <= '0';
			when "10110" => output_4b <= "1010"; error <= '0';
			when "10111" => output_4b <= "1011"; error <= '0';
			when "11010" => output_4b <= "1100"; error <= '0';
			when "11011" => output_4b <= "1101"; error <= '0';
			when "11100" => output_4b <= "1110"; error <= '0';
			when "11101" => output_4b <= "1111"; error <= '0';
			when others	 => output_4b <= "0000"; error <= '1';
		end case;
		
	end process;

end Behaviorial;   
    