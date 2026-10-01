-------------------------------------------------------------------------------
-- Title      : Testbench for design "framegen/framecmp"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : frame_tb.vhd
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

entity frame_tb is

end entity frame_tb;

-------------------------------------------------------------------------------

architecture frame_tb of frame_tb is

  -- component generics
  constant BYTES_COUNTER : integer := 3;
  constant N_CYCLES      : integer := 500;

  -- component ports
  signal clk0       : std_logic := '0';
  signal rst_n      : std_logic := '0';
  signal enable_i   : std_logic := '0';
  signal status_o   : std_logic;
  signal avst_valid : std_logic;
  signal avst_ready : std_logic;
  signal avst_sop   : std_logic;
  signal avst_eop   : std_logic;
  signal avst_data  : std_logic_vector(7 downto 0);

begin  -- architecture frame_tb

  -- component instantiation
  CMP_DUT : entity work.framecmp
    generic map (
      BYTES_COUNTER => BYTES_COUNTER,
      N_CYCLES      => N_CYCLES)
    port map (
      clk0         => clk0,
      rst_n        => rst_n,
      status_o     => status_o,
      s_avst_valid => avst_valid,
      s_avst_ready => avst_ready,
      s_avst_sop   => avst_sop,
      s_avst_eop   => avst_eop,
      s_avst_data  => avst_data);

  -- component instantiation
  GEN_DUT : entity work.framegen
    generic map (
      BYTES_COUNTER => BYTES_COUNTER,
      N_CYCLES      => N_CYCLES)
    port map (
      clk0         => clk0,
      rst_n        => rst_n,
      enable_i     => enable_i,
      m_avst_valid => avst_valid,
      m_avst_ready => avst_ready,
      m_avst_sop   => avst_sop,
      m_avst_eop   => avst_eop,
      m_avst_data  => avst_data);

  clk0 <= not clk0 after 10 ns;

  WaveGen_Proc : process
  begin
    wait until clk0 = '1';
    wait for 20 ns;
    rst_n    <= '1';
    wait for 10 us;
    assert status_o = '0' report "Status should be false" severity error;
    enable_i <= '1';
    wait for 20 us;
    enable_i <= '0';
    assert status_o = '1' report "Status should be true" severity error;
    wait for 10 us;
    assert status_o = '0' report "Status should be false" severity error;
    stop;
  end process WaveGen_Proc;

end architecture frame_tb;

