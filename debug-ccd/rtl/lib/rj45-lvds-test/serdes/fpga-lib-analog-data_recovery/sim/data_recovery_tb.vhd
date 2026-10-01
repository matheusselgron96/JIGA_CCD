-------------------------------------------------------------------------------
-- Title      : Testbench for design "data_recovery"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : data_recovery_tb.vhd
-- Author     :   <reny@SEL107>
-- Company    : 
-- Created    : 2021-06-16
-- Last update: 2021-06-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-06-16  1.0      reny    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-------------------------------------------------------------------------------

entity data_recovery_tb is

end entity data_recovery_tb;

-------------------------------------------------------------------------------

architecture test_bench of data_recovery_tb is

  -- component generics
  constant BYTES_COUNTER : integer := 100;

  -- component ports
  signal clk0            : std_logic := '1';
  signal clk90           : std_logic := '1';
  signal rst_n           : std_logic := '1';
  signal serial_data_i   : std_logic := '0';
  signal parallel_data_o : std_logic_vector(7 downto 0);
  signal data_valid_o    : std_logic;

begin  -- architecture test_bench

  -- component instantiation
  DUT : entity work.data_recovery
    generic map (
      BYTES_COUNTER => BYTES_COUNTER)
    port map (
      clk0            => clk0,
      clk90           => clk90,
      rst_n           => rst_n,
      serial_data_i   => serial_data_i,
      parallel_data_o => parallel_data_o
      data_valid_o    => data_valid_o);

  -- clock generation
  clk0  <= not clk0       after 5 ns;
  clk90 <= transport clk0 after 2.5 ns;

  -- waveform generation
  tb : process
    variable data_vec : std_logic_vector(7 downto 0) := (others => '0');

  begin
    wait for 1 us;
    wait for 4.5 ns;                    --first xor to detect data 90 degrees

    for i in 0 to 10 loop               -- number of packets

      serial_data_i <= '1';
      wait for 500 ns;                  -- first ones

      serial_data_i <= '0';             -- start bit
      wait for 10 ns;

      data_vec := "10100101";
      for ii in 0 to 50 loop            -- number of words

        for i in 0 to 7 loop
          serial_data_i <= data_vec(i);
          wait for 10 ns;
        end loop;

        data_vec := not(data_vec);
      end loop;
      serial_data_i <= '0';

      wait for 10 us;                   -- delay between packets

    end loop;


    -- first data to detect data 0 degrees
    -- wait for 8.5 ns;

    -- first data to detect data 180 degrees
    -- wait for 4.5 ns;

    -- first data to detect data 270 degrees
    -- wait for 6 ns;

    wait;
  end process tb;

end architecture test_bench;
