-----------------------------------------------------------------------------------------
-- Generated by PERL program wishbone.pl. Do not edit this file.
--
-- For defines see wishbone.defines
--
-- Package: WBInterconPkg (WBIntercon_package.vhdl)
--
-- Generated Tue Apr 26 13:22:20 2016
--
-- Wishbone masters:
--   wb_master
--
-- Wishbone slaves:
--   u1
--     baseadr 0x00000000 - size 0x40
--   counter1
--     baseadr 0x00000040 - size 0x40
-----------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package WBInterconIntPackage is
   function "and"(l : std_logic_vector;
                  r : std_logic) return std_logic_vector;
end package WBInterconIntPackage;

package body WBInterconIntPackage is
   function "and"(l : std_logic_vector;
                  r : std_logic) return std_logic_vector is
      variable result : std_logic_vector(l'range);
   begin  -- "and"
      for i in l'range loop
          result(i):=l(i) and r;
      end loop;  -- i
      return result;
   end function "and";
end package body WBInterconIntPackage;

library IEEE;
use IEEE.std_logic_1164.all;
use work.WBInterconIntPackage.all;

entity WBIntercon is
   port(
      -- wishbone master port(s)
      -- wb_master
      wb_master_dat_o : out std_logic_vector(7 downto 0);
      wb_master_ack_o : out std_logic;
      wb_master_dat_i : in  std_logic_vector(7 downto 0);
      wb_master_we_i  : in  std_logic;
      wb_master_adr_i : in  std_logic_vector(7 downto 0);
      wb_master_cyc_i : in  std_logic;
      wb_master_stb_i : in  std_logic;
      -- wishbone slave port(s)
      -- u1
      u1_dat_i : in  std_logic_vector(7 downto 0);
      u1_ack_i : in  std_logic;
      u1_dat_o : out std_logic_vector(7 downto 0);
      u1_we_o  : out std_logic;
      u1_adr_o : out std_logic_vector(0 downto 0);
      u1_stb_o : out std_logic;
      -- counter1
      counter1_dat_i : in  std_logic_vector(7 downto 0);
      counter1_ack_i : in  std_logic;
      counter1_dat_o : out std_logic_vector(7 downto 0);
      counter1_we_o  : out std_logic;
      counter1_adr_o : out std_logic_vector(0 downto 0);
      counter1_stb_o : out std_logic;
      -- clock and reset
      wb_clk_i  : in std_logic;
      wb_rst_i  : in std_logic);
end entity WBIntercon;

architecture RTL of WBIntercon is
   signal u1_ss : std_logic; -- slave select
   signal counter1_ss : std_logic; -- slave select
begin  -- RTL
   decoder:
   block
      signal adr : std_logic_vector(7 downto 0);
   begin
      adr <= wb_master_adr_i;
      u1_ss <= '1' when adr(7 downto 6)="00" else '0';
      counter1_ss <= '1' when adr(7 downto 6)="01" else '0';
      u1_adr_o <= adr(0 downto 0);
      counter1_adr_o <= adr(0 downto 0);
   end block decoder;

   mux:
   block
      signal stb_m2s : std_logic;
      signal we_m2s  : std_logic;
      signal ack_s2m : std_logic;
      signal dat_m2s : std_logic_vector(7 downto 0);
      signal dat_s2m : std_logic_vector(7 downto 0);
   begin
      -- stb Master -> Slave [Selection]
      stb_m2s <= wb_master_stb_i;
      u1_stb_o <= u1_ss and stb_m2s;
      counter1_stb_o <= counter1_ss and stb_m2s;
      -- we Master -> Slave
      we_m2s <= wb_master_we_i;
      u1_we_o <= we_m2s;
      counter1_we_o <= we_m2s;
      -- ack Slave -> Master
      ack_s2m <= u1_ack_i or counter1_ack_i;
      wb_master_ack_o <= ack_s2m;
      -- dat Master -> Slave
      dat_m2s <= wb_master_dat_i;
      u1_dat_o <= dat_m2s;
      counter1_dat_o <= dat_m2s;
      -- dat Slave -> Master [three state]
      dat_s2m <= u1_dat_i when u1_ss='1' else (others => 'Z');
      dat_s2m <= counter1_dat_i when counter1_ss='1' else (others => 'Z');
      wb_master_dat_o <= dat_s2m;
   end block mux;
end architecture RTL;