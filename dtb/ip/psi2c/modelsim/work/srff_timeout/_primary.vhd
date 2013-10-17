library verilog;
use verilog.vl_types.all;
entity srff_timeout is
    port(
        clk             : in     vl_logic;
        sync            : in     vl_logic;
        reset           : in     vl_logic;
        to_disable      : in     vl_logic;
        s               : in     vl_logic;
        r               : in     vl_logic;
        q               : out    vl_logic
    );
end srff_timeout;
