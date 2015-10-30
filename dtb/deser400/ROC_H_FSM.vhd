

library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity ROC_H_FSM is
   port (clk_i :         in   std_logic;
         reset_i :       in   std_logic;
         ROC_start_i :   in   std_logic;
         serdat_i :      in   std_logic;
         payload_o :     out  std_logic_vector(3 downto 0);
         type_o :        out  std_logic_vector(3 downto 0);
         wen_o :         out  std_logic);
end ROC_H_FSM;




architecture rtl of ROC_H_FSM is

  type t_state is (waiting,
                   tick_RB3,
                   tick_RB2,
 				   tick_RB1,
                   tick_RB0);

 signal s_state : t_state;
  --signal s_count : unsigned(3 downto 0);
 
begin     



p_format: process (clk_i, reset_i)
begin  -- process p_serin
  if (reset_i = '1') then               -- asynchronous reset 
    wen_o <= '0';
    payload_o <= "0000";
    type_o <= "0000";
    s_state <= waiting;
    
  elsif rising_edge(clk_i) then  -- rising clock edge
    case s_state is
      -------------------------------------------------------------------------
      when tick_RB3 =>
           wen_o <= '0';
           payload_o(3)<=serdat_i;
           s_state <= tick_RB2;  
      -------------------------------------------------------------------------
      when tick_RB2 =>
           payload_o(2)<=serdat_i;
           s_state <= tick_RB1;  
      -------------------------------------------------------------------------
	   when tick_RB1 =>
           payload_o(1)<=serdat_i;
           s_state <= tick_RB0;  
      -------------------------------------------------------------------------
      when tick_RB0 =>
        payload_o(0)<=serdat_i;
        type_o <= "0111";
        wen_o <= '1';
 
        s_state <= waiting ;
      -------------------------------------------------------------------------
      -------------------------------------------------------------------------
	
      
      when others =>
        if ROC_start_i = '1' then
          wen_o <= '0';
          payload_o <= "0000";
          s_state <= tick_RB3;
          
         else
           wen_o <= '0';
           s_state <= waiting;
        end if; 
        
        
    end case;
  end if;
end process p_format;



end rtl;
