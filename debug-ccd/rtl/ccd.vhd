-------------------------------------------------------------------------------
-- Title      : ccd top level file
-- Project    : 
-------------------------------------------------------------------------------
-- File       : poc_serdes.vhd
-- Author     :   <reny@SEL107>
-- Company    : Selgron
-- Created    : 2021-07-02
-- Last update: 2023-12-06
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-07-02  1.0      reny    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ccd is

  port (
    sysclk : in std_logic;
    -- rj45
    -- CON1

    -- receive from hmi or ccd_n-1
    lvds_serial_i      : in  std_logic;  -- rx
    -- send to ccd_n-2 or hmi
    lvds_to_ccd_o      : out std_logic;  -- tx
    -- send to ccd_n_2 or hmi
    lvds_to_ejection_o : out std_logic;  -- ignore
    -- CON2

    -- send to ccd_n
    lvds_serial_o        : out   std_logic;  -- tx
    -- return from ccd_n
    lvds_from_ccd_i      : in    std_logic;  -- rx
    -- receive from ccd_n
    lvds_from_ejection_i : in    std_logic;  -- ignore
    -- switch
    board_id_i           : in    std_logic_vector(7 downto 0);
    -- led 
    led_o                : out   std_logic_vector(3 downto 0);
    sdram_clk_o          : out   std_logic;
    sdram_addr_o         : inout std_logic_vector(12 downto 0);
    sdram_banks_o        : inout std_logic_vector(1 downto 0);
    sdram_dq_o           : inout std_logic_vector(15 downto 0);
    sdram_cs_n_o         : inout std_logic;
    sdram_ras_n_o        : inout std_logic;
    sdram_cas_n_o        : inout std_logic;
    sdram_we_n_o         : inout std_logic;
    sdram_dqm_o          : inout std_logic;
    sdram_cke_o          : inout std_logic;
    sdram_udqm_o         : inout std_logic;
    -- ad/ccd
    ad_red_e_i           : in    std_logic_vector(11 downto 0);
    ad_red_o_i           : in    std_logic_vector(11 downto 0);
    ad_green_e_i         : in    std_logic_vector(11 downto 0);
    ad_green_o_i         : in    std_logic_vector(11 downto 0);
    ad_blue_e_i          : in    std_logic_vector(11 downto 0);
    ad_blue_o_i          : in    std_logic_vector(11 downto 0);
    ad_cplob_o           : out   std_logic_vector(5 downto 0);
    ad_data_clk_o        : out   std_logic_vector(5 downto 0);
    ad_pblk_o            : out   std_logic_vector(5 downto 0);
    ad_shd_o             : out   std_logic_vector(5 downto 0);
    ad_shp_o             : out   std_logic_vector(5 downto 0);
    ccd_cp_o             : out   std_logic;
    ccd_rs_o             : out   std_logic;
    ccd_sh_o             : out   std_logic;
    ccd_theta_1a_o       : out   std_logic_vector(1 downto 0);
    ccd_theta_2a_o       : out   std_logic_vector(1 downto 0);
    ccd_theta_2b_o       : out   std_logic;
    -- ad spi
    ad_spi_data0_o       : out   std_logic;
    ad_spi_data1_o       : out   std_logic;
    ad_spi_data2_o       : out   std_logic;
    ad_spi_data3_o       : out   std_logic;
    ad_spi_data4_o       : out   std_logic;
    ad_spi_data5_o       : out   std_logic;
    ad_spi_sclk_o        : out   std_logic_vector(5 downto 0);
    ad_spi_ss_0          : out   std_logic;
    ad_spi_ss_1          : out   std_logic;
    ad_spi_ss_2          : out   std_logic;
    ad_spi_ss_3          : out   std_logic;
    ad_spi_ss_4          : out   std_logic;
    ad_spi_ss_5          : out   std_logic);

end entity ccd;

