

library  IEEE;
use      IEEE.std_logic_1164.all;
use      IEEE.std_logic_arith.all;


entity simple_i2c is
   port (clk_i :         in   std_logic;
         reset_n_i :     in   std_logic;
         sub_i2c_i :     in   std_logic;
         sda_i :         in   std_logic;
         scl_i:			 in   std_logic;
     	 sda_o :         out  std_logic;
         ack_o :         out  std_logic;
         sdadir_o :      out  std_logic;
         sclen_o:		 out  std_logic;
         addrw_i :       in   std_logic_vector(7 downto 0);
         data_i :        in   std_logic_vector(7 downto 0);
         nbytes_i :      in   unsigned(7 downto 0);
         pd_o :          out  std_logic_vector(7 downto 0);
         error_o :       out  std_logic_vector(7 downto 0);
         readen_o :      out  std_logic;
         next_b :        out  std_logic_vector(1 downto 0));
end simple_i2c;




architecture rtl of simple_i2c is

  type t_state is (waiting,
                   check_bus_busy,
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
				   send_D7,
				   send_D6,
				   send_D5,
				   send_D4,
				   send_D3,
				   send_D2,
				   send_D1,
				   send_D0,
				   read_D_ACK,
				   read_D7,
				   read_D6,
				   read_D5,
				   read_D4,
				   read_D3,
				   read_D2,
				   read_D1,
				   read_D0,
				   send_NOACK,
				   send_ACK,
				   restart_READ,
				   restart_DATA,
				   send_STOPCLKRD,
				   send_STOPCLK,
				   send_STOP,
                   write_sda);
  signal s_state : t_state;
  signal s_sdadir : std_logic;   -- Signal buffer for sdadir_o !!
  signal s_sda_response : std_logic;
  signal s_count : unsigned(3 downto 0);
  signal s_timeout: unsigned(4 downto 0);
  signal s_d_serin : std_logic_vector(7 downto 0);
  signal s_addrw :   std_logic_vector(7 downto 0);
  signal s_nbytes :  unsigned(7 downto 0);
  signal s_bytecount :  unsigned(7 downto 0);
  signal s_rwq :  std_logic;
  
begin     




p_get_SDA: process (clk_i, reset_n_i)
begin

	if (reset_n_i = '0') then   
	  s_sda_response <= '1';
	elsif clk_i'EVENT AND clk_i = '0' then
	  if ( s_sdadir= '0' AND sda_i = '0') then 
	    s_sda_response <= '0';
	  else 
	    s_sda_response <= '1';
	 end if;
	  
	end if;
	
	ack_o <= s_sda_response;
	   
end process p_get_SDA;








