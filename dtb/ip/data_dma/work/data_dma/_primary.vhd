library verilog;
use verilog.vl_types.all;
entity data_dma is
    port(
        csi_clock_clk   : in     vl_logic;
        csi_clock_reset : in     vl_logic;
        avs_ctrl_address: in     vl_logic_vector(1 downto 0);
        avs_ctrl_write  : in     vl_logic;
        avs_ctrl_writedata: in     vl_logic_vector(31 downto 0);
        avs_ctrl_read   : in     vl_logic;
        avs_ctrl_readdata: out    vl_logic_vector(31 downto 0);
        avm_data_address: out    vl_logic_vector(31 downto 0);
        avm_data_write  : out    vl_logic;
        avm_data_writedata: out    vl_logic_vector(15 downto 0);
        avm_data_waitrequest: in     vl_logic;
        avm_data_byteenable: out    vl_logic_vector(1 downto 0);
        write           : in     vl_logic;
        waitrq          : out    vl_logic;
        data            : in     vl_logic_vector(15 downto 0)
    );
end data_dma;
