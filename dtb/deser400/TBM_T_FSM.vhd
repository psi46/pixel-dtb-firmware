

library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity TBM_T_FSM is
   port (clk_i :         in   std_logic;
         reset_i :       in   std_logic;
         TBM_T_start_i :   in   std_logic;
         serdat_i:		 in   std_logic;
         payload_o :     out  std_logic_vector(3 downto 0);
         type_o :        out  std_logic_vector(3 downto 0);
         wen_o :         out  std_logic);
end TBM_T_FSM;




architecture rtl of TBM_T_FSM is

  type t_state is (waiting,
                   tick_NTP,
                   tick_RTB,
 				   tick_RER,
                   tick_SER,
				   tick_STR,
				   tick_CTC,
				   tick_CAL,
				   tick_STF,
				   tick_DI1,
				   tick_DI0,
				   tick_D5,
				   tick_D4,
				   tick_D3,
				   tick_D2,
				   tick_D1,
				   tick_D0);

 signal s_state : t_state;
 
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
      when tick_NTP =>
           wen_o <= '0';
           payload_o(3)<=serdat_i;
           s_state <= tick_RTB;  
      -------------------------------------------------------------------------
       when tick_RTB =>
        payload_o(2)<=serdat_i;
        s_state <= tick_RER ;
      -------------------------------------------------------------------------
      when tick_RER =>
        payload_o(1)<=serdat_i;
        s_state <= tick_SER ;
      -------------------------------------------------------------------------
	   when tick_SER =>
        payload_o(0)<=serdat_i;
        type_o <= "1100";
        wen_o <= '1';
        s_state <= tick_STR ;
      -------------------------------------------------------------------------
      when tick_STR =>
        payload_o(3)<=serdat_i;
        wen_o <= '0';
        s_state <= tick_CTC ;
      -------------------------------------------------------------------------
 	  when tick_CTC =>
 	    
        payload_o(2)<=serdat_i;
        s_state <= tick_CAL ;
      -------------------------------------------------------------------------
	  when tick_CAL =>
        payload_o(1)<=serdat_i;
        s_state <= tick_STF ;
      -------------------------------------------------------------------------
      -------------------------------------------------------------------------
	   when tick_STF =>
        payload_o(0)<=serdat_i;
         type_o <= "1101";
        wen_o <= '1';
        s_state <= tick_DI1 ;
      -------------------------------------------------------------------------
	   when tick_DI1 =>
        payload_o(3)<=serdat_i;
        wen_o <= '0';
        s_state <= tick_DI0 ;
      -------------------------------------------------------------------------
	   when tick_DI0 =>
	   
	    payload_o(2)<=serdat_i;
        s_state <= tick_D5 ;
      -------------------------------------------------------------------------
       when tick_D5 =>
        payload_o(1)<=serdat_i;
        s_state <= tick_D4 ;
      -------------------------------------------------------------------------
       when tick_D4 =>
        payload_o(0)<=serdat_i;
         type_o <= "1110";
        wen_o <= '1';
        s_state <= tick_D3 ;
      -------------------------------------------------------------------------
      when tick_D3 =>
        payload_o(3)<=serdat_i;
        wen_o <= '0';
        s_state <= tick_D2 ;
      -------------------------------------------------------------------------
     when tick_D2 =>
        payload_o(2)<=serdat_i;
        s_state <= tick_D1 ;
      -------------------------------------------------------------------------
      when tick_D1 =>
        payload_o(1)<=serdat_i;
        s_state <= tick_D0 ;
      -------------------------------------------------------------------------
 when tick_D0 =>
        payload_o(0)<=serdat_i;
         type_o <= "1111";
        wen_o <= '1';
        s_state <= waiting ;
      -------------------------------------------------------------------------
      
      when others =>
        if TBM_T_start_i = '1' then
          wen_o <= '0';
          s_state <= tick_NTP;
          
         else
           wen_o <= '0';
           s_state <= waiting;
        end if; 
        
        
    end case;
  end if;
end process p_format;



end rtl;
