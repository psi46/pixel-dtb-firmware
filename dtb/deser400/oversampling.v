// oversampling.v


module oversampling
(
	input [7:0]sclk,
	input res,
	
	input sdata,
	output [7:0]samples,
	output reg [7:0]trans
);

	reg [7:0]s1; // fixed position in FPGA
	always @(posedge sclk[0]) s1[0] <= sdata;
	always @(posedge sclk[1]) s1[1] <= sdata;
	always @(posedge sclk[2]) s1[2] <= sdata;
	always @(posedge sclk[3]) s1[3] <= sdata;
	always @(posedge sclk[4]) s1[4] <= sdata;
	always @(posedge sclk[5]) s1[5] <= sdata;
	always @(posedge sclk[6]) s1[6] <= sdata;
	always @(posedge sclk[7]) s1[7] <= sdata;

	reg [7:0]s2; // fixed position in FPGA
	always @(posedge sclk[0]) if (res) s2[0] <= 0; else s2[0] <= s1[0];
	always @(posedge sclk[0]) if (res) s2[1] <= 0; else s2[1] <= s1[1];
	always @(posedge sclk[0]) if (res) s2[2] <= 0; else s2[2] <= s1[2];
	always @(posedge sclk[0]) if (res) s2[3] <= 0; else s2[3] <= s1[3];
	always @(posedge sclk[0]) if (res) s2[4] <= 0; else s2[4] <= s1[4];
	always @(posedge sclk[1]) if (res) s2[5] <= 0; else s2[5] <= s1[5];
	always @(posedge sclk[2]) if (res) s2[6] <= 0; else s2[6] <= s1[6];
	always @(posedge sclk[3]) if (res) s2[7] <= 0; else s2[7] <= s1[7];

	reg [7:0]s3;
	reg [7:0]s4;
	always @(posedge sclk[0])
	begin
		if (res)
		begin
			s3 <= 0;
			s4 <= 0;
		end
		else
		begin
			s3 <= s2;
			s4 <= s3;
		end
	end
 
	assign samples = s4;

	// xor transition detector
	wire [7:0]t;
	assign t[0] = s3[0] ^ s3[1];
	assign t[1] = s3[1] ^ s3[2];
	assign t[2] = s3[2] ^ s3[3];
	assign t[3] = s3[3] ^ s3[4];
	assign t[4] = s3[4] ^ s3[5];
	assign t[5] = s3[5] ^ s3[6];
	assign t[6] = s3[6] ^ s3[7];
	assign t[7] = s3[7] ^ s2[0];

	always @(posedge sclk[0]) if (res) trans <= 0; else trans <= t;
	
endmodule
