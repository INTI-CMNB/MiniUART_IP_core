------------------------------------------------------------------------------
----                                                                      ----
----  Mini UART package file                                              ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  Package file to ease the use of the miniuart.                       ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Juan Pablo D. Borgna, jpborgna en inti.gov.ar                   ----
----    - Salvador E. Tropea, salvador en inti gov ar                     ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2005 Juan Pablo D. Borgna <jpborgna en inti.gov.ar>    ----
---- Copyright (c) 2006-2008 Salvador E. Tropea <salvador en inti gov ar> ----
---- Copyright (c) 2005-2008 Instituto Nacional de Tecnología Industrial  ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      UART (Package)                                     ----
---- File name:        miniuart_pkg.vhdl                                  ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          None                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
---- Target FPGA:      None                                               ----
---- Language:         VHDL                                               ----
---- Wishbone:         None                                               ----
---- Synthesis tools:  None                                               ----
---- Simulation tools: GHDL [Sokcho edition] (0.1x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package UART is
   @component:miniuart.vhdl@

   @component:miniuart_fifo.vhdl@

   @component:miniuart_wb.vhdl@

   @component:Txunit.vhdl@

   @component:Rxunit.vhdl@

   @component:utils.vhdl@

   -- EXPORT CONSTANTS
   constant UART_RX      : std_logic_vector(7 downto 0):="00000000";
   constant UART_TX      : std_logic_vector(7 downto 0):="00000000";
   constant UART_ST      : std_logic_vector(7 downto 0):="00000001";
   constant UART_PRER_LO : std_logic_vector(7 downto 0):="00000010";
   constant UART_PRER_HI : std_logic_vector(7 downto 0):="00000011";
   constant UART_INTTX   : integer:=0;
   constant UART_INTRX   : integer:=1;
   constant UART_RXFULL  : integer:=2;
   -- END EXPORT CONSTANTS
end package UART;



