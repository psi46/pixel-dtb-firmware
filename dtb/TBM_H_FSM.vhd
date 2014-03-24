

library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity TBM_H_FSM is
   port (clk_i :         in   std_logic;
         reset_i :       in   std_logic;
         TBM_H_start_i :   in   std_logic;
         serdat_i:		 in   std_logic;
         payload_o :     out  std_logic_vector(3 downto 0);
         type_o :        out  std_logic_vector(3 downto 0);
         wen_o :         out  std_logic);
end TBM_H_FSM;




architecture rtl of TBM_H_FSM is

  type t_state is (waiting,
                   tick_EN7,
 				   tick_EN6,
				   tick_EN5,
				   tick_EN4,
				   tick_EN3,
				   tick_EN2,
				   tick_EN1,
				   tick_EN0,
				   tick_STF,
				   tick_PKR,
				   tick_SC5,
				   tick_SC4,
				   tick_SC3,
				   tick_SC2,
				   tick_SC1,
				   tick_SC0);

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
      when tick_EN7 =>
        wen_o <= '0';
        payload_o(3)<=serdat_i;
        s_state <= tick_EN6 ;
      -------------------------------------------------------------------------
	   when tick_EN6 =>
        payload_o(2)<=serdat_i;
        s_state <= tick_EN5 ;
      -------------------------------------------------------------------------
 	  when tick_EN5 =>
        payload_o(1)<=serdat_i;
        s_state <= tick_EN4 ;
      -------------------------------------------------------------------------
	  when tick_EN4 =>
        payload_o(0)<=serdat_i;
        type_o <= "1000";
        wen_o <= '1';
        s_state <= tick_EN3 ;
      -------------------------------------------------------------------------
	   when tick_EN3 =>
        payload_o(3)<=serdat_i;
        wen_o <= '0';
        s_state <= tick_EN2 ;
      -------------------------------------------------------------------------
	   when tick_EN2 =>
        payload_o(2)<=serdat_i;
        s_state <= tick_EN1 ;
      -------------------------------------------------------------------------
       when tick_EN1 =>
        payload_o(1)<=serdat_i;
        s_state <= tick_EN0 ;
      -------------------------------------------------------------------------
       when tick_EN0 =>
        payload_o(0)<=serdat_i;
         type_o <= "1001";
        wen_o <= '1';
        s_state <= tick_STF ;
      -------------------------------------------------------------------------
       when tick_STF =>
        payload_o(3)<=serdat_i;
        wen_o <= '0';
        s_state <= tick_PKR ;
       
       -------------------------------------------------------------------------
 	  when tick_PKR =>
        payload_o(2)<=serdat_i;
        s_state <= tick_SC5 ;
      -------------------------------------------------------------------------
	  when tick_SC5 =>
        payload_o(1)<=serdat_i;
        s_state <= tick_SC4 ;
      -------------------------------------------------------------------------
	   when tick_SC4 =>
        payload_o(0)<=serdat_i;
          type_o <= "1010";
        wen_o <= '1';
        s_state <= tick_SC3 ;
      -------------------------------------------------------------------------
	   when tick_SC3 =>
        payload_o(3)<=serdat_i;
        wen_o <= '0';
        s_state <= tick_SC2 ;
      -------------------------------------------------------------------------
       when tick_SC2 =>
        payload_o(2)<=serdat_i;
        s_state <= tick_SC1 ;
      -------------------------------------------------------------------------
       when tick_SC1 =>
        payload_o(1)<=serdat_i;
        s_state <= tick_SC0 ;
      -------------------------------------------------------------------------
       when tick_SC0 =>
        payload_o(0)<=serdat_i;
        wen_o <= '1';
        type_o <= "1011";
        s_state <= waiting ;
      -------------------------------------------------------------------------
      
      when others =>
        if TBM_H_start_i = '1' then
          wen_o <= '0';
          s_state <= tick_EN7;
          
         else
           wen_o <= '0';
           s_state <= waiting;
        end if; 
        
        
    end case;
  end if;
end process p_format;



end rtl;
