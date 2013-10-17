library verilog;
use verilog.vl_types.all;
entity probe_mux4 is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        \select\        : in     vl_logic_vector(1 downto 0);
        sig_in          : in     vl_logic_vector(3 downto 0);
        sig_out         : out    vl_logic
    );
end probe_mux4;
