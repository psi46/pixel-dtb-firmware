library verilog;
use verilog.vl_types.all;
entity psi2c_readback is
    port(
        clk             : in     vl_logic;
        sync            : in     vl_logic;
        reset           : in     vl_logic;
        go              : in     vl_logic;
        rda             : in     vl_logic;
        sync2           : in     vl_logic;
        i2c_send        : in     vl_logic;
        d               : out    vl_logic_vector(31 downto 0)
    );
end psi2c_readback;
