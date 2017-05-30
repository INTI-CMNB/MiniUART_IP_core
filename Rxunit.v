/***********************************************************************

  RS-232 simple Rx module

  This file is part FPGA Libre project http://fpgalibre.sf.net/

  Description:
  Implements a simple 8N1 rx module for RS-232.

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

 Design unit:      RxUnit
 File name:        Rxunit.v
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

module RxUnit
   (
    input        clk_i,    // System clock signal
    input        reset_i,  // Reset input (sync)
    input        enable_i, // Enable input (rate*4)
    input        read_i,   // Received Byte Read
    input        rxd_i,    // RS-232 data input
    output       rxav_o,   // Byte available
    output [7:0] datao_o); // Byte received

reg [7:0] r_r;  // Receive register
reg bavail_r=0; // Byte received
reg [7:0] datao_r; // Last byte received

assign rxav_o=bavail_r;

// Rx Process
reg [3:0] bitpos;    // Position of the bit in the frame (0 to 10)
reg [1:0] samplecnt; // Count from 0 to 3 in each bit
always @(posedge clk_i)
begin : RxProc
  if (reset_i)
     begin
     bavail_r <= 0;
     bitpos=0;
     end
  else // reset_i==0
     begin
     if (read_i)
        bavail_r <= 0;
     if (enable_i)
        begin
        case (bitpos)
           0: // idle
           begin
           bavail_r <= 0;
           if (!rxd_i) // Start Bit
              begin
              samplecnt=0;
              bitpos=1;
              end
           end
          10: // Stop Bit
           begin
           bitpos=0;      // next is idle
           bavail_r <= 1; // Indicate byte received
           datao_r  <= r_r; // Store received byte
           end
          default:
           begin
           if (samplecnt==1 && bitpos>=2) // Sample RxD on 1
              r_r[bitpos-2] <= rxd_i; // Deserialisation
           if (samplecnt==3) // Increment BitPos on 3
              bitpos=bitpos+1;
           end
        endcase
        if (samplecnt==3)
           samplecnt=0;
        else
           samplecnt=samplecnt+1;
        end // enable_i='1'
     end // reset_i==0
end // RxProc

assign datao_o=datao_r;

endmodule // RxUnit

