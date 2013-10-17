library verilog;
use verilog.vl_types.all;
entity cdc_pulse is
    port(
        clk1            : in     vl_logic;
        clk2            : in     vl_logic;
        clk2ena         : in     vl_logic;
        reset           : in     vl_logic;
        \in\            : in     vl_logic;
        \out\           : out    vl_logic
    );
end cdc_pulse;
