-------------------------------------------------------------------------------
-- Title      : Testbench for design "rjtester"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rjtester_tb.vhd
-- Author     : U-DESKTOP-9VMS10B\elias  <elias@DESKTOP-9VMS10B>
-- Company    : 
-- Created    : 2023-10-21
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
-- 2023-10-21  1.0      elias   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use std.env.all;
use ieee.Numeric_Std.all;

-------------------------------------------------------------------------------

entity rjtester_tb is

end entity rjtester_tb;

-------------------------------------------------------------------------------

architecture rjtester_tb of rjtester_tb is

  signal sysclk : std_logic := '1';
  signal rst_n  : std_logic := '0';

  signal avmm_address   : std_logic_vector(3 downto 0);
  signal avmm_write     : std_logic := '0';
  signal avmm_writedata : std_logic_vector(31 downto 0);
  signal avmm_read      : std_logic := '0';
  signal avmm_readdata  : std_logic_vector(31 downto 0);

  signal clk0_0       : std_logic := '0';
  signal clk0_90      : std_logic;
  signal tx0_serial_o : std_logic;
  signal rx0_serial_i : std_logic;

  signal tx1_serial_o : std_logic;
  signal rx1_serial_i : std_logic;

  signal clk2_0       : std_logic := '0';
  signal clk2_90      : std_logic;
  signal tx2_serial_o : std_logic;
  signal rx2_serial_i : std_logic;

begin  -- architecture rjtester_tb

  -- component instantiation
  DUT : entity work.rjtester
    generic map (
      PERIOD_SYNC_US       => 100,
      LINK_0_FREQUENCY_MHZ => 50,
      LINK_0_NUM_BYTES     => 500,
      LINK_2_FREQUENCY_MHZ => 20,
      LINK_2_NUM_BYTES     => 80
      )
    port map (
      rst_n          => rst_n,
      sysclk         => sysclk,
      avmm_address   => avmm_address,
      avmm_write     => avmm_write,
      avmm_writedata => avmm_writedata,
      avmm_read      => avmm_read,
      avmm_readdata  => avmm_readdata,
      clk0_0         => clk0_0,
      clk0_90        => clk0_90,
      tx0_serial_o   => tx0_serial_o,
      rx0_serial_i   => rx0_serial_i,
      tx1_serial_o   => tx1_serial_o,
      rx1_serial_i   => rx1_serial_i,
      clk2_0         => clk2_0,
      clk2_90        => clk2_90,
      tx2_serial_o   => tx2_serial_o,
      rx2_serial_i   => rx2_serial_i);

  rx0_serial_i <= transport tx0_serial_o after 13 ns;
  rx1_serial_i <= transport tx1_serial_o after 43 ns;
  rx2_serial_i <= transport tx2_serial_o after 21 ns;

  -- 100Mhz
  sysclk  <= not sysclk after 5 ns;
  -- 50Mhz
  clk0_0  <= not clk0_0 after 10 ns;
  clk0_90 <= clk0_0     after 5 ns;
  -- 25Mhz
  clk2_0  <= not clk2_0 after 25 ns;
  clk2_90 <= clk2_0     after 12.5 ns;

  process
    procedure mm_write(address : integer; data : std_logic_vector) is
    begin
      avmm_address   <= std_logic_vector(to_unsigned(address, avmm_address'length));
      avmm_writedata <= data;
      avmm_write     <= '1';
      wait for 10 ns;
      avmm_write     <= '0';
      avmm_address   <= (others => 'X');
      avmm_writedata <= (others => 'X');
      wait for 10 ns;
    end procedure mm_write;
    procedure mm_read(address : integer; data : std_logic_vector) is
    begin
      avmm_address <= std_logic_vector(to_unsigned(address, avmm_address'length));
      avmm_read    <= '1';
      wait for 10 ns;
      wait for 10 ns;
      assert avmm_readdata = data report "Mistmatch on read" severity error;
      avmm_read    <= '0';
      avmm_address <= (others => 'X');
      wait for 10 ns;
    end procedure mm_read;
  begin
    wait until sysclk = '1';
    wait for 1 us;
    rst_n <= '1';
    wait for 1 us;
    -- Ensure we have no data being received
    mm_read(address  => 1, data => X"00000001");
    mm_read(address  => 3, data => X"00000001");
    -- TX 0 Enabled
    mm_write(address => 0, data => X"00000001");
    mm_read(address  => 0, data => X"00000001");
    wait for 200 us;
    -- Link 0 is receiving Link 1 is not
    mm_read(address  => 1, data => X"00000002");
    mm_read(address  => 3, data => X"00000001");
    wait for 200 us;
    -- TX 1 Enabled
    mm_write(address => 2, data => X"00000001");
    mm_read(address  => 2, data => X"00000001");
    wait for 200 us;
    -- Both links are receiving
    mm_read(address  => 1, data => X"00000002");
    mm_read(address  => 3, data => X"00000002");
    wait for 200 us;
    -- TX 0 Disabled
    mm_write(address => 0, data => X"00000000");
    mm_read(address  => 0, data => X"00000000");
    wait for 200 us;
    -- Link 1 is receiving
    mm_read(address  => 1, data => X"00000002");
    mm_read(address  => 3, data => X"00000002");
    wait for 200 us;
    -- TX 1 Disabled
    mm_write(address => 2, data => X"00000000");
    mm_read(address  => 2, data => X"00000000");
    wait for 200 us;
    -- No one is receving
    mm_read(address  => 1, data => X"00000001");
    mm_read(address  => 3, data => X"00000001");
    wait for 200 us;
    -- TX 2 Enabled
    mm_write(address => 4, data => X"00000001");
    mm_read(address  => 4, data => X"00000001");
    wait for 200 us;
    -- Link 2 is receiving, others not
    mm_read(address  => 1, data => X"00000001");
    mm_read(address  => 3, data => X"00000001");
    mm_read(address  => 5, data => X"00000002");
    stop;
  end process;

end architecture rjtester_tb;
-------------------------------------------------------------------------------
