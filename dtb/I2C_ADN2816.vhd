

library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity I2C_ADN2816 is
   port (clk_i :         in   std_logic;
         sub_i2c_i:      in   std_logic;
         reset_n_i :     in   std_logic;
     	 sda_o :         out  std_logic;
     	 sda_dir_o :     out  std_logic;
         sclen_o:		 out  std_logic);
end I2C_ADN2816;




architecture rtl of I2C_ADN2816 is

  type t_state is (waiting,
                   send_START,
 				   send_A7,
                   send_A6,
				   send_A5,
				   send_A4,
				   send_A3,
				   send_A2,
				   send_A1,
				   send_RW,
				   read_A_ACK,
				   send_SA7,
				   send_SA6,
				   send_SA5,
				   send_SA4,
				   send_SA3,
				   send_SA2,
				   send_SA1,
				   send_SA0,
				   read_SA_ACK,
				   send_D7,
				   send_D6,
				   send_D5,
				   send_D4,
				   send_D3,
				   send_D2,
				   send_D1,
				   send_D0,
				   read_D_ACK,
				   send_ACK,
				   send_STOPCLK,
				   send_PAUS1,
				   send_PAUS2,
				   send_PAUS3,
				   send_PAUS4,
				   send_PAUS5,
				   send_PAUS6,
				   send_PAUS7,
				   send_STOP);
  signal s_state : t_state;

  signal s_count : std_logic;
 
begin     





p_i2cmaster: process (clk_i, reset_n_i)
begin  -- process p_serin
  if (reset_n_i = '0') then 
                  -- asynchronous reset (active low)
    sda_dir_o <= '1';
    sda_o <= '1';
    sclen_o <= '0';
    s_count <= '0';
    s_state <= waiting;
   
  elsif rising_edge(clk_i) then  -- rising clock edge
    case s_state is
      
      when send_START =>
        sda_dir_o <= '1'; 
        sda_o <= '0';
       
        s_state <= send_A7 ;
      -------------------------------------------------------------------------
	  when send_A7 =>
	    sclen_o <= '1';
        sda_o <= '1';
        s_state <= send_A6;
      -------------------------------------------------------------------------
      when send_A6 =>
        sda_o <= s_count;          --sda_o <= '1'; old PCB version
        s_state <= send_A5;
      -------------------------------------------------------------------------
 	  when send_A5 =>
        sda_o <= '0';
        s_state <= send_A4;
      -------------------------------------------------------------------------
	  when send_A4 =>
        sda_o <= '0';
        s_state <= send_A3;
      -------------------------------------------------------------------------
	  when send_A3 =>
        sda_o <= '0';
        s_state <= send_A2;
      -------------------------------------------------------------------------
	  when send_A2 =>
        sda_o <= '0';
        s_state <= send_A1;
      -------------------------------------------------------------------------
	  when send_A1 =>
        sda_o <= '0';
        s_state <= send_RW;
      -----------------------------------------------------------------------
	  when send_RW =>
        sda_o <= '0';
        s_state <= read_A_ACK;
      -------------------------------------------------------------------------
	  when read_A_ACK =>
		sda_o <= '0';  
		sda_dir_o <= '0'; 
		s_state <= send_SA7;
       
      -------------------------------------------------------------------------
      when send_SA7 =>
        sda_dir_o <= '1'; 
        
          sda_o <= '0';
          s_state <= send_SA6;
        
      -------------------------------------------------------------------------
      when send_SA6 =>
        sda_o <= '0';
        s_state <= send_SA5;
      -------------------------------------------------------------------------
 	  when send_SA5 =>
        sda_o <= '0';
        s_state <= send_SA4;
      -------------------------------------------------------------------------
	  when send_SA4 =>
        sda_o <= '0';
        s_state <= send_SA3;
      -------------------------------------------------------------------------
	  when send_SA3 =>
        sda_o <= '1';
        s_state <= send_SA2;
      -------------------------------------------------------------------------
	  when send_SA2 =>
        sda_o <= '0';
        s_state <= send_SA1;
      -------------------------------------------------------------------------
	  when send_SA1 =>
        sda_o <= '0';
        s_state <= send_SA0;
      -----------------------------------------------------------------------
	  when send_SA0 =>
        sda_o <= '0';
        s_state <= read_SA_ACK;
      -------------------------------------------------------------------------
	  when read_SA_ACK =>
	    sda_o <= '0';
	    sda_dir_o <= '0'; 
	   
	      s_state <= send_D7;
	    
      -------------------------------------------------------------------------
      when send_D7 =>
      sda_dir_o <= '1'; 
          sda_o <= '1';
          s_state <= send_D6;
       
      -------------------------------------------------------------------------
      when send_D6 =>
         sda_o <= '1';
        
         s_state <= send_D5;
      -------------------------------------------------------------------------
      when send_D5 =>
         sda_o <= '0';
         s_state <= send_D4;
      -------------------------------------------------------------------------
      when send_D4 =>
          sda_o <= '1';
         s_state <= send_D3;
      -------------------------------------------------------------------------
      when send_D3 =>
          sda_o <= '0';
         s_state <= send_D2;
      -------------------------------------------------------------------------
      when send_D2 =>
          sda_o <= '1';
         s_state <= send_D1;
      -------------------------------------------------------------------------
      when send_D1 =>
          sda_o <= '0';
         s_state <= send_D0;
      -------------------------------------------------------------------------
      when send_D0 =>
         sda_o <= '1';
	      s_state <= read_D_ACK;
	   
      -------------------------------------------------------------------------
      when read_D_ACK =>
	    sda_o <= '0';
	    sda_dir_o <= '0'; 
	   
	      s_state <= send_STOPCLK;
      -------------------------------------------------------------------------
     
      when send_STOPCLK =>
        sda_dir_o <= '1'; 
        sda_o <= '0';
        --sclen_o <= '0'; 
        
          s_state <= send_STOP;
       
      -------------------------------------------------------------------------
      when send_STOP =>
        sda_o <= '1';
        sclen_o <= '0';
       
        s_state <= send_PAUS1;
      -------------------------------------------------------------------------
      when send_PAUS1 =>
        if (s_count ='0') then
        s_state <= send_PAUS2;
        else 
        s_state <= waiting;
        end if;
      -------------------------------------------------------------------------
      when send_PAUS2 =>
        s_count <= '1';
        s_state <= send_PAUS3;
      -------------------------------------------------------------------------
       when send_PAUS3 =>
        s_state <= send_PAUS4;
      -------------------------------------------------------------------------
       when send_PAUS4 =>
        s_state <= send_PAUS5;
      -------------------------------------------------------------------------
       when send_PAUS5 =>
        s_state <= send_PAUS6;
      -------------------------------------------------------------------------
       when send_PAUS6 =>
        s_state <= send_PAUS7;
      -------------------------------------------------------------------------
       when send_PAUS7 =>
       
        s_state <= send_START;
        ------------------------------------------------------
      when others =>
        if sub_i2c_i = '1' then
          -- VME Start I2C Cycle command detected.
          s_count <= '0';
          s_state <= send_START;
          
      
        end if;
    end case;
  end if;
end process p_i2cmaster;



end rtl;
