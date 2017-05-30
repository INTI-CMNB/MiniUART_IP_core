/***********************************************************************

  RS-232 baudrate generator

  This file is part FPGA Libre project http://fpgalibre.sf.net/

  Description:
  This counter is a parametrizable clock divider. The count value is
  the generic parameter COUNT. It has a chip enable ce_i input.
  (will count only if CE is high).
  When it overflows, will emit a pulse on o_o.

  To Do:
  -

  Author:
    - Philippe Carton, philippe.carton2 libertysurf.fr
    - Juan Pablo Daniel Borgna, jpdborgna gmail.com
    - Salvador E. Tropea, salvador inti.gob.ar

------------------------------------------------------------------------------

 Copyright (c) 2001-2003 Philippe Carton
 Copyright (c) 2005 Juan Pablo Daniel Borgna
 Copyright (c) 2005-2017 Salvador E. Tropea
 Copyright (c) 2005-2017 Instituto Nacional de Tecnología Industrial

 Distributed under the GPL v2 or newer license

------------------------------------------------------------------------------

 Design unit:      BRGen
 File name:        br_gen.v
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

module BRGen
  #(
    parameter COUNT=1) // Count revolution
   (
    input  clk_i,    // Clock
    input  reset_i,  // Reset input
    input  ce_i,     // Chip Enable
    output o_o); // Output

generate
if (COUNT==1)
   begin : CountWire
   assign o_o=reset_i ? 0 : ce_i;
   end
else
   begin : CountGen
   localparam integer CNT_BITS=$clog2(COUNT);
   reg [CNT_BITS-1:0] cnt;
   reg o;
   always @(posedge clk_i)
   begin : Counter
     o <= 0;
     if (reset_i)
        cnt <= COUNT-1;
     else if (ce_i)
        begin
        if (cnt)
           cnt <= cnt-1;
        else
           begin
           o <= 1;
           cnt <= COUNT-1;
           end
        end // ce_i='1'
   end // Counter
   assign o_o=o;
   end
endgenerate

endmodule // BRGen

