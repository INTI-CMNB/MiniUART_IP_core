------------------------------------------------------------------------------
----                                                                      ----
----  Mini UART package file                                              ----
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
---- Covered by the GPL license.                                          ----
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
   component UART_C is
     generic(
        BRDIVISOR  : positive:=1;     -- Baud rate divisor
        WIP_ENABLE : boolean:=false;  -- WIP flag enable
        AUX_ENABLE : boolean:=false); -- Aux. register enable
     port (
        -- Wishbone signals
        wb_clk_i  : in  std_logic;  -- clock
        wb_rst_i  : in  std_logic;  -- Reset input
        wb_adr_i  : in  std_logic_vector(0 downto 0); -- Adress bus
        wb_dat_i  : in  std_logic_vector(7 downto 0); -- DataIn Bus
        wb_dat_o  : out std_logic_vector(7 downto 0); -- DataOut Bus
        wb_we_i   : in  std_logic;  -- Write Enable
        wb_stb_i  : in  std_logic;  -- Strobe
        wb_ack_o  : out std_logic;  -- Acknowledge
        -- The spare register, for external uses
        aux_reg_o : out std_logic_vector(7 downto 0);
        -- Process signals
        inttx_o   : out std_logic;  -- Transmit interrupt: indicate waiting for Byte
        intrx_o   : out std_logic;  -- Receive interrupt: indicate Byte received
        br_clk_i  : in  std_logic;  -- Clock used for Transmit/Receive
        txd_pad_o : out std_logic;  -- Tx RS232 Line
        rxd_pad_i : in  std_logic); -- Rx RS232 Line
   end component UART_C;

   component UART_F is
      generic(
         FIFO_ADDR_W : natural:=9; -- FIFO size
         BRDIVISOR   : positive:=1); -- Baud rate divisor
      port (
         -- Wishbone signals
         wb_clk_i  : in  std_logic;  -- clock
         wb_rst_i  : in  std_logic;  -- Reset input
         wb_adr_i  : in  std_logic_vector(0 downto 0); -- Adress bus
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
   end component UART_F;

   component UART_WB is
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
   end component UART_WB;

   component TxUnit is
     port (
        clk_i    : in  std_logic;  -- Clock signal
        reset_i  : in  std_logic;  -- Reset input
        enable_i : in  std_logic;  -- Enable input
        load_i   : in  std_logic;  -- Load input
        txd_o    : out std_logic;  -- RS-232 data output
        busy_o   : out std_logic;  -- Tx Busy
        wip_o    : out std_logic;  -- Work In Progress (transmitting or w/data to)
        datai_i  : in  std_logic_vector(7 downto 0)); -- Byte to transmit
   end component TxUnit;

   component RxUnit is
      port(
         clk_i    : in  std_logic;  -- System clock signal
         reset_i  : in  std_logic;  -- Reset input (sync)
         enable_i : in  std_logic;  -- Enable input (rate*4)
         read_i   : in  std_logic;  -- Received Byte Read
         rxd_i    : in  std_logic;  -- RS-232 data input
         rxav_o   : out std_logic;  -- Byte available
         datao_o  : out std_logic_vector(7 downto 0)); -- Byte received
   end component RxUnit;

   component BRGen is
     generic(
        COUNT : positive);-- Count revolution
     port (
        clk_i   : in  std_logic;  -- Clock
        reset_i : in  std_logic;  -- Reset input
        ce_i    : in  std_logic;  -- Chip Enable
        o_o     : out std_logic); -- Output
   end component BRGen;

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



