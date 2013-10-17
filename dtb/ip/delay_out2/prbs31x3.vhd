-- pseudo random bit sequence with 31-bit register
--  CLK: max speed given by 2 random bits each clock cycle
--  RESET: reset the internal register all to 1
--  SPEED: the speed of the output
--    "11" output each clock cycle two random bits on Y
--    "10" output each clock cycle the same random bit on Y
--    "01" output every second clock cycle the same random bit on Y
--    "00" output every fourth clock cycle the same random bit on Y
-------------------------------------------------------------------

entity PRBS31 is
  port (CLK: in bit;
        RESET: in bit;
        EN: in bit;
        SPEED: in bit_vector(1 downto 0);
        Y: out bit_vector(1 downto 0));
  end PRBS31;

entity DIVIDER_FSM is
  port (CLK: in bit;
        SPEED: in bit_vector(1 downto 0);
        Y: out bit);
  end DIVIDER_FSM;

architecture PRBS31_ARCH of PRBS31 is
  signal CIN: bit; -- Internal Clock used for switching
  component DIVIDER_FSM is port(CLK: in bit; SPEED: in bit_vector(1 downto 0); Y: out bit); end component;
  begin
    -- CLOCK DIVIDER FSM
    I0: DIVIDER_FSM port map(CLK,SPEED,CIN);
    process(CIN,RESET)
      variable REG: bit_vector(30 downto 0) := (others => '1');
      begin
        if RESET='1' then
          REG := (others => '1');
        elsif CIN'event and CIN='1' then
          if EN='0' then
            REG := (others => '1');
          else
            if SPEED="11" then
              REG := REG(28 downto 0) & (REG(30) xor REG(27)) & (REG(29) xor REG(26));
            else
              REG := REG(29 downto 0) & (REG(30) xor REG(27));
            end if;
          end if;
        end if;
        case SPEED is
          when "11" => Y <= REG(30 downto 29);
          when others => Y <= REG(30) & REG(30);
        end case;
      end process;
  end PRBS31_ARCH;


architecture DIVIDER_FSM_ARCH of DIVIDER_FSM is
  begin
    FSM: process(CLK)
         variable STATE: bit_vector(1 downto 0) := (others => '0');
         variable DECISION: bit_vector(3 downto 0);
         begin
           -- change state
           if CLK'event and CLK='1' then
             DECISION := STATE & SPEED;
             case DECISION is
               when "1100" => STATE := "00";
               when "0000" | "1101" => STATE := "01";
               when "0001" | "0100" => STATE := "10";
               when others => STATE := "11";
             end case;
           end if;
           
           -- output depending on state
           if CLK='1' then
             case STATE is
               when "11" => Y <= '1';
               when others => Y <= '0';
             end case;
           else
             Y <= '0';
           end if;
         end process FSM;
  end DIVIDER_FSM_ARCH;
