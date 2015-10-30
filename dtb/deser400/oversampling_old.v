// oversampling.v


module oversampling
(
	input [7:0]sclk,
	
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

	reg [7:0]s2;
	always @(posedge sclk[0]) s2[0] <= s1[0];
	always @(posedge sclk[0]) s2[1] <= s1[1];
	always @(posedge sclk[0]) s2[2] <= s1[2];
	always @(posedge sclk[0]) s2[3] <= s1[3];
	always @(posedge sclk[1]) s2[4] <= s1[4];
	always @(posedge sclk[2]) s2[5] <= s1[5];
	always @(posedge sclk[3]) s2[6] <= s1[6];
	always @(posedge sclk[4]) s2[7] <= s1[7];

	reg [7:0]s3;
	always @(posedge sclk[0]) s3[0] <= s2[0];
	always @(posedge sclk[0]) s3[1] <= s2[1];
	always @(posedge sclk[0]) s3[2] <= s2[2];
	always @(posedge sclk[0]) s3[3] <= s2[3];
	always @(posedge sclk[0]) s3[4] <= s2[4];
	always @(posedge sclk[0]) s3[5] <= s2[5];
	always @(posedge sclk[0]) s3[6] <= s2[6];
	always @(posedge sclk[1]) s3[7] <= s2[7];


	reg [7:0]s4;
	always @(posedge sclk[0])
	begin
		s4[0] <= s3[0];
		s4[1] <= s3[1];
		s4[2] <= s3[2];
		s4[3] <= s3[3];
		s4[4] <= s3[4];
		s4[5] <= s3[5];
		s4[6] <= s3[6];
		s4[7] <= s3[7];
	end
 
	assign samples = s4;

	// xor transition detector
	wire [7:0]t;
	assign t[0] = s4[0] ^ s4[1];
	assign t[1] = s4[1] ^ s4[2];
	assign t[2] = s4[2] ^ s4[3];
	assign t[3] = s4[3] ^ s4[4];
	assign t[4] = s4[4] ^ s4[5];
	assign t[5] = s4[5] ^ s4[6];
	assign t[6] = s4[6] ^ s4[7];
	assign t[7] = s4[7] ^ s3[0];

	always @(posedge sclk[0]) trans <= t;
	
endmodule
