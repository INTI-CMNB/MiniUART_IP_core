
library IEEE;
use IEEE.std_logic_1164.all;

package WBInterconPkg is

   component WBIntercon is
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
   end component WBIntercon;

end package WBInterconPkg;

-- Instantiation example:
-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use work.WBInterconPkg.all;
-- 
--    -- signals:
--    -- wb_master
--    signal wb_master_dati  : std_logic_vector(7 downto 0);
--    signal wb_master_acki  : std_logic;
--    signal wb_master_dato  : std_logic_vector(7 downto 0);
--    signal wb_master_weo   : std_logic;
--    signal wb_master_adro  : std_logic_vector(7 downto 0);
--    signal wb_master_cyco  : std_logic;
--    signal wb_master_stbo  : std_logic;
--    -- u1
--    signal u1_dato  : std_logic_vector(7 downto 0);
--    signal u1_acko  : std_logic;
--    signal u1_dati  : std_logic_vector(7 downto 0);
--    signal u1_wei   : std_logic;
--    signal u1_adri  : std_logic_vector(0 downto 0);
--    signal u1_stbi  : std_logic;
--    -- counter1
--    signal counter1_dato  : std_logic_vector(7 downto 0);
--    signal counter1_acko  : std_logic;
--    signal counter1_dati  : std_logic_vector(7 downto 0);
--    signal counter1_wei   : std_logic;
--    signal counter1_adri  : std_logic_vector(0 downto 0);
--    signal counter1_stbi  : std_logic;
-- 
-- intercon: WBIntercon
--    port map(
--       -- wishbone master port(s)
--       -- wb_master
--       wb_master_dat_o => wb_master_dati,
--       wb_master_ack_o => wb_master_acki,
--       wb_master_dat_i => wb_master_dato,
--       wb_master_we_i  => wb_master_weo,
--       wb_master_adr_i => wb_master_adro,
--       wb_master_cyc_i => wb_master_cyco,
--       wb_master_stb_i => wb_master_stbo,
--       -- wishbone slave port(s)
--       -- u1
--       u1_dat_i => u1_dato,
--       u1_ack_i => u1_acko,
--       u1_dat_o => u1_dati,
--       u1_we_o  => u1_wei,
--       u1_adr_o => u1_adri,
--       u1_stb_o => u1_stbi,
--       -- counter1
--       counter1_dat_i => counter1_dato,
--       counter1_ack_i => counter1_acko,
--       counter1_dat_o => counter1_dati,
--       counter1_we_o  => counter1_wei,
--       counter1_adr_o => counter1_adri,
--       counter1_stb_o => counter1_stbi,
--       -- clock and reset
--       wb_clk_i => wb_clk_o,
--       wb_rst_i => wb_rst_o);
