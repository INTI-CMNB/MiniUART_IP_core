------------------------------------------------------------------------------
----                                                                      ----
----  Mini UART with FIFO                                                 ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  This miniuart has a FIFO.                                           ----
----  Note: FIFO_ADDR_W takes 2 Spartan 2 BRAMs as default.               ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Juan Pablo D. Borgna, jpborgna inti.gov.ar                      ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2005 Juan Pablo D. Borgna                              ----
---- Copyright (c) 2008 Salvador E. Tropea                                ----
---- Copyright (c) 2005-2008 Instituto Nacional de Tecnología Industrial  ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      UART_F(Behaviour)    (Entity and architecture)     ----
---- File name:        miniuart_fifo.vhdl                                 ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          None                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   miniuart.UART                                      ----
----                   mems.devices                                       ----
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
library mems;
use mems.devices.all;

entity UART_F is
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
end entity UART_F;

-- Architecture for UART for synthesis
architecture Behaviour of UART_F is
   constant FIFO_DEPTH : natural:=2**FIFO_ADDR_W;

   signal status_r : std_logic_vector(7 downto 0); -- Status register
   signal ena_rx   : std_logic;  -- Enable RX unit
   signal ena_tx   : std_logic;  -- Enable TX unit
   signal rxav     : std_logic;  -- Data Received
   signal txbusy   : std_logic;  -- Transmiter Busy
   signal load_r   : std_logic;  -- Load transmit buffer

   --FIFO handle signals
   signal tx_data  : std_logic_vector(7 downto 0);
   signal tx_aval  : std_logic;
   signal tx_full  : std_logic;
   signal tx_write : std_logic;
  
   signal rx_read  : std_logic;
   signal rx_data  : std_logic_vector(7 downto 0);
   signal u2f_data : std_logic_vector(7 downto 0); -- UART to FIFO
   signal rx_aval  : std_logic;
   signal rx_we    : std_logic;
   signal rx_full  : std_logic;
begin
   Uart_Rxrate : BRGen -- Baud Rate adjust
      generic map(COUNT => BRDIVISOR)
      port map(
         clk_i => wb_clk_i, reset_i => wb_rst_i, ce_i => br_clk_i,
         o_o => ena_rx);
 
   Uart_Txrate : BRGen -- 4 Divider for Tx
      generic map(COUNT => 4)
      port map(
         clk_i => wb_clk_i, reset_i => wb_rst_i, ce_i => ena_rx,
         o_o => ena_tx);
 
   Uart_TxUnit : TxUnit
      port map(
         clk_i => wb_clk_i, reset_i => wb_rst_i, enable_i => ena_tx,
         load_i => load_r, txd_o => txd_pad_o, busy_o => txbusy,
         datai_i => tx_data);
 
   Uart_RxUnit : RxUnit
      port map(
         clk_i => br_clk_i, reset_i => wb_rst_i, enable_i => ena_rx,
         read_i => rxav, rxd_i => rxd_pad_i, rxav_o => rxav,
         datao_o => u2f_data);
 
   tx_fifo: FIFO
      generic map(
         ADDR_W => FIFO_ADDR_W, DATA_W => 8, DEPTH => FIFO_DEPTH)
      port map(
         clk_i => wb_clk_i, rst_i => wb_rst_i, we_i => tx_write,
         re_i => load_r, datai_i => wb_dat_i, datao_o => tx_data,
         full_o => tx_full, avail_o => tx_aval);

   rx_fifo: FIFO
      generic map(
         ADDR_W => FIFO_ADDR_W, DATA_W => 8, DEPTH => FIFO_DEPTH)
      port map(
         clk_i => wb_clk_i, rst_i => wb_rst_i, we_i => rxav,
         re_i => rx_read, datai_i => u2f_data, datao_o => rx_data,
         full_o => rx_full, avail_o => rx_aval);
 
   load_txU:
   process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         load_r <='0';
         if load_r='0' and wb_rst_i='0' then
            load_r <= tx_aval and not(txbusy);
         end if;
      end if;
   end process load_txU;
 
   inttx_o <= not(tx_full);
   intrx_o <= rx_aval;
   status_r(0) <= not(tx_full);
   status_r(1) <= rx_aval;
   status_r(2) <= rx_full;
   status_r(7 downto 3) <= "00000";
  
   tx_write <= wb_stb_i and     wb_we_i  and not(wb_adr_i(0));
   rx_read  <= wb_stb_i and not(wb_we_i) and not(wb_adr_i(0));
  
   wb_ack_o <= wb_stb_i;
   wb_dat_o <= rx_data when wb_adr_i="0" else  -- read byte from rx
               status_r;                           -- read status reg
end architecture Behaviour;
