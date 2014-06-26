

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
                   tick_X1,
                   tick_EW7,
 				   tick_EW6,
                   tick_X2,
				   tick_EW5,
				   tick_EW4,
				   tick_EW3,
				   tick_EW2,
				   tick_X3,
				   tick_EW1,
				   tick_EW0,
				   tick_X4);

 signal s_state : t_state;
 signal s_payload : std_logic_vector(7 downto 0);--unsigned(3 downto 0);
 
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
      when tick_X1 =>
           wen_o <= '0';
           s_state <= tick_EW7;  
      -------------------------------------------------------------------------
      when tick_EW7 =>
        s_payload(7)<=serdat_i;
        s_state <= tick_EW6 ;
      -------------------------------------------------------------------------
	   when tick_EW6 =>
        s_payload(6)<=serdat_i;
        s_state <= tick_X2 ;
      -------------------------------------------------------------------------
      when tick_X2 =>
        s_state <= tick_EW5 ;
      -------------------------------------------------------------------------
 	  when tick_EW5 =>
        s_payload(5)<=serdat_i;
        s_state <= tick_EW4 ;
      -------------------------------------------------------------------------
	  when tick_EW4 =>
        s_payload(4)<=serdat_i;
        s_state <= tick_EW3 ;
      -------------------------------------------------------------------------
      -------------------------------------------------------------------------
	   when tick_EW3 =>
        s_payload(3)<=serdat_i;
        s_state <= tick_EW2 ;
      -------------------------------------------------------------------------
	   when tick_EW2 =>
        s_payload(2)<=serdat_i;
        payload_o(3)<=s_payload(7);
        payload_o(2)<=s_payload(6);
        payload_o(1)<=s_payload(5);
        payload_o(0)<=s_payload(4);
        wen_o <= '1';
        type_o <= "1011";
        s_state <= tick_X3 ;
      -------------------------------------------------------------------------
	   when tick_X3 =>
	    wen_o <= '0';
        s_state <= tick_EW1 ;
      -------------------------------------------------------------------------
       when tick_EW1 =>
        s_payload(1)<=serdat_i;
        s_state <= tick_EW0 ;
      -------------------------------------------------------------------------
       when tick_EW0 =>
        s_payload(0)<=serdat_i;
        s_state <= tick_X4 ;
      -------------------------------------------------------------------------
      -------------------------------------------------------------------------
       when tick_X4 =>
        payload_o(3)<=s_payload(3);
        payload_o(2)<=s_payload(2);
        payload_o(1)<=s_payload(1);
        payload_o(0)<=s_payload(0);
        wen_o <= '1';
        type_o <= "1100";
       
        s_state <= waiting ;
      -------------------------------------------------------------------------
      
      when others =>
        if TBM_T_start_i = '1' then
          wen_o <= '0';
          s_state <= tick_X1;
          
         else
           wen_o <= '0';
           s_state <= waiting;
        end if; 
        
        
    end case;
  end if;
end process p_format;



end rtl;
