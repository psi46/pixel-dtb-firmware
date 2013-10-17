library verilog;
use verilog.vl_types.all;
entity psi2c_bitsend is
    port(
        clk             : in     vl_logic;
        sync            : in     vl_logic;
        reset           : in     vl_logic;
        phase           : in     vl_logic;
        go              : in     vl_logic;
        empty           : in     vl_logic;
        rd              : out    vl_logic;
        busy            : out    vl_logic;
        d               : in     vl_logic_vector(11 downto 0);
        sda             : out    vl_logic
    );
end psi2c_bitsend;
