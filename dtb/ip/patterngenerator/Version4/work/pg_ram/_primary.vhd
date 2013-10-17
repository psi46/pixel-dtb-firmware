library verilog;
use verilog.vl_types.all;
entity pg_ram is
    port(
        byteena_a       : in     vl_logic_vector(1 downto 0);
        clock           : in     vl_logic;
        data            : in     vl_logic_vector(15 downto 0);
        rdaddress       : in     vl_logic_vector(7 downto 0);
        wraddress       : in     vl_logic_vector(7 downto 0);
        wren            : in     vl_logic;
        q               : out    vl_logic_vector(15 downto 0)
    );
end pg_ram;
