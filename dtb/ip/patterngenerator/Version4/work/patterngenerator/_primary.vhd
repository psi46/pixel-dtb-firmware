library verilog;
use verilog.vl_types.all;
entity patterngenerator is
    port(
        csi_clock_clk   : in     vl_logic;
        csi_clock_reset : in     vl_logic;
        avs_ctrl_address: in     vl_logic;
        avs_ctrl_read   : in     vl_logic;
        avs_ctrl_readdata: out    vl_logic_vector(31 downto 0);
        avs_ctrl_write  : in     vl_logic;
        avs_ctrl_writedata: in     vl_logic_vector(31 downto 0);
        avs_data_address: in     vl_logic_vector(7 downto 0);
        avs_data_write  : in     vl_logic;
        avs_data_byteenable: in     vl_logic_vector(1 downto 0);
        avs_data_writedata: in     vl_logic_vector(15 downto 0);
        clkena          : in     vl_logic;
        trigger         : in     vl_logic;
        pgout           : out    vl_logic_vector(4 downto 0)
    );
end patterngenerator;
