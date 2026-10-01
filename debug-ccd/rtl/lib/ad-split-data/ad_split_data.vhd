-------------------------------------------------------------------------------
-- Title      : ad-split-data
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ad-split-data.vhd
-- Author     :   <soly@SEL171>
-- Company    : 
-- Created    : 2023-10-24
-- Last update: 2023-10-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-10-24  1.0      soly    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ad_split is

  port (
    sysclk : in std_logic;
    rst_n  : in std_logic;

    asi_ad_data_i  : in std_logic_vector(47 downto 0);
    asi_ad_valid_i : in std_logic;

    aso_ad_data_odd_o  : out std_logic_vector(31 downto 0);
    aso_ad_valid_odd_o : out std_logic;

    aso_ad_data_even_o  : out std_logic_vector(31 downto 0);
    aso_ad_valid_even_o : out std_logic
    );

end entity ad_split;

architecture ad_split_rtl of ad_split is
  signal data_i_reg, data_i_next   : std_logic_vector(47 downto 0) := (others => '0');
  signal valid_i_reg, valid_i_next : std_logic                     := '0';

begin  -- architecture ad_split_rtl


  reg_process : process (sysclk) is
  begin  -- process reg_process
    data_i_reg  <= data_i_next;
    valid_i_reg <= valid_i_next;
  end process reg_process;

  process (asi_ad_data_i, asi_ad_valid_i, data_i_reg, valid_i_reg) is
  begin  -- process
    valid_i_next        <= asi_ad_valid_i;
    data_i_next         <= asi_ad_data_i;
    aso_ad_valid_even_o <= '0';
    aso_ad_valid_odd_o  <= '0';
    aso_ad_data_even_o  <= (others => '0');
    aso_ad_data_odd_o   <= (others => '0');
    if valid_i_reg = '1' then
      aso_ad_valid_even_o              <= '1';
      aso_ad_valid_odd_o               <= '1';
      aso_ad_data_even_o(31 downto 24) <= (others => '0');
      aso_ad_data_even_o(23 downto 0)  <= data_i_reg(47 downto 24);
      aso_ad_data_odd_o(31 downto 24)  <= (others => '0');
      aso_ad_data_odd_o(23 downto 0)   <= data_i_reg(23 downto 0);

    end if;
  end process;

end architecture ad_split_rtl;

