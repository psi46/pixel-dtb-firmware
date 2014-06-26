-- Copyright (C) 1991-2010 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 9.1 Build 350 03/24/2010 Service Pack 2 SJ Full Version"
-- CREATED		"Thu Oct 31 13:57:57 2013"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY nedge_s IS 
	PORT
	(
		D :  IN  STD_LOGIC;
		CK :  IN  STD_LOGIC;
		Q :  OUT  STD_LOGIC
	);
END nedge_s;

ARCHITECTURE bdf_type OF nedge_s IS 

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;


BEGIN 
SYNTHESIZED_WIRE_0 <= '1';
SYNTHESIZED_WIRE_1 <= '1';
SYNTHESIZED_WIRE_2 <= '1';
SYNTHESIZED_WIRE_3 <= '1';
SYNTHESIZED_WIRE_4 <= '1';
SYNTHESIZED_WIRE_6 <= '1';



PROCESS(CK,SYNTHESIZED_WIRE_0,SYNTHESIZED_WIRE_1)
BEGIN
IF (SYNTHESIZED_WIRE_0 = '0') THEN
	SYNTHESIZED_WIRE_8 <= '0';
ELSIF (SYNTHESIZED_WIRE_1 = '0') THEN
	SYNTHESIZED_WIRE_8 <= '1';
ELSIF (RISING_EDGE(CK)) THEN
	SYNTHESIZED_WIRE_8 <= D;
END IF;
END PROCESS;



PROCESS(CK,SYNTHESIZED_WIRE_2,SYNTHESIZED_WIRE_3)
BEGIN
IF (SYNTHESIZED_WIRE_2 = '0') THEN
	SYNTHESIZED_WIRE_9 <= '0';
ELSIF (SYNTHESIZED_WIRE_3 = '0') THEN
	SYNTHESIZED_WIRE_9 <= '1';
ELSIF (RISING_EDGE(CK)) THEN
	SYNTHESIZED_WIRE_9 <= SYNTHESIZED_WIRE_8;
END IF;
END PROCESS;



PROCESS(CK,SYNTHESIZED_WIRE_4,SYNTHESIZED_WIRE_6)
BEGIN
IF (SYNTHESIZED_WIRE_4 = '0') THEN
	Q <= '0';
ELSIF (SYNTHESIZED_WIRE_6 = '0') THEN
	Q <= '1';
ELSIF (RISING_EDGE(CK)) THEN
	Q <= SYNTHESIZED_WIRE_5;
END IF;
END PROCESS;



SYNTHESIZED_WIRE_5 <= SYNTHESIZED_WIRE_7 AND SYNTHESIZED_WIRE_9;



SYNTHESIZED_WIRE_7 <= SYNTHESIZED_WIRE_8 XOR SYNTHESIZED_WIRE_9;




END bdf_type;