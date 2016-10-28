// stb_switch.v


module stb_switch
(
	// switch control
	//     bit 5      bit 4     bit 3       bit 2      bit 1       bit 0
	// +----------+----------+---------+-----------+-----------+-----------+
  // | mode_stb | mode_spi | spi_pol | spi_cs[2] | spi_cs[1] | spi_cs[0] |
 	// +----------+----------+---------+-----------+-----------+-----------+
 
	input [5:0]ctrl,
	
	// from SPI controller
	input spi_sclk,
	input spi_ss,
	input spi_mosi,
	output spi_miso,
	
	// from ROC_addr/reset port
	input [3:0]addr_in,
	input nReset_in,
	
	// from Plug_IOs output port
	input [3:0] port_out,
	
	// combined ports
	output reg i2c_scl,   // spi_sclk to I2C controller
	inout  reg [3:0]addr, // Chip Address
	inout  reg nReset,    // Chip reset_n
	inout  reg [3:0]io    // gpio
);

	// control port decoding
	wire mode_stb    = ctrl[5];
	wire mode_spi    = ctrl[4];
	wire spi_pol     = ctrl[3];
	wire [2:0]spi_cs = ctrl[2:0];

	assign spi_miso = io[1];
	
	always @(*)
	begin
		if (mode_stb)
		begin // --- STB mode
			if (mode_spi)
			begin // SPI mode
				i2c_scl <= spi_sclk ^ spi_pol;
				io[0]   <= spi_mosi;
				io[1]   <= 1'bz;
				io[2]   <= !spi_ss;
				io[3]   <= port_out[3];
				addr[0] <= spi_cs[0];
				addr[1] <= spi_cs[1];
				addr[2] <= spi_cs[2];
				addr[3] <= 1'bz;
				nReset  <= 1'bz;
			end // spi_mode
			else
			begin // I2C mode
				i2c_scl <= 1'b1;
				io[0]   <= spi_mosi;
				io[1]   <= 1'bz;
				io[2]   <= 1'b0;
				io[3]   <= port_out[3];
				addr[0] <= spi_cs[0];
				addr[1] <= spi_cs[1];
				addr[2] <= spi_cs[2];
				addr[3] <= 1'bz;
				nReset  <= 1'bz;
			end // I2C mode
		end // --- STB mode
		else
		begin // --- DTB mode
			i2c_scl <= 1'b1;
			io[0]   <= port_out[0];
			io[1]   <= port_out[1];
			io[2]   <= 1'b0;
			io[3]   <= port_out[3];
			addr[0] <= addr_in[0] ? 1'bz : 1'b0;
			addr[1] <= addr_in[1] ? 1'bz : 1'b0;
			addr[2] <= addr_in[2] ? 1'bz : 1'b0;
			addr[3] <= addr_in[3] ? 1'bz : 1'b0;
			nReset  <= nReset_in      ? 1'bz : 1'b0;
		end // --- DTB mode
	end

endmodule