p_i2cmaster: process (clk_i, reset_n_i)
begin  -- process p_serin
  if (reset_n_i = '0') then               -- asynchronous reset (active low)
    s_state <= waiting;
    s_count <= conv_unsigned(0,4);
    s_d_serin <= "00000000";
    pd_o <= "00000000";
    error_o <= "00000000";
    sclen_o <= '0';
    readen_o <= '0';
    sda_o <= '1';
    sdadir_o <= '0'; s_sdadir <= '0';
  elsif rising_edge(clk_i) then  -- rising clock edge
    case s_state is
      -------------------------------------------------------------------------
      when check_bus_busy =>
        if ( sda_i = '1' AND scl_i = '1' ) then
          -- bus is free 
          s_state <= send_START;
        else
          -- bus isn't free
          s_timeout <= s_timeout - conv_unsigned(1,1); -- decrement s_timeout
          if (s_timeout = 0) then 
             error_o <= "00000001";
             s_state <= waiting;
          end if;
        end if;  
      -------------------------------------------------------------------------
      when send_START =>
        sdadir_o <= '1'; s_sdadir <= '0';
        sclen_o <= '1';
        readen_o <= '0'; 
        sda_o <= '0';
        s_bytecount <= conv_unsigned(0,8);
        next_b <= CONV_STD_LOGIC_VECTOR(s_bytecount,2);
        s_state <= send_A7 ;
      -------------------------------------------------------------------------
	  when send_A7 =>
        sda_o <= s_addrw(7);
        s_state <= send_A6;
      -------------------------------------------------------------------------
      when send_A6 =>
        sda_o <= s_addrw(6);
        s_state <= send_A5;
      -------------------------------------------------------------------------
 	  when send_A5 =>
        sda_o <= s_addrw(5);
        s_state <= send_A4;
      -------------------------------------------------------------------------
	  when send_A4 =>
        sda_o <= s_addrw(4);
        s_state <= send_A3;
      -------------------------------------------------------------------------
	  when send_A3 =>
        sda_o <= s_addrw(3);
        s_state <= send_A2;
      -------------------------------------------------------------------------
	  when send_A2 =>
        sda_o <= s_addrw(2);
        s_state <= send_A1;
      -------------------------------------------------------------------------
	  when send_A1 =>
        sda_o <= s_addrw(1);
        s_state <= send_RW;
      -----------------------------------------------------------------------
	  when send_RW =>
        sda_o <= s_addrw(0);
        s_state <= read_A_ACK;
      -------------------------------------------------------------------------
	  when read_A_ACK =>
		sda_o <= '0';  
		sdadir_o <= '0';  s_sdadir <= '0';
		s_state <= send_D7;
        if ( s_rwq = '1') then                 	-- read
		  s_state <= read_D7;
		else								    -- write
		  s_state <= send_D7;
		end if;
      -------------------------------------------------------------------------
      when send_D7 =>
        sdadir_o <= '1';  s_sdadir <= '0';
        if(s_sda_response = '0') then
          -- ADDRESS acknowledged
          sda_o <= data_i(7);
          s_state <= send_D6;
        else
          -- A_ACK ERROR
          error_o <= "00000010";
          sda_o <= '1';
          sclen_o <= '0'; 
          s_state <= waiting;
        end if;
      -------------------------------------------------------------------------
      when send_D6 =>
        sda_o <= data_i(6);
        s_bytecount <= s_bytecount + conv_unsigned(1,8);
        s_state <= send_D5;
      -------------------------------------------------------------------------
 	  when send_D5 =>
        sda_o <= data_i(5);
        s_state <= send_D4;
      -------------------------------------------------------------------------
	  when send_D4 =>
        sda_o <= data_i(4);
        s_state <= send_D3;
      -------------------------------------------------------------------------
	  when send_D3 =>
        sda_o <= data_i(3);
        s_state <= send_D2;
      -------------------------------------------------------------------------
	  when send_D2 =>
        sda_o <= data_i(2);
        s_state <= send_D1;
      -------------------------------------------------------------------------
	  when send_D1 =>
        sda_o <= data_i(1);
        s_state <= send_D0;
      -----------------------------------------------------------------------
	  when send_D0 =>
        sda_o <= data_i(0);
        s_state <= read_D_ACK;
      -------------------------------------------------------------------------
	  when read_D_ACK =>
	    sda_o <= '0';
	    sdadir_o <= '0';  s_sdadir <= '0';
	    if(s_nbytes = s_bytecount) then
	      s_state <= send_STOPCLK;
	    else
	      s_state <= restart_DATA;
	      next_b <= CONV_STD_LOGIC_VECTOR(s_bytecount,2);
	    end if;
      -------------------------------------------------------------------------
      when read_D7 =>
        if(s_sda_response = '0') then
          -- ADDRESS acknowledged
          s_state <= read_D6;
        else
          -- A_ACK ERROR
          sdadir_o <= '1';  s_sdadir <= '0';
          error_o <= "00000010";
          sda_o <= '1';
          sclen_o <= '0'; 
          s_state <= waiting;
        end if;
      -------------------------------------------------------------------------
      when read_D6 =>
         readen_o <= '0';
         s_d_serin(7)<= s_sda_response;
         s_bytecount <= s_bytecount + conv_unsigned(1,8);
         next_b <= CONV_STD_LOGIC_VECTOR(s_bytecount,2);
         s_state <= read_D5;
      -------------------------------------------------------------------------
      when read_D5 =>
         s_d_serin(6)<= s_sda_response;
         s_state <= read_D4;
      -------------------------------------------------------------------------
      when read_D4 =>
         s_d_serin(5)<= s_sda_response;
         s_state <= read_D3;
      -------------------------------------------------------------------------
      when read_D3 =>
         s_d_serin(4)<=s_sda_response;
         s_state <= read_D2;
      -------------------------------------------------------------------------
      when read_D2 =>
         s_d_serin(3)<= s_sda_response;
         s_state <= read_D1;
      -------------------------------------------------------------------------
      when read_D1 =>
         s_d_serin(2)<= s_sda_response;
         s_state <= read_D0;
      -------------------------------------------------------------------------
      when read_D0 =>
         s_d_serin(1)<= s_sda_response;
         if(s_nbytes = s_bytecount) then
	      s_state <= send_NOACK;
	    else
	      s_state <= send_ACK;
	    end if;
      -------------------------------------------------------------------------
      when send_NOACK =>
         s_d_serin(0)<= s_sda_response;
         sdadir_o <= '1';  s_sdadir <= '1';
         sda_o <= '1';   -- NOACK BY MASTER
         s_state <= send_STOPCLKRD;
      -------------------------------------------------------------------------
      when send_ACK =>
          s_d_serin(0)<= s_sda_response;
          sdadir_o <= '1';  s_sdadir <= '1';
          sda_o <= '0'; -- DTACK by Master
          s_state <= restart_READ;
      -------------------------------------------------------------------------
      when restart_READ =>
          sdadir_o <= '0';  s_sdadir <= '0';
          readen_o <= '1';
          pd_o <= s_d_serin;
          s_d_serin(7)<= s_sda_response;
          s_state <= read_D6;
      -------------------------------------------------------------------------
      when restart_DATA =>
        if(s_sda_response =  '0') then
          -- DATA acknowledged
          sdadir_o <= '1';  s_sdadir <= '1';
          sda_o <= data_i(7);
          s_state <= send_D6;
        else
          -- D_ACK ERROR
          error_o <= "00000100";
          s_state <= send_STOP;
        end if;
      -------------------------------------------------------------------------
      when send_STOPCLKRD =>
        sda_o <= '0';
        sclen_o <= '0'; 
        readen_o <= '1';
        pd_o <= s_d_serin;
        s_state <= send_STOP;
      -------------------------------------------------------------------------
      when send_STOPCLK =>
        sda_o <= '0';
        sclen_o <= '0'; 
        if(s_sda_response =  '0') then
          -- DATA acknowledged
          s_state <= send_STOP;
        else
          -- D_ACK ERROR
          error_o <= "00000100";
          s_state <= send_STOP;
        end if;
      -------------------------------------------------------------------------
      when send_STOP =>
        sda_o <= '1';
        sclen_o <= '0';
        readen_o <= '0'; 
        s_state <= waiting;
      -------------------------------------------------------------------------
      -------------------------------------------------------------------------
      when others =>
        if sub_i2c_i = '1' then
          -- VME Start I2C Cycle command detected.
          s_addrw <= addrw_i;
          s_nbytes <= nbytes_i;
		  s_rwq <= addrw_i(0);
          s_state <= check_bus_busy;
          
          -- Initialize input counter
          s_timeout <= conv_unsigned(10,5);
        end if;
    end case;
  end if;
end process p_i2cmaster;



end rtl;
