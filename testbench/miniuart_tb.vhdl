------------------------------------------------------------------------------
----                                                                      ----
----  Mini UART testbench                                                 ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  UART_C testbench.                                                   ----
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
---- Design unit:      TestBench(Bench) (Entity and architecture)         ----
---- File name:        miniuart_tb.vhdl                                   ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          None                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
----                   utils.stdio                                        ----
----                   wbhandler.WishboneTB                               ----
----                   miniuart.UART                                      ----
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
library utils;
use utils.stdio.all;
library wb_handler;
use wb_handler.WishboneTB.all;
library miniuart;
use miniuart.UART.all;

entity TestBench is
end entity TestBench;

architecture Bench of TestBench is

   constant CLKPERIOD : time:=40 ns;
   constant WB_INTS   : boolean:=false;
   constant TEST_B1   : std_logic_vector(7 downto 0):="01010101";
   constant TEST_B2   : std_logic_vector(7 downto 0):="01100110";
   
   signal wb_rst   : std_logic:='1';
   signal wb_clk   : std_logic;
   signal wb_adr   : std_logic_vector(7 downto 0);
   signal adr      : std_logic_vector(0 downto 0);
   signal wb_dati  : std_logic_vector(7 downto 0):=(others => 'Z');
   signal wb_dato  : std_logic_vector(7 downto 0);
   signal wb_we    : std_logic;
   signal wb_stb   : std_logic;
   signal wb_cyc   : std_logic;
   signal wb_ack   : std_logic:='0';

   signal wbi      : wb_bus_i_type;
   signal wbo      : wb_bus_o_type;
   
   --UART
   signal inttx    : std_logic;
   signal intrx    : std_logic;
   signal txd_pad  : std_logic;
   signal rxd_pad  : std_logic;

   signal stop_clock : std_logic:='0';
