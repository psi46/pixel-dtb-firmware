library verilog;
use verilog.vl_types.all;
entity pg_sequencer is
    port(
        clk             : in     vl_logic;
        sync            : in     vl_logic;
        reset           : in     vl_logic;
        enable          : in     vl_logic;
        start           : in     vl_logic;
        running         : out    vl_logic;
        pgout           : out    vl_logic_vector(4 downto 0);
        ip              : out    vl_logic_vector(7 downto 0);
        cmd             : in     vl_logic_vector(15 downto 0)
    );
end pg_sequencer;
