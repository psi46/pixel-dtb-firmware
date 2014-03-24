library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity HeRhTr is
Port ( 	clk : in STD_LOGIC;
		reset:in STD_LOGIC;
		sd_in: in STD_LOGIC;
		sd_out:out STD_LOGIC;
		TbmHeader:out STD_LOGIC;
		RocHeader:out STD_LOGIC;
		TbmTrailer:out STD_LOGIC;
		TP:out STD_LOGIC;
		TPP:out STD_LOGIC;
		allowRocH:out STD_LOGIC);
end HeRhTr;


architecture Behaviorial of HeRhTr is

 --signal
 signal s_1: STD_LOGIC:='0';
 signal s_2: STD_LOGIC:='0';
 signal s_3: STD_LOGIC:='0';
 signal s_4: STD_LOGIC:='0';
 signal s_5: STD_LOGIC:='0';
 signal s_6: STD_LOGIC:='0';
 signal s_7: STD_LOGIC:='0';
 signal s_8: STD_LOGIC:='0';
 signal s_9: STD_LOGIC:='0';
 signal s_10: STD_LOGIC:='0';
 signal s_11: STD_LOGIC:='0';
 signal s_12: STD_LOGIC:='0';
 signal s_13: STD_LOGIC:='0';
 
 signal s_d1: STD_LOGIC:='0';
 signal s_d2: STD_LOGIC:='0';
 signal s_d3: STD_LOGIC:='0';
 signal s_d4: STD_LOGIC:='0';
 signal s_d5: STD_LOGIC:='0';
 signal s_d6: STD_LOGIC:='0';
 signal s_d7: STD_LOGIC:='0';
 signal s_d8: STD_LOGIC:='0';
 signal s_d9: STD_LOGIC:='0';
 signal s_d10: STD_LOGIC:='0';
 signal s_d11: STD_LOGIC:='0';
 signal s_d12: STD_LOGIC:='0';
 signal s_d13: STD_LOGIC:='0';
 signal s_d14: STD_LOGIC:='0';
 signal s_d15: STD_LOGIC:='0';
 signal s_d16: STD_LOGIC:='0';
 
 signal s_HEADER: STD_LOGIC:='0';
 signal s_ROC: STD_LOGIC:='0';
 signal s_TRAILER: STD_LOGIC:='0';
 
 signal s_DataWindow: STD_LOGIC:='0';
 
 signal s_count: STD_LOGIC_VECTOR (3 downto 0):="0000";
 signal s_TC: STD_LOGIC:='0';
  
begin

------------------------------------------------------------
  p_pipe: process (clk)
  begin
	if (rising_edge(clk)) then
		s_1 <= sd_in;
		s_2 <= s_1;
		s_3 <= s_2;
		s_4 <= s_3;
		s_5 <= s_4;
		s_6 <= s_5;
		s_7 <= s_6;
		s_8 <= s_7;
		s_9 <= s_8;
		s_10 <= s_9;
		s_11 <= s_10;
		s_12 <= s_11;
		s_13 <= s_12;
		
	end if;
  end process p_pipe;
  sd_out <= s_13;
 
  ------------------------------------------------------------
  s_HEADER <= ( (not s_11) and s_10 and s_9 and s_8 and s_7
				 and s_6 and s_5 and s_4 and s_3 and s_2
				 and (not s_1) and (not sd_in) );
 
  s_ROC <= ( (not s_11) and s_10 and s_9 and s_8 and s_7
			  and s_6 and s_5 and s_4 and s_3 and (not s_2)
			  and s_d15 and s_DataWindow);
				 
  s_TRAILER <= ( (not s_11) and s_10 and s_9 and s_8 and s_7
				 and s_6 and s_5 and s_4 and s_3 and s_2
				 and s_1 and sd_in );
				 
  ------------------------------------------------------------
  
  p_DataWindow: process (clk, reset)
  begin
	if (reset = '1') then
		s_DataWindow <= '0';
	
	elsif (rising_edge(clk)) then
		if ( s_HEADER = '1') then
	       s_DataWindow <= '1';
        elsif ( s_TRAILER = '1') then
	       s_DataWindow <= '0';
        end if;

	end if;
  end process p_DataWindow;

  TP <= s_DataWindow;
  ------------------------------------------------------------
  
  p_Mod12Cnt: process (clk)
  begin
	if (rising_edge(clk)) then
		if (s_DataWindow = '1') then --count
	       if (s_count= "1011") then
	         s_count <= "0000";
	         s_TC <='1';
	       else
	         s_count <= s_count +1;
	         s_TC <='0';
	       end if;  
	
        else -- do not count
	      s_count <= "0000";
	      s_TC <='0';
		end if;
	end if;
  end process p_Mod12Cnt;

  TPP <= s_TC;
  ------------------------------------------------------------
  p_delay: process (clk)
  begin
	if (rising_edge(clk)) then
		s_d1 <= s_TC;
		s_d2 <= s_d1;
		s_d3 <= s_d2;
		s_d4 <= s_d3;
		s_d5 <= s_d4;
		s_d6 <= s_d5;
		s_d7 <= s_d6;
		s_d8 <= s_d7;
		s_d9 <= s_d8;
		s_d10 <= s_d9;
		s_d11 <= s_d10;
		s_d12 <= s_d11;
		s_d13 <= s_d12;
		s_d14 <= s_d13;
		s_d15 <= s_d14;
		s_d16 <= s_d15;
		
	end if;
  end process p_delay;
 allowRocH <= s_d16;
 
  ------------------------------------------------------------  
  
  p_output_registers : process (clk)
  begin
	if (rising_edge(clk)) then
		
		TbmHeader	<= s_HEADER;		 
        RocHeader	<= s_ROC;
        TbmTrailer <= s_TRAILER;	
		
	end if;
  end process p_output_registers;
 
  ------------------------------------------------------------ 
   
 
end;--Behavioral