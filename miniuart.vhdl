------------------------------------------------------------------------------
----                                                                      ----
----  RS-232 simple Rx/Tx module WISHBONE compatible                      ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  Implements a simple 8N1 rx/tx module for RS-232.                    ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Philippe Carton, philippe.carton2 libertysurf.fr                ----
----    - Juan Pablo Daniel Borgna, jpdborgna gmail.com                   ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2001-2003 Philippe Carton                              ----
---- Copyright (c) 2005 Juan Pablo Daniel Borgna                          ----
---- Copyright (c) 2005-2017 Salvador E. Tropea                           ----
---- Copyright (c) 2005-2017 Instituto Nacional de Tecnología Industrial  ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      UART_C(Behaviour) (Entity and architecture)        ----
---- File name:        miniuart.vhdl                                      ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          miniuart                                           ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   miniuart.UART                                      ----
---- Target FPGA:      Spartan                                            ----
---- Language:         VHDL                                               ----
---- Wishbone:         No                                                 ----
---- Synthesis tools:  Xilinx Release 9.2.03i - xst J.39                  ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
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

entity UART_C is
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
end entity UART_C;

-- Architecture for UART for synthesis
architecture Behaviour of UART_C is
   signal rxdata : std_logic_vector(7 downto 0); -- Last Byte received
   signal sreg   : std_logic_vector(7 downto 0); -- Status register
   signal ena_rx : std_logic;  -- Enable RX unit
   signal ena_tx : std_logic;  -- Enable TX unit
   signal rxav   : std_logic;  -- Data Received
   signal txbusy : std_logic;  -- Transmiter Busy
   signal reada  : std_logic;  -- Read receive buffer
   signal loada  : std_logic;  -- Load transmit buffer
   signal wip    : std_logic;  -- Tx UART is working
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
         load_i => loada, txd_o => txd_pad_o, busy_o => txbusy,
         datai_i => wb_dat_i, wip_o => wip);
 
   Uart_RxUnit : RxUnit
      port map(
         clk_i => wb_clk_i, reset_i => wb_rst_i, enable_i => ena_rx,
         read_i => reada, rxd_i => rxd_pad_i, rxav_o => rxav,
         datao_o => rxdata);
 
   inttx_o <= not txbusy;
   intrx_o <= rxav;
   sreg(0) <= not txbusy;
   sreg(1) <= rxav;
   sreg(2) <= wip when WIP_ENABLE else '0';
   sreg(7 downto 3) <= "00000";
   
   -- Implements WishBone data exchange.
   -- Clocked on rising edge. Synchronous Reset RST_I
   loada <= '1' when wb_stb_i='1' and wb_we_i='1' and wb_adr_i="0" else '0';
   reada <= '1' when wb_stb_i='1' and wb_we_i='0' and wb_adr_i="0" else '0';
 
   wb_ack_o <= wb_stb_i;
   wb_dat_o <= rxdata when wb_adr_i="0" else  -- read byte from rx
               sreg;                          -- read status reg

   aux_reg_enabled:
   if AUX_ENABLE generate
      do_aux_reg:
      process (wb_clk_i)
      begin
         if rising_edge(wb_clk_i) then
            if wb_rst_i='1' then
               aux_reg_o <= (others => '0');
            elsif wb_stb_i='1' and wb_we_i='1' and wb_adr_i="1" then
               aux_reg_o <= wb_dat_i;
            end if;
         end if;
      end process do_aux_reg;
   end generate aux_reg_enabled;

   aux_reg_disabled:
   if AUX_ENABLE generate
      aux_reg_o <= (others => '0');
   end generate aux_reg_disabled;

end architecture Behaviour;