architecture ccd_rtl of ccd is

  signal ad_cplob_int          : std_logic;
  signal ad_data_clk_int       : std_logic;
  signal ad_pblk_int           : std_logic;
  signal ad_shd_int            : std_logic;
  signal ad_shp_int            : std_logic;
  signal ccd_theta_1a_int      : std_logic := '0';
  signal ccd_theta_2a_int      : std_logic := '0';
  signal ccd_theta_2b_int      : std_logic := '0';
  signal ccd_sh_int            : std_logic := '0';
  signal ccd_cp_int            : std_logic := '0';
  signal ccd_rs_int            : std_logic := '0';
  signal start_reg, start_next : std_logic := '0';
  signal data_rx_int           : std_logic := '0';



  component ccd_qsys is
    port (
      board_id_external_connection_export        : in    std_logic_vector(7 downto 0)  := (others => 'X');  -- export
      clock_bridge_0_out_clk_clk                 : out   std_logic;  -- clk
      nios_write_led_external_connection_export  : out   std_logic_vector(3 downto 0);  -- export
      reset_ad_reset_n                           : in    std_logic                     := 'X';  -- reset_n
      reset_system_reset_n                       : in    std_logic                     := 'X';  -- reset_n
      ad_module_0_ad_i_red_e_co                  : in    std_logic_vector(11 downto 0) := (others => 'X');  -- red_e_co
      ad_module_0_ad_i_red_o_co                  : in    std_logic_vector(11 downto 0) := (others => 'X');  -- red_o_co
      ad_module_0_ad_i_green_e_co                : in    std_logic_vector(11 downto 0) := (others => 'X');  -- green_e_co
      ad_module_0_ad_i_green_o_co                : in    std_logic_vector(11 downto 0) := (others => 'X');  -- green_o_co
      ad_module_0_ad_i_blue_e_co                 : in    std_logic_vector(11 downto 0) := (others => 'X');  -- blue_e_co
      ad_module_0_ad_i_blue_o_co                 : in    std_logic_vector(11 downto 0) := (others => 'X');  -- blue_o_co
      ad_module_0_ad_o_cplob_co                  : out   std_logic;  -- cplob_co
      ad_module_0_ad_o_dataclk_co                : out   std_logic;  -- dataclk_co
      ad_module_0_ad_o_pblk_co                   : out   std_logic;  -- pblk_co
      ad_module_0_ad_o_shd_co                    : out   std_logic;  -- shd_co
      ad_module_0_ad_o_shp_co                    : out   std_logic;  -- shp_co
      ad_module_0_ccd_o_theta_1a_co              : out   std_logic;  -- theta_1a_co
      ad_module_0_ccd_o_theta_2a_co              : out   std_logic;  -- theta_2a_co
      ad_module_0_ccd_o_theta_2b_co              : out   std_logic;  -- theta_2b_co
      ad_module_0_ccd_o_rs_co                    : out   std_logic;  -- rs_co
      ad_module_0_ccd_o_sh_co                    : out   std_logic;  -- sh_co
      ad_module_0_ccd_o_cp_co                    : out   std_logic;  -- cp_co
      ad_module_0_sync_i_co                      : in    std_logic                     := 'X';  -- co
      clk_system_clk                             : in    std_logic                     := 'X';  -- clk
      clk_ad_clk                                 : in    std_logic                     := 'X';  -- clk
      spi_0_external_MISO                        : in    std_logic                     := 'X';  -- MISO
      spi_0_external_MOSI                        : out   std_logic;  -- MOSI
      spi_0_external_SCLK                        : out   std_logic;  -- SCLK
      spi_0_external_SS_n                        : out   std_logic_vector(5 downto 0);  -- SS_n
      tristate_conduit_bridge_0_out_sdram_ras_n  : out   std_logic_vector(0 downto 0);  -- sdram_ras_n
      tristate_conduit_bridge_0_out_sdram_we_n   : out   std_logic_vector(0 downto 0);  -- sdram_we_n
      tristate_conduit_bridge_0_out_sdram_dq_out : inout std_logic_vector(15 downto 0) := (others => 'X');  -- sdram_dq_out
      tristate_conduit_bridge_0_out_sdram_cs_n   : out   std_logic_vector(0 downto 0);  -- sdram_cs_n
      tristate_conduit_bridge_0_out_sdram_addr   : out   std_logic_vector(12 downto 0);  -- sdram_addr
      tristate_conduit_bridge_0_out_sdram_ba     : out   std_logic_vector(1 downto 0);  -- sdram_ba
      tristate_conduit_bridge_0_out_sdram_dqm    : out   std_logic_vector(1 downto 0);  -- sdram_dqm
      tristate_conduit_bridge_0_out_sdram_cas_n  : out   std_logic_vector(0 downto 0);  -- sdram_cas_n
      tristate_conduit_bridge_0_out_sdram_cke    : out   std_logic_vector(0 downto 0);  -- sdram_cke
      pll_sdram_clk                              : out   std_logic;
      ad_module_0_packet_save_save_to_fifo_co    : in    std_logic                     := 'X';

      rj45_tester_0_rj45a_connector_tx0 : out std_logic;         -- tx0
      rj45_tester_0_rj45a_connector_rx1 : in  std_logic := 'X';  -- rx1
      rj45_tester_0_rj45a_connector_tx2 : out std_logic;         -- tx1
      rj45_tester_0_rj45b_connector_rx0 : in  std_logic := 'X';  -- rx0
      rj45_tester_0_rj45b_connector_tx1 : out std_logic;         -- tx1
      rj45_tester_0_rj45b_connector_rx2 : in  std_logic := 'X';  -- rx1

      save_to_debug_export : out std_logic_vector(7 downto 0)  -- export
      );
  end component ccd_qsys;

  component sysclk_control is
    port (
      inclk  : in  std_logic := 'X';    -- inclk
      outclk : out std_logic            -- outclk
      );
  end component sysclk_control;


  constant CTE_COUNT : integer := 60000000;

  type POC_ST_TYPE is (ST_WAIT_SYNC,
                       ST_COUNT);


  type POC_ST_SYNC is (ST_WAIT_SYNC_REG,
                       ST_WAIT_REG,
                       ST_COUNT_REG);

  signal st_sync_reg, st_sync_next                        : POC_ST_SYNC                   := ST_WAIT_SYNC_REG;
  signal st_db_reg, st_db_next                            : POC_ST_TYPE                   := ST_WAIT_SYNC;
  signal clock_byte                                       : std_logic;
  signal board_id_reg, board_id_next                      : std_logic_vector(7 downto 0)  := (others => '0');
  signal led_reg, led_next, led_int                       : std_logic_vector(3 downto 0)  := (others => '0');
  signal data_int                                         : std_logic_vector(7 downto 0);
  signal transition_reg, transition_next, transition_int  : std_logic                     := '0';
  signal debounce_reg, debounce_next                      : unsigned(15 downto 0)         := (others => '0');
  signal start_packet_reg, start_packet_next              : std_logic                     := '0';
  signal clk_int                                          : std_logic;
  signal pll_sync_125                                     : std_logic;
  signal we_sync_reg, we_sync_next                        : std_logic                     := '0';
  signal pio_ok_reg, pio_ok_next, pio_ok_int              : std_logic                     := '0';
  signal flag_reg, flag_next                              : std_logic                     := '0';
  signal count_pio_reg, count_pio_next                    : unsigned(27 downto 0)         := (others => '0');
  signal sync_reg, sync_next, sync_old_reg, sync_old_next : std_logic                     := '0';
  signal count_sync_reg, count_sync_next                  : unsigned(15 downto 0)         := (others => '0');
  signal mosi_int                                         : std_logic;
  signal miso_int                                         : std_logic;
  signal sclk_int                                         : std_logic;
  signal ss_int                                           : std_logic_vector(5 downto 0);
  --debug
  signal before_buffer_int, after_buffer_int              : std_logic;
  signal after_sim_int                                    : std_logic;
  signal save_reg, save_next, save_int                    : std_logic;
  signal sdram_clk_int                                    : std_logic                     := '0';
  signal debug_ejection_int                               : std_logic                     := '0';
  signal ad_to_fifo_data_int                              : std_logic_vector(47 downto 0) := (others => '0');
  signal ad_to_fifo_valid_int                             : std_logic                     := '0';
  signal debug_sens_int                                   : std_logic                     := '0';
  signal counter_led_reg, counter_led_next                : unsigned(23 downto 0)         := (others => '0');
  signal boot_reg, boot_next                              : std_logic                     := '0';
  signal sync_count_reg, sync_count_next                  : unsigned(12 downto 0)         := (others => '0');
  signal sync_gen_reg, sync_gen_next                      : std_logic                     := '0';
