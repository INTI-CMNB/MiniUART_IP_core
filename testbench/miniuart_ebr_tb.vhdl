------------------------------------------------------------------------------
----                                                                      ----
----  Mini UART testbench                                                 ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  UART_C + external Wishbone counter as baudrate generator testbench. ----
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
----                   work.WBInterconPkg                                 ----
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
library wb_counter;
use wb_counter.counters.all;
use work.WBInterconPkg.all;


entity TestBench is
end entity TestBench;

architecture Bench of TestBench is
   constant CLKPERIOD   : time:=40 ns;
   constant WB_INTS     : boolean:=false;
   constant TEST_B1     : std_logic_vector(7 downto 0):="01010101";
   constant TEST_B2     : std_logic_vector(7 downto 0):="01100110";

   -- signals:
   -- wb
   signal wb_dati   : std_logic_vector(7 downto 0);
   signal wb_ack    : std_logic;
   signal wb_dato   : std_logic_vector(7 downto 0);
   signal wb_we     : std_logic;
   signal wb_adr    : std_logic_vector(7 downto 0);
   signal wb_cyc    : std_logic;
   signal wb_stb    : std_logic;
   -- U1
   signal u1_dato   : std_logic_vector(7 downto 0);
   signal u1_ack    : std_logic;
   signal u1_dati   : std_logic_vector(7 downto 0);
   signal u1_we     : std_logic;
   signal u1_adr    : std_logic_vector(0 downto 0);
   signal u1_stb    : std_logic;
   -- Counter1
   signal cnt1_dato : std_logic_vector(7 downto 0);
   signal cnt1_ack  : std_logic;
   signal cnt1_dati : std_logic_vector(7 downto 0);
   signal cnt1_we   : std_logic;
   signal cnt1_adr  : std_logic_vector(0 downto 0);
   signal cnt1_stb  : std_logic;

   signal wbi       : wb_bus_i_type;
   signal wbo       : wb_bus_o_type;

   -- UART
   signal inttx     : std_logic;
   signal intrx     : std_logic;
   signal txd_pad   : std_logic;
   signal rxd_pad   : std_logic;
   signal adr       : std_logic_vector(0 downto 0);

   -- SimpleCounter
   signal brate     : std_logic;
   signal ce        : std_logic:='0';

   -- Wishbone
   signal wb_rst    : std_logic:='1';
   signal wb_clk    : std_logic;

   signal stop_clk  : std_logic:='0';

