

library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity blockPHfinding is
   port (clk_i :         in   std_logic;
         reset_i :       in   std_logic;
         framing_i :     in   std_logic;
         
         block_o :         out  std_logic);
end blockPHfinding;




architecture rtl of blockPHfinding is

  type t_state is (waiting,
                   tick1,
 				   tick2,
				   tick3,
				   tick4);

 signal s_state : t_state;
 
begin     



p_monoflop: process (clk_i, reset_i)
begin  -- process p_serin
  if (reset_i = '1') then               -- asynchronous reset 
    block_o <= '0';
    s_state <= waiting;
    
  elsif rising_edge(clk_i) then  -- rising clock edge
    case s_state is
      -------------------------------------------------------------------------
      when tick1 =>
        block_o <= '1';
        s_state <= tick2 ;
      -------------------------------------------------------------------------
       when tick2 =>
        block_o <= '1';
        s_state <= tick3 ;
      -------------------------------------------------------------------------
       when tick3 =>
        block_o <= '1';
        s_state <= tick4 ;
      -------------------------------------------------------------------------
       when tick4 =>
        block_o <= '1';
        s_state <= waiting ;
      -------------------------------------------------------------------------
	  
      -------------------------------------------------------------------------
      
      when others =>
        if framing_i = '1' then
          
          s_state <= tick1;
          
         else
          block_o <= '0';
           s_state <= waiting;
        end if; 
        
        
    end case;
  end if;
end process p_monoflop;



end rtl;
