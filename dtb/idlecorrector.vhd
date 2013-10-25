library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity idlecorrector is
   port (input_5b_u  :       in   std_logic_vector(4 downto 0) ;
         output_5b_c :       out  std_logic_vector(4 downto 0)
			);
end idlecorrector;

architecture Behaviorial of idlecorrector is

begin

	process(input_5b_u)
	begin
		case input_5b_u is
			when "10000" => output_5b_c <= "10110";
			when others => output_5b_c <= input_5b_u;
		end case;
	end process;

end Behaviorial;   
    