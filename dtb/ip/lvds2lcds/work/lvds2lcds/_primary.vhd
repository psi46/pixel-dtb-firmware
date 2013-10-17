library verilog;
use verilog.vl_types.all;
entity lvds2lcds is
    generic(
        divider         : integer := 4
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        avs_slave_address: in     vl_logic;
        avs_slave_write : in     vl_logic;
        avs_slave_read  : in     vl_logic;
        avs_slave_writedata: in     vl_logic_vector(7 downto 0);
        avs_slave_readdata: out    vl_logic_vector(7 downto 0);
        reset_n         : out    vl_logic;
        scl             : out    vl_logic;
        sdi             : out    vl_logic;
        sld             : out    vl_logic;
        lvds_clk        : out    vl_logic;
        lvds_ctr        : out    vl_logic;
        lvds_sda        : out    vl_logic;
        lvds_tin        : out    vl_logic;
        lvds_tout_rda   : in     vl_logic;
        lvds_sdata1     : in     vl_logic;
        lvds_sdata2     : in     vl_logic;
        lvds_sdata3     : in     vl_logic
    );
end lvds2lcds;
