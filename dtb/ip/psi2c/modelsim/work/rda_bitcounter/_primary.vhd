library verilog;
use verilog.vl_types.all;
entity rda_bitcounter is
    port(
        aclr            : in     vl_logic;
        clk_en          : in     vl_logic;
        clock           : in     vl_logic;
        cnt_en          : in     vl_logic;
        sset            : in     vl_logic;
        cout            : out    vl_logic;
        q               : out    vl_logic_vector(4 downto 0)
    );
end rda_bitcounter;