begin
   --Loopback comunication lines
   rxd_pad <= txd_pad;

   adr <= wb_adr(0 downto 0);

   -- Clock
   p_clks:
   process
   begin
      wb_clk <= '0';
      wait for CLKPERIOD/2;
      wb_clk <= '1';
      wait for CLKPERIOD/2;
      if stop_clock='1' then
         wait;
      end if;
   end process p_clks;

   -- Reset pulse
   p_reset:
   process
   begin
      wb_rst <= '1';
      wait until rising_edge(wb_clk);
      wb_rst <= '0' after 150 ns;
      wait;
   end process p_reset;

   -- Connect the records to the individual signals
   wbi.clk  <= wb_clk;
   wbi.rst  <= wb_rst;
   wbi.dato <= wb_dato;
   wbi.ack  <= wb_ack;

   wb_stb   <= wbo.stb;
   wb_we    <= wbo.we;
   wb_adr   <= wbo.adr;
   wb_dati  <= wbo.dati;
   
   U1: UART_C
      generic map(BRDIVISOR => 651) --use 651 for 9600 baud @ 25Mhz CLK
      port map(--Wishbone signals
         wb_clk_i => wb_clk, wb_rst_i => wb_rst, wb_adr_i => adr,
         wb_dat_i => wb_dati, wb_dat_o => wb_dato, wb_we_i => wb_we,
         wb_stb_i => wb_stb, wb_ack_o => wb_ack,
         --UART signals
         inttx_o => inttx, intrx_o => intrx, br_clk_i => wb_clk,
         txd_pad_o => txd_pad, rxd_pad_i => rxd_pad);
   
   do_testbench:
   process
      variable start_s_b : time;
      variable mbrate    : real;
   begin
      outwrite("* Miniuart testbench");
      --initial reset
      wait until wb_rst='0';
      outwrite(" - Reset");

      --Check the state of the inttx
      assert inttx='1' report "IntTx should be '1' for initial send" severity failure;

      --Send a byte
      WBWrite(UART_TX,TEST_B1,wbi,wbo);
      outwrite(" - Byte sent");

      if WB_INTS then --check the interrupts asking them via wishbone
         WBRead(UART_ST,wbi,wbo);
         while wb_dato(UART_INTTX)='0' loop  --'1' again when ready to send
            WBRead(UART_ST,wbi,wbo);
         end loop;
         outwrite(" - TX Ready -- wishbone signal");
      else
         --wait until the send buff is avaliable (inttx should go '0' and '1')
         if inttx='0' then
            wait until inttx='1';
         end if;
         outwrite(" - TX Ready");
      end if;

      --Send another byte
      WBWrite(UART_TX,TEST_B2,wbi,wbo);
      outwrite(" - Byte sent");

      if WB_INTS then --check the interrupts asking them via wishbone
         WBRead(UART_ST,wbi,wbo);
         while wb_dato(UART_INTTX)='0' loop  --'1' when ready to read
            WBRead(UART_ST,wbi,wbo);
         end loop;
         outwrite(" - RX Ready -- wishbone signal");
      else
         --Check the state of intrx
         assert intrx='0' report "IntRx should be '0'" severity failure;
         --Wait for the byte
         if intrx='0' then
            wait until intrx='1';
         end if;
         outwrite(" - Byte received");
      end if;

      -- Verify
      WBRead(UART_RX,wbi,wbo);
      outwrite(" - Byte read");
      assert wb_dato=TEST_B1 report "Received byte mismatch send byte 1" severity failure;
                                                                     
      if WB_INTS then --check the interrupts asking them via wishbone
         WBRead(UART_ST,wbi,wbo);
         while wb_dato(UART_INTTX)='0' loop  --'1' when ready to read
               WBRead(UART_ST,wbi,wbo);
         end loop;
         outwrite(" - RX Ready -- wishbone signal");
      else
         wait until rising_edge(wb_clk);
         --Check the state of intrx
         assert intrx='0' report "IntRx should be '0'" severity failure;
         --Wait for the byte
         if intrx='0' then
            wait until intrx='1';
         end if;
         outwrite(" - Byte received");
      end if;

      -- Verify
      WBRead(UART_RX,wbi,wbo);
      outwrite(" - Byte read");
      assert wb_dato=TEST_B2 report "Received byte mismatch send byte 2" severity failure;

      --This part of the testbench is for check if the baudrate is ok

      if WB_INTS then --check the interrupts asking them via wishbone
         WBRead(UART_ST,wbi,wbo);
         while wb_dato(UART_INTTX)='0' loop  --'1' again when ready to send
               WBRead(UART_ST,wbi,wbo);
         end loop;
         outwrite(" - TX Ready -- wishbone signal");
      else
         --wait until the send buff is avaliable (inttx should go '0' and '1')
         if inttx='0' then
            wait until inttx='1';
         end if;
         outwrite(" - TX Ready");
      end if;

      --Send byte
      WBWrite(UART_TX,TEST_B1,wbi,wbo,true);
      outwrite(" - Byte sent");

      wait until falling_edge(txd_pad);
      wait until rising_edge(txd_pad);
      start_s_b:=now;
      wait until falling_edge(txd_pad);

      mbrate:=real((1 sec)/(now-start_s_b));
      outwrite(" - Baudrate: "&integer'image(integer(mbrate))&" bps");
      assert abs(mbrate-9600.0)<1.0 report "Wrong baudrate" severity failure;

      if WB_INTS then --check the interrupts asking them via wishbone
         WBRead(UART_ST,wbi,wbo);
         while wb_dato(UART_INTTX)='0' loop  --'1' when ready to read
               WBRead(UART_ST,wbi,wbo);
         end loop;
         outwrite(" - RX Ready -- wishbone signal");
      else
          --Check the state of intrx
          assert intrx='0' report "IntRx should be '0'" severity failure;
          --Wait for the byte
          if intrx='0' then
             wait until intrx='1';
          end if;
          outwrite(" - Byte received");
      end if;

      outwrite("* End of test");
      stop_clock <= '1';
      wait;

  end process do_testbench;
   
end architecture Bench; -- Entity: testbench
