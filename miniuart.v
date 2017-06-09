/***********************************************************************

  RS-232 simple Rx/Tx module WISHBONE compatible

  This file is part FPGA Libre project http://fpgalibre.sf.net/

  Description:
  Implements a simple 8N1 rx/tx module for RS-232.

  To Do:
  -

  Author:
    - Philippe Carton, philippe.carton2 libertysurf.fr
    - Juan Pablo Daniel Borgna, jpdborgna gmail.com
    - Salvador E. Tropea, salvador inti.gob.ar

----------------------------------------------------------------------

 Copyright (c) 2001-2003 Philippe Carton
 Copyright (c) 2005 Juan Pablo Daniel Borgna
 Copyright (c) 2005-2017 Salvador E. Tropea
 Copyright (c) 2005-2017 Instituto Nacional de Tecnología Industrial

 Distributed under the GPL v2 or newer license

----------------------------------------------------------------------

 Design unit:      UART_C
 File name:        miniuart.v
 Note:             None
 Limitations:      None known
 Errors:           None known
 Library:          miniuart
 Dependencies:     IEEE.std_logic_1164
                   miniuart.UART
 Target FPGA:      Spartan
 Language:         Verilog
 Wishbone:         Slave
 Synthesis tools:  Xilinx Release 9.2.03i - xst J.39
 Simulation tools: GHDL [Sokcho edition] (0.2x)
 Text editor:      SETEdit 0.5.x

----------------------------------------------------------------------

 Wishbone Datasheet

  1 Revision level                      B.3
  2 Type of interface                   SLAVE
  3 Defined signal names                RST_I => wb_rst_i
                                        CLK_I => wb_clk_i
                                        ADR_I => wb_adr_i
                                        DAT_I => wb_dat_i
                                        DAT_O => wb_dat_o
                                        WE_I  => wb_we_i
                                        ACK_O => wb_ack_o
                                        STB_I => wb_stb_i
  4 ERR_I                               Unsupported
  5 RTY_I                               Unsupported
  6 TAGs                                None
  7 Port size                           8-bit
  8 Port granularity                    8-bit
  9 Maximum operand size                8-bit
 10 Data transfer ordering              N/A
 11 Data transfer sequencing            Undefined
 12 Constraints on the CLK_I signal     None

************************************************************************/

module UART_C
   #(
     parameter BRDIVISOR=1,  // Baud rate divisor
     parameter WIP_ENABLE=0, // WIP flag enable
     parameter AUX_ENABLE=0) // Aux. register enable
   (
    // WISHBONE signals
    input        wb_clk_i,   // Clock
    input        wb_rst_i,   // Reset input
    input  [0:0] wb_adr_i,   // Adress bus
    output [7:0] wb_dat_o,   // DataOut Bus
    input  [7:0] wb_dat_i,   // DataIn Bus
    input        wb_we_i,    // Write Enable
    input        wb_stb_i,   // Strobe
    output       wb_ack_o,   // Acknowledge
    // The spare register, for external uses
    output [7:0] aux_reg_o,
    // Process signals
    output       inttx_o,    // Transmit interrupt: indicate waiting for Byte
    output       intrx_o,    // Receive interrupt: indicate Byte received
    input        br_clk_i,   // Clock used for Transmit/Receive
    output       txd_pad_o,  // Tx RS232 Line
    input        rxd_pad_i); // Rx RS232 Line

wire [7:0] rxdata; // Last Byte received
wire [7:0] sreg;   // Status register
wire       ena_rx; // Enable RX unit
wire       ena_tx; // Enable TX unit
wire       rxav;   // Data Received
wire       txbusy; // Transmiter Busy
wire       reada;  // Read receive buffer
wire       loada;  // Load transmit buffer
wire       wip;    // Tx UART is working

BRGen #(.COUNT(BRDIVISOR)) Uart_Rxrate // Baud Rate adjust
  (.clk_i(wb_clk_i), .reset_i(wb_rst_i), .ce_i(br_clk_i),
   .o_o(ena_rx));

BRGen #(.COUNT(4)) Uart_Txrate // 4 Divider for Tx
  (.clk_i(wb_clk_i), .reset_i(wb_rst_i), .ce_i(ena_rx),
   .o_o(ena_tx));

TxUnit Uart_TxUnit
  (.clk_i(wb_clk_i), .reset_i(wb_rst_i), .enable_i(ena_tx),
   .load_i(loada), .txd_o(txd_pad_o), .busy_o(txbusy),
   .datai_i(wb_dat_i), .wip_o(wip));

RxUnit Uart_RxUnit
  (.clk_i(wb_clk_i), .reset_i(wb_rst_i), .enable_i(ena_rx),
   .read_i(reada), .rxd_i(rxd_pad_i), .rxav_o(rxav),
   .datao_o(rxdata));

assign inttx_o=!txbusy;
assign intrx_o=rxav;
assign sreg[0]=!txbusy;
assign sreg[1]=rxav;
assign sreg[2]=WIP_ENABLE & wip;
assign sreg[7:3]=0;

// Implements WishBone data exchange.
// Clocked on rising edge. Synchronous Reset RST_I
assign loada=wb_stb_i &&  wb_we_i && !wb_adr_i;
assign reada=wb_stb_i && !wb_we_i && !wb_adr_i;

assign wb_ack_o=wb_stb_i;
assign wb_dat_o=wb_adr_i ? sreg : rxdata; // read status reg/byte from rx

generate
if (AUX_ENABLE)
   begin : aux_reg_enabled
   reg  [7:0] aux_reg_r; // Spare register
   always @(posedge wb_clk_i)
   begin : do_aux_reg
     if (wb_rst_i)
        aux_reg_r <= 0;
     else if (wb_stb_i && wb_we_i && wb_adr_i)
        aux_reg_r <= wb_dat_i;
   end // do_aux_reg
   assign aux_reg_o=aux_reg_r;
   end // aux_reg_enabled
else
   begin : aux_reg_disabled
   assign aux_reg_o=0;
   end
endgenerate

endmodule // UART_C
