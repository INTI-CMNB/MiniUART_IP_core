------------------------------------------------------------------------------
----                                                                      ----
----  Mini UART with BR Divisor configurable through WISHBONE             ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  This is a miniuart UART_C with an extra register to configure the   ----
----  baud rate divisor so the baudrate can be changed while working      ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Juan Pablo D. Borgna, jpborgna@inti.gov.ar                      ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2005 Juan Pablo D. Borgna <jpborgna@inti.gov.ar>       ----
---- Copyright (c) 2008 Salvador E. Tropea                                ----
---- Copyright (c) 2005-2008 Instituto Nacional de Tecnología Industrial  ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      UART_WB(Behaviour)   (Entity and architecture)     ----
---- File name:        miniuart_wb.vhdl                                   ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          None                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
----                   miniuart.UART                                      ----
----                   wb_counter.counters                                ----
---- Target FPGA:      None                                               ----
---- Language:         VHDL                                               ----
---- Wishbone:         None                                               ----
---- Synthesis tools:  None                                               ----
---- Simulation tools: GHDL [Sokcho edition] (0.1x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Wishbone Datasheet                                                   ----
----                                                                      ----
----  1 Revision level                      B.3                           ----
----  2 Type of interface                   SLAVE                         ----
----  3 Defined signal names                RST_I => wb_rst_i             ----
----                                        CLK_I => wb_clk_i             ----
----                                        ADR_I => wb_adr_i             ----
----                                        DAT_I => wb_dat_i             ----
----                                        DAT_O => wb_dat_o             ----
----                                        WE_I  => wb_we_i              ----
----                                        ACK_O => wb_ack_o             ----
----                                        STB_I => wb_stb_i             ----
----  4 ERR_I                               Unsupported                   ----
----  5 RTY_I                               Unsupported                   ----
----  6 TAGs                                None                          ----
----  7 Port size                           8-bit                         ----
----  8 Port granularity                    8-bit                         ----
----  9 Maximum operand size                8-bit                         ----
---- 10 Data transfer ordering              N/A                           ----
---- 11 Data transfer sequencing            Undefined                     ----
---- 12 Constraints on the CLK_I signal     None                          ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
   use IEEE.std_logic_1164.all;
library miniuart;
use miniuart.UART.all;
library wb_counter;
use wb_counter.counters.all;

entity UART_WB is
  port (
     -- Wishbone signals
     wb_clk_i  : in  std_logic;  -- clock
     wb_rst_i  : in  std_logic;  -- Reset input
     wb_adr_i  : in  std_logic_vector(1 downto 0); -- Adress bus
     wb_dat_i  : in  std_logic_vector(7 downto 0); -- DataIn Bus
     wb_dat_o  : out std_logic_vector(7 downto 0); -- DataOut Bus
     wb_we_i   : in  std_logic;  -- Write Enable
     wb_stb_i  : in  std_logic;  -- Strobe
     wb_ack_o  : out std_logic;  -- Acknowledge
     -- Process signals
     inttx_o   : out std_logic;  -- Transmit interrupt: indicate waiting for Byte
     intrx_o   : out std_logic;  -- Receive interrupt: indicate Byte received
     br_clk_i  : in  std_logic;  -- Clock used for Transmit/Receive
     txd_pad_o : out std_logic;  -- Tx RS232 Line
     rxd_pad_i : in  std_logic); -- Rx RS232 Line
end entity UART_WB;

-- Architecture for UART for synthesis
architecture Behaviour of UART_WB is
   signal pulse    : std_logic;
   signal cnt_stb  : std_logic;
   signal uart_stb : std_logic;
   signal cnt_ack  : std_logic;
   signal uart_ack : std_logic;
   signal uart_adr : std_logic_vector(0 downto 0);
   signal cnt_adr  : std_logic_vector(0 downto 0);
begin
   UART_RxRate: SCounter
      port map(
         --Wishbone signals
         wb_clk_i => wb_clk_i, wb_rst_i => wb_rst_i, wb_adr_i => cnt_adr,
         wb_dat_i => wb_dat_i, wb_we_i => wb_we_i, wb_stb_i => cnt_stb,
         wb_ack_o => cnt_ack,
         --Counter signals
         ce_i => br_clk_i, o_o => pulse);

   miniUART: UART_C
      generic map(BRDIVISOR => 1) --Use the baudrate gen through Scounter
      port map(--Wishbone signals
         wb_clk_i => wb_clk_i, wb_rst_i => wb_rst_i, wb_adr_i => uart_adr,
         wb_dat_i => wb_dat_i, wb_dat_o => wb_dat_o, wb_we_i => wb_we_i,
         wb_stb_i => uart_stb, wb_ack_o => uart_ack,
         --UART signals
         inttx_o => inttx_o, intrx_o => intrx_o, br_clk_i => pulse,
         txd_pad_o => txd_pad_o, rxd_pad_i => rxd_pad_i);

   uart_adr(0) <= wb_adr_i(0);
   cnt_adr(0)  <= wb_adr_i(0);
   uart_stb    <= not(wb_adr_i(1)) and wb_stb_i;
   cnt_stb     <= wb_adr_i(1) and wb_stb_i;
   wb_ack_o    <= cnt_ack or uart_ack;
end architecture Behaviour;
