-------------------------------------------------------------------------------
-- Title      : Testbench for design "ser/des"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : serdes_tb.vhd
-- Author     : Elias Bencz  <elias@elias-GA-78LMT-S2>
-- Company    : 
-- Created    : 2023-10-19
-- Last update: 2023-10-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-10-19  1.0      elias   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

-------------------------------------------------------------------------------

entity serdes_tb is

end entity serdes_tb;

-------------------------------------------------------------------------------

architecture serdes_tb of serdes_tb is

  -- component generics
  constant BYTES_COUNTER : integer := 10;
  constant N_CYCLES      : integer := 500;

  -- component ports
  signal rst_n         : std_logic := '0';
  signal enable_i      : std_logic := '0';
  signal status_o      : std_logic;
  signal tx_avst_valid : std_logic;
  signal tx_avst_ready : std_logic;
  signal tx_avst_sop   : std_logic;
  signal tx_avst_eop   : std_logic;
  signal tx_avst_data  : std_logic_vector(7 downto 0);
  signal rx_avst_valid : std_logic;
  signal rx_avst_ready : std_logic;
  signal rx_avst_sop   : std_logic;
  signal rx_avst_eop   : std_logic;
  signal rx_avst_data  : std_logic_vector(7 downto 0);
  signal tx_serial_o   : std_logic;
  signal rx_serial_i   : std_logic;
  signal sync_o        : std_logic;

  -- clock
  signal clk0  : std_logic := '0';
  signal clk90 : std_logic;


begin  -- architecture serdes_tb

  -- component instantiation
  GEN_DUT : entity work.framegen
    generic map (
      BYTES_COUNTER => BYTES_COUNTER + 30,
      N_CYCLES      => N_CYCLES)
    port map (
      clk0         => clk0,
      rst_n        => rst_n,
      enable_i     => enable_i,
      m_avst_valid => tx_avst_valid,
      m_avst_ready => tx_avst_ready,
      m_avst_sop   => tx_avst_sop,
      m_avst_eop   => tx_avst_eop,
      m_avst_data  => tx_avst_data);

  -- component instantiation
  -- We are allowed to send more data, but only BYTES_COUNTER will be processed
  -- We can even send less data that will be padded as zero
  SER_DUT : entity work.ser
    generic map (
      BYTES_COUNTER => BYTES_COUNTER + 100)
    port map (
      clk0         => clk0,
      rst_n        => rst_n,
      s_avst_valid => tx_avst_valid,
      s_avst_ready => tx_avst_ready,
      s_avst_sop   => tx_avst_sop,
      s_avst_eop   => tx_avst_eop,
      s_avst_data  => tx_avst_data,
      tx_serial_o  => tx_serial_o);

  -- Simulate a delay
  rx_serial_i <= transport tx_serial_o after 12 ns;

  -- component instantiation
  -- The desserializer will only decoded up to BYTES_COUNTER
  -- It will then wait for a next PREAMBLE
  DES_DUT : entity work.des
    generic map (
      BYTES_COUNTER => BYTES_COUNTER)
    port map (
      clk0         => clk0,
      clk90        => clk90,
      rst_n        => rst_n,
      sync_o       => sync_o,
      m_avst_valid => rx_avst_valid,
      m_avst_ready => rx_avst_ready,
      m_avst_sop   => rx_avst_sop,
      m_avst_eop   => rx_avst_eop,
      m_avst_data  => rx_avst_data,
      rx_serial_i  => rx_serial_i);

  -- component instantiation
  CMP_DUT : entity work.framecmp
    generic map (
      BYTES_COUNTER => BYTES_COUNTER,
      N_CYCLES      => N_CYCLES)
    port map (
      clk0         => clk0,
      rst_n        => rst_n,
      status_o     => status_o,
      s_avst_valid => rx_avst_valid,
      s_avst_ready => rx_avst_ready,
      s_avst_sop   => rx_avst_sop,
      s_avst_eop   => rx_avst_eop,
      s_avst_data  => rx_avst_data);

  clk0  <= not clk0 after 20 ns;
  clk90 <= clk0     after 10 ns;

  WaveGen_Proc : process
  begin
    wait until clk0 = '1';
    wait for 20 ns;
    rst_n    <= '1';
    wait for 1 us;
    assert status_o = '0' report "Status should be false" severity error;
    enable_i <= '1';
    wait for 40 us;
    enable_i <= '0';
    assert status_o = '1' report "Status should be true" severity error;
    wait for 40 us;
    assert status_o = '0' report "Status should be false" severity error;
    stop;
  end process WaveGen_Proc;

end architecture serdes_tb;
