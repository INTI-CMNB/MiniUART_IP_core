Copyright (c) 2005 Juan Pablo D. Borgna <jpborgna en inti gov ar>
Copyright (c) 2006-2008 Salvador E. Tropea <salvador en inti gov ar>
Copyright (c) 2005-2008 Instituto Nacional de Tecnología Industrial
Para la miniuart2:
Author : Philippe CARTON     philippe.carton2@libertysurf.fr
Copyright (c) notice: This core adheres to the GNU public license

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 2.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
 02111-1307, USA

Dependencies: bakalint (Optional)
              xtracth (.h & .inc generator)
              wb_counter.counters (For the version w/baurate generator)
              mems.devices (For the version w/FIFO)
  Para los bancos de pruebas:
              c.stdio_h (Standard C library for VHDL)
              wb_handler.WishboneTB (Wishbone Handler)
              Wishbone Builder
              ghdl

  This core is based on the miniuart from OpenCores. It have some additions
and fixes.
  The included cores are an UART with fixed baudrate, another with
programmable baudrate and another with FIFO. All are Wishbone compatible.
  The original documentation can be found in the doc directory. For more
information about the programmable baudrate generator consult the wb_counter
documentation.
  If you wish to simulate with GHDL just use make.


Note about FIFO changes:
------------------------

If FIFO memories of the library "mems" will be used, take into account that
has implemented a change in the behavior of the signal "avail_o" (data
available), delaying their passage to '1' by one clock cycle. Support for
UART_F has been tested successfully, but not intensively.
For more information, see (.. / MEMS / FIFO.txt).


Cores in the UART package:
--------------------------

UART_C       Rx+Tx+Fixed Baudrate(optional)+Wishbone
UART_F       Rx+Tx+Fixed Baudrate(optional)+Wishbone+FIFO(mems.devices)
UART_WB      Rx+Tx+Programmable Baudrate(wb_counter.counters)+Wishbone
RxUnit       UART Rx core
TxUnit       UART Tx core
Counter      Fixed baudrate generator
Synchroniser To make a signal synchronous with a provided clock


Registers:
----------

All are 8 bits. This is just a resume to show the difference with the docs.

Address   | Mode | Name         | Description
-----------------------------------------------------------------------------
    0     |   R  | UART_RX      | Receive Register
-----------------------------------------------------------------------------
    0     |   W  | UART_TX      | Transmit Register
-----------------------------------------------------------------------------
    1     |   R  | UART_ST      | Status Register
          |      |              | bit 1: Byte received (1=received)
          |      |              | bit 0: Ready to transmit (1=ready)
-----------------------------------------------------------------------------
    2     |   W  | UART_PRER_LO | Clock Prescaler Low (only for UART_WB)
-----------------------------------------------------------------------------
    3     |   W  | UART_PRER_HI | Clock Prescaler High (only for UART_WB)
-----------------------------------------------------------------------------


Sources:
--------

Rxunit.vhdl        RxUnit
Txunit.vhdl        TxUnit
miniuart.vhdl      UART_C
miniuart_fifo.vhdl UART_F
miniuart_pkg.vhdl  Declarations for UART package
miniuart_wb.vhdl   UART_WB
utils.vhdl         Counter, Synchroniser


Testbenches:
------------

testbench/miniuart_ebr_tb.vhdl   UART_C+external Wishbone baudrate generator
testbench/miniuart_fifo_tb.vhdl  UART_F
testbench/miniuart_tb.vhdl       UART_C
testbench/miniuart_wb_tb.vhdl    UART_WB


Generics:
---------

UART_C and UART_F uses a fixed baudrate generator controlled by the following
generic:
BRDIVISOR: integer range 0 to 65535:=1; -- Baud rate divisor
To disable it just assign 1 (default) and connect a baudrate generator to
br_clk_i.

