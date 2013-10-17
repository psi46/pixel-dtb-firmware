-- pseudo random bit sequence with 31-bit register
--------------------------------------------------

entity PRBS31 is
  port (CLK: in bit;
        RESET: in bit;
        SPEED: in bit_vector(1 downto 0);
        Y: out bit_vector(1 downto 0));
  end PRBS31;

architecture PRBS31_ARCH of PRBS31 is
  begin
    process(CLK,RESET)
      variable REG: bit_vector(30 downto 0) := (others => '1');
      begin
        if RESET='1' then
          REG := (others => '1');
        elsif CLK'event and CLK='1' then
          REG := REG(29 downto 0) & (REG(30) xor REG(27));
        end if;
        Y <= REG(30) & REG(30);
      end process;
  end PRBS31_ARCH;
