

library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity PXData_FSM is
   port (clk_i :         in   std_logic;
         reset_i :       in   std_logic;
         PX_start_i :    in   std_logic;
         PX_present_i :  in   std_logic;
         PX_data_i:		 in   std_logic;
         payload_o :     out  std_logic_vector(3 downto 0);
         type_o :        out  std_logic_vector(3 downto 0);
         PXwen_o :       out  std_logic);
end PXData_FSM;




architecture rtl of PXData_FSM is

  type t_state is (waiting,
                   tick_C5,
                   tick_C4,
 				   tick_C3,
                   tick_C2,
				   tick_C1,
				   tick_C0,
				   tick_R8,
				   tick_R7,
				   tick_R6,
				   tick_R5,
				   tick_R4,
				   tick_R3,
				   tick_R2,
				   tick_R1,
				   tick_R0,
				   tick_P7,
				   tick_P6,
				   tick_P5,
				   tick_P4,
				   tick_0,
				   tick_P3,
				   tick_P2,
				   tick_P1,
				   tick_P0);

 signal s_state : t_state;
  --signal s_count : unsigned(3 downto 0);
 
begin     



p_format: process (clk_i, reset_i)
begin  -- process p_serin
  if (reset_i = '1') then               -- asynchronous reset 
    PXwen_o <= '0';
    payload_o <= "0000";
    type_o <= "0000";
    s_state <= waiting;
    
  elsif rising_edge(clk_i) then  -- rising clock edge
    case s_state is
      -------------------------------------------------------------------------
      when tick_C5 =>
        if ( PX_present_i= '1' ) then
          -- pxl data present
           PXwen_o <= '0';
           type_o <= "0000";
          payload_o(3)<=PX_data_i;
          s_state <= tick_C4;
        else
           PXwen_o <= '0';
           type_o <= "0000";
           s_state <= waiting;
        end if;  
      -------------------------------------------------------------------------
      when tick_C4 =>
        payload_o(2)<=PX_data_i;
        s_state <= tick_C3 ;
      -------------------------------------------------------------------------
	   when tick_C3 =>
        payload_o(1)<=PX_data_i;
        s_state <= tick_C2 ;
      -------------------------------------------------------------------------
      when tick_C2 =>
        payload_o(0)<=PX_data_i;
        PXwen_o <= '1';
        type_o <= "0001";
        s_state <= tick_C1 ;
      -------------------------------------------------------------------------
      -------------------------------------------------------------------------
 	  when tick_C1 =>
        payload_o(3)<=PX_data_i;
        PXwen_o <= '0';
        s_state <= tick_C0 ;
      -------------------------------------------------------------------------
	  when tick_C0 =>
        payload_o(2)<=PX_data_i;
        s_state <= tick_R8 ;
      -------------------------------------------------------------------------
	   when tick_R8 =>
        payload_o(1)<=PX_data_i;
        s_state <= tick_R7 ;
      -------------------------------------------------------------------------
	   when tick_R7 =>
        payload_o(0)<=PX_data_i;
        PXwen_o <= '1';
        type_o <= "0010";
        s_state <= tick_R6 ;
      -------------------------------------------------------------------------
      -------------------------------------------------------------------------
	   when tick_R6 =>
        payload_o(3)<=PX_data_i;
        PXwen_o <= '0';
        s_state <= tick_R5 ;
      -----------------------------------------------------------------------
	  when tick_R5 =>
        payload_o(2)<=PX_data_i;
        s_state <= tick_R4 ;
      -------------------------------------------------------------------------
	   when tick_R4 =>
        payload_o(1)<=PX_data_i;
        s_state <= tick_R3 ;
      -------------------------------------------------------------------------
       when tick_R3 =>
        payload_o(0)<=PX_data_i;
        PXwen_o <= '1';
        type_o <= "0011";
        s_state <= tick_R2 ;
      -------------------------------------------------------------------------
      -------------------------------------------------------------------------
      when tick_R2 =>
        payload_o(3)<=PX_data_i;
        PXwen_o <= '0';
        s_state <= tick_R1 ;
      -------------------------------------------------------------------------
 	  when tick_R1 =>
        payload_o(2)<=PX_data_i;
        s_state <= tick_R0 ;
      -------------------------------------------------------------------------
	  when tick_R0 =>
        payload_o(1)<=PX_data_i;
        s_state <= tick_P7 ;
      -------------------------------------------------------------------------
	  when tick_P7 =>
        payload_o(0)<=PX_data_i;
        PXwen_o <= '1';
        type_o <= "0100";
        s_state <= tick_P6 ;
      -------------------------------------------------------------------------
      -------------------------------------------------------------------------
	   when tick_P6 =>
        payload_o(3)<=PX_data_i;
        PXwen_o <= '0';
        s_state <= tick_P5 ;
      -------------------------------------------------------------------------
	 when tick_P5 =>
        payload_o(2)<=PX_data_i;
        s_state <= tick_P4 ;
      -----------------------------------------------------------------------
	 when tick_P4 =>
        payload_o(1)<=PX_data_i;
        s_state <= tick_0 ;
      -------------------------------------------------------------------------
	  when tick_0 =>
        payload_o(0)<=PX_data_i;
        PXwen_o <= '1';
        type_o <= "0101";
        s_state <= tick_P3 ;
      -------------------------------------------------------------------------
      -------------------------------------------------------------------------
       when tick_P3 =>
        payload_o(3)<=PX_data_i;
        PXwen_o <= '0';
        s_state <= tick_P2 ;
      -------------------------------------------------------------------------
      when tick_P2 =>
        payload_o(2)<=PX_data_i;
        s_state <= tick_P1 ;
      -------------------------------------------------------------------------
       when tick_P1 =>
        payload_o(1)<=PX_data_i;
        s_state <= tick_P0 ;
      -------------------------------------------------------------------------
      when tick_P0 =>
        payload_o(0)<=PX_data_i;
        PXwen_o <= '1';
        type_o <= "0110";
        s_state <= tick_C5 ;
      -------------------------------------------------------------------------
      -------------------------------------------------------------------------
      
      when others =>
        if PX_start_i = '1' then
          
          s_state <= tick_C5;
          
         else
           s_state <= waiting;
        end if; 
        
        
    end case;
  end if;
end process p_format;



end rtl;
