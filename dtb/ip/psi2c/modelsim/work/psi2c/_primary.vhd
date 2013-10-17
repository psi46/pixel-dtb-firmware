library verilog;
use verilog.vl_types.all;
entity psi2c is
    port(
        csi_clock_clk   : in     vl_logic;
        csi_clock_reset : in     vl_logic;
        avs_ctrl_address: in     vl_logic_vector(2 downto 0);
        avs_ctrl_read   : in     vl_logic;
        avs_ctrl_readdata: out    vl_logic_vector(31 downto 0);
        avs_ctrl_write  : in     vl_logic;
        avs_ctrl_writedata: in     vl_logic_vector(31 downto 0);
        sync            : in     vl_logic;
        phase           : in     vl_logic;
        send            : out    vl_logic;
        sda             : out    vl_logic;
        rda             : in     vl_logic
    );
end psi2c;
