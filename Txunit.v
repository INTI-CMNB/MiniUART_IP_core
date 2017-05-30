/***********************************************************************

  RS-232 simple Tx module

  This file is part FPGA Libre project http://fpgalibre.sf.net/

  Description:
  Implements a simple 8N1 tx module for RS-232.

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

 Design unit:      TxUnit
 File name:        Txunit.v
 Note:             None
 Limitations:      None known
 Errors:           None known
 Library:          miniuart
 Dependencies:     IEEE.std_logic_1164
 Target FPGA:      Spartan
 Language:         Verilog
 Wishbone:         No
 Synthesis tools:  Xilinx Release 9.2.03i - xst J.39
 Simulation tools: GHDL [Sokcho edition] (0.2x)
 Text editor:      SETEdit 0.5.x                                      

***********************************************************************/

module TxUnit
   (
    input  clk_i,    // Clock signal
    input  reset_i,  // Reset input
    input  enable_i, // Enable input
    input  load_i,   // Load input
    output txd_o,    // RS-232 data output
    output busy_o,   // Tx Busy
    output wip_o,    // Work In Progress (transmitting or w/data to)
    input  [7:0] datai_i); // Byte to transmit

reg [7:0] tbuff_r; // transmit buffer
reg [7:0] t_r;     // transmit register
reg loaded_r=0;    // Buffer loaded
reg txd_r=1;       // Tx buffer ready
reg [3:0] bitpos;  // Bit position in the frame (0 to 10)

assign busy_o=load_i | loaded_r;
assign txd_o=txd_r;
assign wip_o=loaded_r || bitpos;

// Tx process
always @(posedge clk_i)
begin : TxProc
  if (reset_i)
     begin
     loaded_r <= 0;
     bitpos <= 0;
     txd_r <= 1;
     end
  else // reset_i==0
     begin
     if (load_i)
        begin
        tbuff_r  <= datai_i;
        loaded_r <= 1;
        end
     if (enable_i)
        begin
        case (bitpos)
          0: // idle or stop bit
           begin
           txd_r <= 1;
           if (loaded_r) // start transmit. next is start bit
              begin
              t_r <= tbuff_r;
              loaded_r <= 0;
              bitpos <= 1;
              end
           end
          1: // Start bit
           begin
           txd_r  <= 0;
           bitpos <= 2;
           end
          default:
           begin
           txd_r <= t_r[bitpos-2]; // Serialisation of t_r
           bitpos <= bitpos+1;
           end
        endcase
        if (bitpos==9) // bit8. next is stop bit
           bitpos <= 0;
        end // enable_i
     end // reset_i==0
end // process TxProc
endmodule // TxUnit

