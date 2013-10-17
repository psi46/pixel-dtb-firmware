library verilog;
use verilog.vl_types.all;
entity adv3224 is
    generic(
        divider         : integer := 5
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        avs_slave_write : in     vl_logic;
        avs_slave_read  : in     vl_logic;
        avs_slave_writedata: in     vl_logic_vector(7 downto 0);
        avs_slave_readdata: out    vl_logic_vector(7 downto 0);
        avs_slave_address: in     vl_logic_vector(2 downto 0);
        cps_reset_n     : out    vl_logic;
        cps_ce_n        : out    vl_logic;
        cps_update_n    : out    vl_logic;
        cps_clk         : out    vl_logic;
        cps_datain      : out    vl_logic
    );
end adv3224;