begin  -- architecture poc_serdes_rtl

  led_o         <= led_reg;
  ad_cplob_o    <= (others => ad_cplob_int);
  ad_data_clk_o <= (others => ad_data_clk_int);
  ad_pblk_o     <= (others => ad_pblk_int);
  ad_shd_o      <= (others => ad_shd_int);
  ad_shp_o      <= (others => ad_shp_int);

  ccd_theta_1a_o <= (others => ccd_theta_1a_int);
  ccd_theta_2a_o <= (others => ccd_theta_2a_int);
  ccd_theta_2b_o <= ccd_theta_2b_int;
  ccd_rs_o       <= ccd_rs_int;
  ccd_cp_o       <= ccd_cp_int;
  ccd_sh_o       <= ccd_sh_int;

  ad_spi_data0_o   <= mosi_int;
  ad_spi_data1_o   <= mosi_int;
  ad_spi_data2_o   <= mosi_int;
  ad_spi_data3_o   <= mosi_int;
  ad_spi_data4_o   <= mosi_int;
  ad_spi_data5_o   <= mosi_int;
  ad_spi_ss_0      <= ss_int(0);        -- red even
  ad_spi_ss_1      <= ss_int(1);        -- red odd
  ad_spi_ss_2      <= ss_int(2);        -- green even
  ad_spi_ss_3      <= ss_int(3);        -- green odd
  ad_spi_ss_4      <= ss_int(4);        -- blue even 
  ad_spi_ss_5      <= ss_int(5);        -- blue odd
  ad_spi_sclk_o(0) <= sclk_int;
  ad_spi_sclk_o(1) <= sclk_int;
  ad_spi_sclk_o(2) <= sclk_int;
  ad_spi_sclk_o(3) <= sclk_int;
  ad_spi_sclk_o(4) <= sclk_int;
  ad_spi_sclk_o(5) <= sclk_int;

  sdram_clk_o  <= sdram_clk_int;
  sdram_udqm_o <= sdram_dqm_o;

  u0 : component ccd_qsys
    port map (
      clk_ad_clk                                   => clk_int,
      reset_system_reset_n                         => '1',
      clock_bridge_0_out_clk_clk                   => clock_byte,
      board_id_external_connection_export          => board_id_reg,
      nios_write_led_external_connection_export    => led_int,
      clk_system_clk                               => sysclk,
      reset_ad_reset_n                             => '1',
      ad_module_0_ad_i_red_e_co                    => ad_red_e_i,
      ad_module_0_ad_i_red_o_co                    => ad_red_o_i,
      ad_module_0_ad_i_green_e_co                  => ad_green_e_i,
      ad_module_0_ad_i_green_o_co                  => ad_green_o_i,
      ad_module_0_ad_i_blue_e_co                   => ad_blue_e_i,
      ad_module_0_ad_i_blue_o_co                   => ad_blue_o_i,
      ad_module_0_ad_o_cplob_co                    => ad_cplob_int,
      ad_module_0_ad_o_dataclk_co                  => ad_data_clk_int,
      ad_module_0_ad_o_pblk_co                     => ad_pblk_int,
      ad_module_0_ad_o_shd_co                      => ad_shd_int,
      ad_module_0_ad_o_shp_co                      => ad_shp_int,
      ad_module_0_ccd_o_theta_1a_co                => ccd_theta_1a_int,
      ad_module_0_ccd_o_theta_2a_co                => ccd_theta_2a_int,
      ad_module_0_ccd_o_theta_2b_co                => ccd_theta_2b_int,
      ad_module_0_ccd_o_rs_co                      => ccd_rs_int,
      ad_module_0_ccd_o_sh_co                      => ccd_sh_int,
      ad_module_0_ccd_o_cp_co                      => ccd_cp_int,
      ad_module_0_sync_i_co                        => sync_gen_reg,
      spi_0_external_MISO                          => '0',
      spi_0_external_MOSI                          => mosi_int,
      spi_0_external_SCLK                          => sclk_int,
      spi_0_external_SS_n                          => ss_int,
      pll_sdram_clk                                => sdram_clk_int,
      tristate_conduit_bridge_0_out_sdram_ras_n(0) => sdram_ras_n_o,  -- tristate_conduit_bridge_0_out.sdram_ras_n
      tristate_conduit_bridge_0_out_sdram_we_n(0)  => sdram_we_n_o,  --                              .sdram_we_n
      tristate_conduit_bridge_0_out_sdram_dq_out   => sdram_dq_o,  --                              .sdram_dq_out
      tristate_conduit_bridge_0_out_sdram_cs_n(0)  => sdram_cs_n_o,  --                              .sdram_cs_n
      tristate_conduit_bridge_0_out_sdram_addr     => sdram_addr_o,  --                              .sdram_addr
      tristate_conduit_bridge_0_out_sdram_ba       => sdram_banks_o,  --                              .sdram_ba
      tristate_conduit_bridge_0_out_sdram_dqm(0)   => sdram_dqm_o,  --                              .sdram_dqm
      tristate_conduit_bridge_0_out_sdram_cas_n(0) => sdram_cas_n_o,  --                              .sdram_cas_n
      tristate_conduit_bridge_0_out_sdram_cke(0)   => sdram_cke_o,  --                              .sdram_cke
      ad_module_0_packet_save_save_to_fifo_co      => save_reg,
      -- transmits @ 50mhz
      rj45_tester_0_rj45a_connector_tx0 => lvds_to_ccd_o,  --      rj45_tester_0_rj45a_connector.tx0
      -- reads @ 50 mhz
      rj45_tester_0_rj45a_connector_rx1 => lvds_serial_i,  --                                   .rx1
      -- transmits @ 20 mhz
      rj45_tester_0_rj45a_connector_tx2 => lvds_to_ejection_o,  --                                   .tx1

      -- reads @ 50 mhz
      rj45_tester_0_rj45b_connector_rx0 => lvds_from_ccd_i,  --      rj45_tester_0_rj45b_connector.rx0
      -- writes @ 50 mhz
      rj45_tester_0_rj45b_connector_tx1 => lvds_serial_o,  --                                   .tx1
      -- reads @ 20 mhz
      rj45_tester_0_rj45b_connector_rx2 => lvds_from_ejection_i,  --                                   .rx1

      save_to_debug_export(0) => save_int  --       
      );

  u1 : component sysclk_control
    port map (
      inclk  => sysclk,                 --  altclkctrl_input.inclk
      outclk => clk_int                 -- altclkctrl_output.outclk
      );

  reg_process : process (clock_byte) is

  begin  -- process reg_process

    if rising_edge(clock_byte) then     -- rising clock edge
      led_reg          <= led_next;
      board_id_reg     <= board_id_next;
      transition_reg   <= transition_next;
      debounce_reg     <= debounce_next;
      st_db_reg        <= st_db_next;
      start_packet_reg <= start_packet_next;
      save_reg         <= save_next;
      counter_led_reg  <= counter_led_next;
      boot_reg         <= boot_next;
      sync_count_reg   <= sync_count_next;
      sync_gen_reg     <= sync_gen_next;
      start_reg        <= start_next;
    end if;

  end process reg_process;

  comb_process : process (board_id_i, debounce_reg, st_db_reg,
                          start_packet_reg, transition_int, transition_reg) is
  begin  -- process comb_process


    -- led_next(3) <= debug_sens_int;
    -- led_next(2) <= debug_ejection_int;
    -- led_next(1) <= after_buffer_int;
    -- led_next(0) <= after_sim_int;

    transition_next   <= transition_int;
    board_id_next     <= not board_id_i;
    debounce_next     <= debounce_reg;
    st_db_next        <= st_db_reg;
    start_packet_next <= start_packet_reg;

    case st_db_reg is

      when ST_WAIT_SYNC =>
        if transition_reg = '1' then
          st_db_next        <= ST_COUNT;
          debounce_next     <= (others => '0');
          start_packet_next <= '1';
        end if;

      when ST_COUNT =>
        debounce_next <= debounce_reg + 1;
        if debounce_reg > 100 then
          st_db_next        <= ST_WAIT_SYNC;
          start_packet_next <= '0';
        end if;

    end case;

  end process comb_process;

  led_process : process (boot_reg, counter_led_reg, led_int, led_reg) is
  begin  -- process led_process
    counter_led_next <= counter_led_reg + 1;
    led_next         <= led_reg;
    boot_next        <= boot_reg;

    if counter_led_reg = 0 then
      led_next(3 downto 1) <= led_reg(2 downto 0);
      led_next(0)          <= led_reg(3);
    end if;
    if boot_reg = '0' then
      led_next(0) <= not led_reg(0);
      boot_next   <= '1';
    end if;

    if unsigned(led_int) >= 0 then
      led_next <= led_int;
    end if;
  end process led_process;


  sync_gen : process (save_int, save_reg, start_reg, sync_count_reg) is

  begin  -- process sync_gen
    sync_gen_next   <= '0';
    sync_count_next <= sync_count_reg + 1;
    save_next       <= save_reg;
    start_next      <= start_reg;
    if (sync_count_reg < 100) then
      sync_gen_next <= '1';
      if save_int = '1' then
        start_next <= '1';
        if start_reg = '0' and sync_count_reg = 0 then
          save_next <= '1';
        elsif start_reg = '1' and sync_count_reg = 0 then
          save_next <= '0';
        end if;
      else
        start_next <= '0';
      end if;
    end if;
    if (sync_count_reg = 5999) then
      sync_count_next <= (others => '0');
    end if;
  end process sync_gen;

end architecture ccd_rtl;
