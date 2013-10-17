
// synthesis translate_off
`timescale 1ns / 100ps
// synthesis translate_on


module ft245io
(
  // avalon interface
  input clk,
  input	reset_n,
  
  // avalon mm bus slave
  input  slave_read,
  input  slave_write,
  input  [3:0]slave_address,
  output [7:0]slave_readdata,
  input  [7:0]slave_writedata,

  // ft245 interface
  input  slp,      // sleep
  output snd,      // send
  input  rxf_n,    // not rx full
  input  txe_n,    // not tx empty
  output wr,       // write
  output rd_n,     // not read
  inout  [7:0]data // data
);

reg  [7:0]rxreg;   // rx register (read address=0)
reg  [7:0]txreg;   // tx register (write address =0)

reg  flag_txrdy_n; // not tx register empty
reg  flag_rxrdy;   // rx register full
wire flag_snd;
reg  flag_slp;     // sleep signal input register
reg  rxfreg;       // rx full input register
reg  txereg;       // tx empty input register

wire ctrl_snd;

// --- usb read write state machine ---------------------------------

//              nnnn _ rd, wr, oe, setdin, setdout
`define usbsm_idle    9'b0000_00000
`define usbsm_read1   9'b0001_00000
`define usbsm_read2   9'b0000_10000
`define usbsm_read3   9'b0001_10000
`define usbsm_read4   9'b0010_10000
`define usbsm_read5   9'b0000_10010
`define usbsm_read6   9'b0010_00000
`define usbsm_read7   9'b0011_00000
`define usbsm_read8   9'b0100_00000
`define usbsm_read9   9'b0101_00000
`define usbsm_read10  9'b0110_00000
`define usbsm_write1  9'b1000_01100
`define usbsm_write3  9'b1001_01100
`define usbsm_write4  9'b1010_01100
`define usbsm_write5  9'b1011_01100
`define usbsm_write6  9'b1100_00101
`define usbsm_write7  9'b1101_00000
`define usbsm_write8  9'b1110_00000
`define usbsm_write9  9'b1111_00000

reg [8:0]usbsm_state;

// state machine input signals
wire rxrdy = rxfreg && !flag_rxrdy;
wire txrdy = txereg &&  flag_txrdy_n;

// state machine output signals
assign rd_n  = !usbsm_state[4]; // usb data read
assign wr    = usbsm_state[3];  // usb data write
wire oe      = usbsm_state[2];  // usb data output enable
wire setdin  = usbsm_state[1];  // set data in ready
wire setdout = usbsm_state[0];  // set data out ready

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n)
    usbsm_state <= `usbsm_idle;
  else
    case (usbsm_state)
      `usbsm_idle:   if      (rxrdy) usbsm_state <= `usbsm_read1;
                    else if (txrdy)  usbsm_state <= `usbsm_write1;
      `usbsm_read1:  usbsm_state <= `usbsm_read2;
      `usbsm_read2:  usbsm_state <= `usbsm_read3;
      `usbsm_read3:  usbsm_state <= `usbsm_read4;
      `usbsm_read4:  usbsm_state <= `usbsm_read5;
      `usbsm_read5:  usbsm_state <= `usbsm_read6;
      `usbsm_read6:  usbsm_state <= `usbsm_read7;
      `usbsm_read7:  usbsm_state <= `usbsm_read8;
      `usbsm_read8:  usbsm_state <= `usbsm_read9;
      `usbsm_read9:  usbsm_state <= `usbsm_read10;
      `usbsm_read10: if      (txrdy) usbsm_state <= `usbsm_write1;
                    else if (rxrdy)  usbsm_state <= `usbsm_read1;
      `usbsm_write1: usbsm_state <= `usbsm_write3;
      `usbsm_write3: usbsm_state <= `usbsm_write4;
      `usbsm_write4: usbsm_state <= `usbsm_write5;
      `usbsm_write5: usbsm_state <= `usbsm_write6;
      `usbsm_write6: usbsm_state <= `usbsm_write7;
      `usbsm_write7: usbsm_state <= `usbsm_write8;
      `usbsm_write8: usbsm_state <= `usbsm_write9;
      `usbsm_write9: usbsm_state <= `usbsm_idle;
      default:       usbsm_state <= `usbsm_idle;
    endcase      
end


// --- usb send/wakeup state machine ---------------------------------
//                         nnnn _ flag_snd, snd
`define sndsm_idle  6'b0000_00
`define sndsm_sd1   6'b0000_10
`define sndsm_sd2   6'b0001_10
`define sndsm_sd3   6'b0010_10
`define sndsm_sd4   6'b0011_10
`define sndsm_sd5   6'b0100_10
`define sndsm_sd6   6'b0101_10
`define sndsm_sd7   6'b0110_10
`define sndsm_sd8   6'b0111_10
`define sndsm_sd9   6'b1000_10
`define sndsm_s1    6'b0000_11
`define sndsm_s2    6'b0001_11
`define sndsm_s3    6'b0010_11
`define sndsm_s4    6'b0011_11

reg [5:0]sndsm_state;

// state machine output signals
assign flag_snd = sndsm_state[1];  // 
assign snd      = sndsm_state[0];  //

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n)
    sndsm_state <= `sndsm_idle;
  else
    case (sndsm_state)
      `sndsm_idle: if (ctrl_snd) sndsm_state <= `sndsm_sd1;
      `sndsm_sd1:  sndsm_state <= `sndsm_sd2;
      `sndsm_sd2:  sndsm_state <= `sndsm_sd3;
      `sndsm_sd3:  sndsm_state <= `sndsm_sd4;
      `sndsm_sd4:  sndsm_state <= `sndsm_sd5;
      `sndsm_sd5:  sndsm_state <= `sndsm_sd6;
      `sndsm_sd6:  sndsm_state <= `sndsm_sd7;
      `sndsm_sd7:  sndsm_state <= `sndsm_sd8;
      `sndsm_sd8:  sndsm_state <= `sndsm_sd9;
      `sndsm_sd9:  sndsm_state <= `sndsm_s1;
      `sndsm_s1:   sndsm_state <= `sndsm_s2;
      `sndsm_s2:   sndsm_state <= `sndsm_s3;
      `sndsm_s3:   sndsm_state <= `sndsm_s4;
      `sndsm_s4:   sndsm_state <= `sndsm_idle;
      default:     sndsm_state <= `sndsm_idle;
    endcase      
end


// --- registers ----------------------------------------------------

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n)
  begin
    rxreg        <= 0;
    txreg        <= 0;
    flag_txrdy_n <= 0;
    flag_rxrdy   <= 0;
    flag_slp     <= 0;
    rxfreg       <= 0;
    txereg       <= 0;
  end
  else
  begin
    rxfreg   <= !rxf_n;
    txereg   <= !txe_n;
    flag_slp <= slp;

    if (setdin)
    begin
      rxreg <= data;
      flag_rxrdy   <= 1;
    end
    if (setdout) flag_txrdy_n <= 0;
    if (slave_read && slave_address == 0) flag_rxrdy <= 0;
    if (slave_write)
    begin
      case (slave_address)
        0: begin
             txreg <= slave_writedata;
             flag_txrdy_n <= 1;
           end
      endcase
    end
  end
end

assign slave_readdata = (slave_address == 0) ?
  rxreg : { 4'b0000, flag_snd, flag_slp, flag_rxrdy, !flag_txrdy_n};

assign ctrl_snd = slave_write && (slave_address == 1) && slave_writedata[3];

assign data = oe ? txreg : 8'bzzzzzzzz;

endmodule

