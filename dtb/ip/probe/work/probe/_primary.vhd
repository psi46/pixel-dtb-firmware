library verilog;
use verilog.vl_types.all;
entity probe is
    port(
        csi_clock_clk   : in     vl_logic;
        csi_clock_reset : in     vl_logic;
        avs_ctrl_write  : in     vl_logic;
        avs_ctrl_writedata: in     vl_logic_vector(7 downto 0);
        sig_in          : in     vl_logic_vector(30 downto 0);
        sig_out         : out    vl_logic
    );
end probe;
