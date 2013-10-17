library verilog;
use verilog.vl_types.all;
entity i2c_control is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        address         : in     vl_logic_vector(2 downto 0);
        write           : in     vl_logic;
        writedata       : in     vl_logic_vector(31 downto 0);
        read            : in     vl_logic;
        readdata        : out    vl_logic_vector(31 downto 0);
        go              : out    vl_logic;
        full            : in     vl_logic;
        memd            : out    vl_logic_vector(11 downto 0);
        memw            : out    vl_logic;
        busy            : in     vl_logic;
        tbm             : out    vl_logic;
        rda             : in     vl_logic_vector(31 downto 0)
    );
end i2c_control;