begin
   --Loopback comunication lines
   rxd_pad <= txd_pad;

   adr <= u1_adr(0 downto 0);

   -- Clock
   p_clks:
   process
   begin
      wb_clk <= '0';
      wait for CLKPERIOD/2;
      wb_clk <= '1';
      wait for CLKPERIOD/2;
      if stop_clk='1' then
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

   -- UART
   u1: UART_C
      generic map(BRDIVISOR => 1) --Use the baudrate gen through wb_counter
      port map(--Wishbone signals
         wb_clk_i => wb_clk, wb_rst_i => wb_rst, wb_adr_i => adr,
         wb_dat_i => u1_dati, wb_dat_o => u1_dato, wb_we_i => u1_we,
         wb_stb_i => u1_stb, wb_ack_o => u1_ack,
         --UART signals
         inttx_o => inttx, intrx_o => intrx, br_clk_i => brate,
         txd_pad_o => txd_pad, rxd_pad_i => rxd_pad);

   counter1: SCounter
      generic map(MOD_WIDTH => 16)
      port map(
          --Wishbone signals
          wb_clk_i => wb_clk, wb_rst_i => wb_rst, wb_adr_i => cnt1_adr,
          wb_dat_i => cnt1_dati, wb_we_i => cnt1_we, wb_stb_i => cnt1_stb,
          wb_ack_o => cnt1_ack,
          --Counter signals
          ce_i => wb_clk, o_o => brate);
          
   intercon: WBIntercon
      port map(
         -- wishbone master port(s)
         -- wb_master
         wb_master_dat_o => wb_dato,
         wb_master_ack_o => wb_ack,
         wb_master_dat_i => wb_dati,
         wb_master_we_i  => wb_we,
         wb_master_adr_i => wb_adr,
         wb_master_cyc_i => wb_cyc,
         wb_master_stb_i => wb_stb,
         -- wishbone slave port(s)
         -- U1
         u1_dat_i => u1_dato,
         u1_ack_i => u1_ack,
         u1_dat_o => u1_dati,
         u1_we_o  => u1_we,
         u1_adr_o => u1_adr,
         u1_stb_o => u1_stb,
         -- Counter1
         counter1_dat_i => cnt1_dato,
         counter1_ack_i => cnt1_ack,
         counter1_dat_o => cnt1_dati,
         counter1_we_o  => cnt1_we,
         counter1_adr_o => cnt1_adr,
         counter1_stb_o => cnt1_stb,
         -- clock and reset
         wb_clk_i => wb_clk,
         wb_rst_i => wb_rst);


   do_testbench:
   process
      variable start_s_b : time;
      variable mbrate    : real;
   begin
      outwrite("* Miniuart testbench with external WB baudrate generator");
      --initial reset
      wait until wb_rst='0';
      outwrite(" - Reset");
      ce <= '1';

      --Program the baudrate generator
      --want to count to 651 -- send a 650 0b1010001010
      --Send hi byte 0x01
      WBWrite("01000001","00000010",wbi,wbo);
      outwrite(" - BR byte hi");
      --Send low byte 0x00
      WBWrite("01000000","10001010",wbi,wbo);
      outwrite(" - BR byte lo");

      --Check the state of the inttx
      assert inttx='1' report "IntTx should be '1' for initial send" severity failure;

      --Send a byte
      WBWrite(UART_TX,TEST_B1,wbi,wbo);
      outwrite(" - Byte sent");

      if WB_INTS then --check the interrupts asking them via wishbone
         WBRead(UART_ST,wbi,wbo);
         while wb_dato(UART_INTTX)='1' loop  --go '0'
            WBRead(UART_ST,wbi,wbo);
         end loop;
         while wb_dato(UART_INTTX)='0' loop  --'1' again when ready to send
            WBRead(UART_ST,wbi,wbo);
         end loop;
         outwrite(" - TX Ready -- wishbone signal");
      else
         --wait until the send buff is avaliable (inttx should go '0' and '1')
         if inttx='1' then
            wait until inttx='0';
         end if;
         wait until rising_edge(inttx);
         outwrite(" - TX Ready");
      end if;

      --Send another byte
      WBWrite(UART_TX,TEST_B2,wbi,wbo);
      outwrite(" - Byte sent");

      if WB_INTS then --check the interrupts asking them via wishbone
         WBRead(UART_ST,wbi,wbo);
         while wb_dato(UART_INTRX)='0' loop  --'1' when ready to read
            WBRead(UART_ST,wbi,wbo);
         end loop;
         outwrite(" - RX Ready -- wishbone signal");
      else
         --Check the state of intrx
         assert intrx='0' report "IntRx should be '0'" severity failure;
         --Wait for the byte
         wait until rising_edge(intrx);
         outwrite(" - Byte recived");
      end if;

      -- Verify
      WBRead(UART_RX,wbi,wbo);
      outwrite(" - Byte read");
      assert wb_dato=TEST_B1 report "Recived byte mismatch send byte 1" severity failure;
                                                                     
      if WB_INTS then --check the interrupts asking them via wishbone
         WBRead(UART_ST,wbi,wbo);
         while wb_dato(UART_INTRX)='0' loop  --'1' when ready to read
            WBRead(UART_ST,wbi,wbo);
         end loop;
         outwrite(" - RX Ready -- wishbone signal");
      else
         --Check the state of intrx
         wait until rising_edge(wb_clk);
         assert intrx='0' report "IntRx should be '0'" severity failure;
         --Wait for the byte
         wait until rising_edge(intrx);
         outwrite(" - Byte recived");
      end if;

      -- verify
      WBRead(UART_RX,wbi,wbo);
      outwrite(" - Byte read");
      assert wb_dato=TEST_B2 report "Recived byte mismatch send byte 2" severity failure;

      --This part of the testbench is for check if the baudrate is ok

      if WB_INTS then --check the interrupts asking them via wishbone
         WBRead(UART_ST,wbi,wbo);
         assert wb_dato(UART_INTTX)='1' report "TX NOT Ready but should be -- wishbone signal" severity note;
         outwrite(" - TX Ready -- wishbone signal");
      else
         --wait until the send buff is avaliable (inttx should go '0' and '1')
         assert inttx='1' report "TX NOT Ready but should be" severity note;
         outwrite(" - TX Ready");
      end if;

      --Send byte
      WBWrite(UART_TX,TEST_B1,wbi,wbo);
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
         while wb_dato(UART_INTRX)='0' loop  --'1' when ready to read
            WBRead(UART_ST,wbi,wbo);
         end loop;
         outwrite(" - RX Ready -- wishbone signal");
      else
         --Check the state of intrx
         assert intrx='0' report "IntRx should be '0'" severity failure;
         --Wait for the byte
         wait until rising_edge(intrx);
         outwrite(" - Byte recived");
      end if;

      outwrite("* End of test");
      stop_clk <= '1';
      wait;

  end process do_testbench;
   
end architecture Bench; -- Entity: testbench
