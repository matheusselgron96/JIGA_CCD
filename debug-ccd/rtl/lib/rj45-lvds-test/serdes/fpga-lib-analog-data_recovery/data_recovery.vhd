-------------------------------------------------------------------------------
-- Title      : data_recovery.vhd
-- Project    : Marte
-------------------------------------------------------------------------------
-- File       : data_recovery.vhd
-- Author     :   <reny@SEL107>
-- Company    : Selgron
-- Created    : 2021-06-16
-- Last update: 2022-07-07
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: asynchronous oversampling module
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

entity data_recovery is

  generic (
    BYTES_COUNTER          : integer := 100;  -- packet max bytes
    MIN_START_PULSE_CYCLES : integer := 5;
    TYPE_OF_RETURN         : integer := 0
    );  -- min start pulse to module consider as
          -- new packet

  port (
    clk0            : in  std_logic;    -- clock from pll 0 degrees
    clk90           : in  std_logic;    -- clock from pll 90 degrees
    rst_n           : in  std_logic;    -- reset_n
    sop_o           : out std_logic;
    serial_data_i   : in  std_logic;    -- differential input data
    parallel_data_o : out std_logic_vector(7 downto 0);  -- parallel register out data
    data_valid_o    : out std_logic
    );

end entity data_recovery;

architecture data_recovery_rtl of data_recovery is
  ------------------------------------------------------------------------
  -- constants
  ------------------------------------------------------------------------
  constant DATA_REG_WIDTH      : integer := 6;  --  data path to prevent  metastability and change clock domain to clk 0 degrees
  constant COUNTER_BYTES_WIDTH : integer := integer(ceil(log2(real(BYTES_COUNTER))));
  constant START_PULSE_WIDTH   : integer := integer(ceil(log2(real(MIN_START_PULSE_CYCLES))));

  -- main state machine
  type DR_ST_TYPE is (ST_WAIT_VALID,
                      ST_FIRST_TRANSITION,
                      ST_WAIT_START_BIT_HIGH,
                      ST_WAIT_ZERO_TRANSITION,
                      ST_SHIFT_REG);
  ------------------------------------------------------------------------
  -- signals
  ------------------------------------------------------------------------
  signal st_dr_reg, st_dr_next                       : DR_ST_TYPE                                  := ST_WAIT_VALID;  -- state machine register
  signal data_phase0_reg, data_phase0_next           : std_logic_vector(DATA_REG_WIDTH-1 downto 0) := (others => '0');  -- reg 0 degrees
  signal data_phase90_reg, data_phase90_next         : std_logic_vector(DATA_REG_WIDTH-1 downto 0) := (others => '0');  -- reg 90 degrees
  signal data_phase180_reg, data_phase180_next       : std_logic_vector(DATA_REG_WIDTH-1 downto 0) := (others => '0');  -- reg 180 degrees
  signal data_phase270_reg, data_phase270_next       : std_logic_vector(DATA_REG_WIDTH-1 downto 0) := (others => '0');  -- reg 270 degrees
  signal xor_p_clk0_reg, xor_p_clk0_next             : std_logic                                   := '0';
  signal xor_p_clk90_reg, xor_p_clk90_next           : std_logic                                   := '0';
  signal xor_p_clk180_reg, xor_p_clk180_next         : std_logic                                   := '0';
  signal xor_p_clk270_reg, xor_p_clk270_next         : std_logic                                   := '0';
  signal xor_n_clk0_reg, xor_n_clk0_next             : std_logic                                   := '0';
  signal xor_n_clk90_reg, xor_n_clk90_next           : std_logic                                   := '0';
  signal xor_n_clk180_reg, xor_n_clk180_next         : std_logic                                   := '0';
  signal xor_n_clk270_reg, xor_n_clk270_next         : std_logic                                   := '0';
  signal bit_sel_reg, bit_sel_next                   : std_logic_vector(1 downto 0)                := (others => '0');
  signal selected_bit_reg, selected_bit_next         : std_logic                                   := '0';
  signal transition_found_reg, transition_found_next : std_logic                                   := '0';
  signal transition_true_reg, transition_true_next   : std_logic                                   := '0';
  signal shift_reg, shift_next                       : std_logic_vector(7 downto 0)                := (others => '0');
  signal bit_counter_reg, bit_counter_next           : unsigned(2 downto 0)                        := (others => '0');
  signal data_out_reg, data_out_next                 : std_logic_vector(7 downto 0)                := (others => '0');
  signal flag_start_reg, flag_start_next             : std_logic                                   := '0';
  signal bytes_counter_reg, bytes_counter_next       : unsigned(COUNTER_BYTES_WIDTH downto 0)      := (others => '0');
  signal pulse_counter_reg, pulse_counter_next       : unsigned(START_PULSE_WIDTH-1 downto 0)      := (others => '0');
  signal ok_to_check_reg, ok_to_check_next           : std_logic                                   := '0';
  signal dv_reg, dv_next                             : std_logic                                   := '0';
  signal valid_tor_flag_reg, valid_tor_flag_next     : std_logic                                   := '0';

begin  -- architecture data_recovery_rtl

  --out definitions
  parallel_data_o <= data_out_reg;
  data_valid_o    <= dv_reg;
  sop_o           <= transition_true_reg;

  -- four process to put all sampled data in sysclk domain (clk0)    
  reg_process_clk0 : process (clk0) is
  begin
    if rising_edge(clk0) then
      data_phase0_reg                              <= data_phase0_next;
      data_phase90_reg(DATA_REG_WIDTH-1 downto 1)  <= data_phase90_next(DATA_REG_WIDTH-1 downto 1);
      data_phase180_reg(DATA_REG_WIDTH-1 downto 2) <= data_phase180_next(DATA_REG_WIDTH-1 downto 2);
      data_phase270_reg(DATA_REG_WIDTH-1 downto 3) <= data_phase270_next(DATA_REG_WIDTH-1 downto 3);
    end if;
  end process reg_process_clk0;

  comb_process_clk0 : process (data_phase0_reg, serial_data_i) is
  begin
    data_phase0_next(0) <= serial_data_i;
    data_phase0_next(1) <= data_phase0_reg(0);
    data_phase0_next(2) <= data_phase0_reg(1);
    data_phase0_next(3) <= data_phase0_reg(2);
    data_phase0_next(4) <= data_phase0_reg(3);
    data_phase0_next(5) <= data_phase0_reg(4);
  end process comb_process_clk0;

  -------------------------------------------
  reg_process_clk90 : process (clk90) is
  begin
    if rising_edge(clk90) then
      data_phase90_reg(0)  <= data_phase90_next(0);
      data_phase180_reg(1) <= data_phase180_next(1);
      data_phase270_reg(2) <= data_phase270_next(2);
    end if;
  end process reg_process_clk90;

  comb_process_clk90 : process (data_phase90_reg, serial_data_i) is
  begin
    data_phase90_next(0) <= serial_data_i;
    data_phase90_next(1) <= data_phase90_reg(0);
    data_phase90_next(2) <= data_phase90_reg(1);
    data_phase90_next(3) <= data_phase90_reg(2);
    data_phase90_next(4) <= data_phase90_reg(3);
    data_phase90_next(5) <= data_phase90_reg(4);
  end process comb_process_clk90;

  -------------------------------------------
  reg_process_clk180 : process (clk0) is
  begin
    if falling_edge(clk0) then
      data_phase180_reg(0) <= data_phase180_next(0);
      data_phase270_reg(1) <= data_phase270_next(1);
    end if;
  end process reg_process_clk180;

  comb_process_clk180 : process (data_phase180_reg, serial_data_i) is
  begin
    data_phase180_next(0) <= serial_data_i;
    data_phase180_next(1) <= data_phase180_reg(0);
    data_phase180_next(2) <= data_phase180_reg(1);
    data_phase180_next(3) <= data_phase180_reg(2);
    data_phase180_next(4) <= data_phase180_reg(3);
    data_phase180_next(5) <= data_phase180_reg(4);
  end process comb_process_clk180;

  -------------------------------------------
  reg_process_clk270 : process (clk90) is
  begin
    if falling_edge(clk90) then
      data_phase270_reg(0) <= data_phase270_next(0);
    end if;
  end process reg_process_clk270;

  comb_process_clk270 : process (data_phase270_reg, serial_data_i) is
  begin
    data_phase270_next(0) <= serial_data_i;
    data_phase270_next(1) <= data_phase270_reg(0);
    data_phase270_next(2) <= data_phase270_reg(1);
    data_phase270_next(3) <= data_phase270_reg(2);
    data_phase270_next(4) <= data_phase270_reg(3);
    data_phase270_next(5) <= data_phase270_reg(4);
  end process comb_process_clk270;

  -- sysclk register process   
  reg_process_sysclk : process (clk0) is
  begin
    if rising_edge(clk0) then
      st_dr_reg            <= st_dr_next;
      xor_p_clk0_reg       <= xor_p_clk0_next;
      xor_p_clk90_reg      <= xor_p_clk90_next;
      xor_p_clk180_reg     <= xor_p_clk180_next;
      xor_p_clk270_reg     <= xor_p_clk270_next;
      xor_n_clk0_reg       <= xor_n_clk0_next;
      xor_n_clk90_reg      <= xor_n_clk90_next;
      xor_n_clk180_reg     <= xor_n_clk180_next;
      xor_n_clk270_reg     <= xor_n_clk270_next;
      bit_sel_reg          <= bit_sel_next;
      selected_bit_reg     <= selected_bit_next;
      bytes_counter_reg    <= bytes_counter_next;
      transition_found_reg <= transition_found_next;
      shift_reg            <= shift_next;
      bit_counter_reg      <= bit_counter_next;
      data_out_reg         <= data_out_next;
      flag_start_reg       <= flag_start_next;
      ok_to_check_reg      <= ok_to_check_next;
      dv_reg               <= dv_next;
      pulse_counter_reg    <= pulse_counter_next;
      transition_true_reg  <= transition_true_next;
      valid_tor_flag_reg   <= valid_tor_flag_next;
    end if;
  end process reg_process_sysclk;


  -- xor codes
  comb_process_xor : process (data_phase0_reg, data_phase180_reg,
                              data_phase270_reg, data_phase90_reg) is
  begin
    -- L to H transitions
    xor_p_clk0_next   <= (data_phase0_reg(DATA_REG_WIDTH-2) xor data_phase0_reg(DATA_REG_WIDTH-3)) and data_phase0_reg(DATA_REG_WIDTH-3);
    xor_p_clk90_next  <= (data_phase90_reg(DATA_REG_WIDTH-2) xor data_phase90_reg(DATA_REG_WIDTH-3)) and data_phase90_reg(DATA_REG_WIDTH-3);
    xor_p_clk180_next <= (data_phase180_reg(DATA_REG_WIDTH-2) xor data_phase180_reg(DATA_REG_WIDTH-3)) and data_phase180_reg(DATA_REG_WIDTH-3);
    xor_p_clk270_next <= (data_phase270_reg(DATA_REG_WIDTH-2) xor data_phase270_reg(DATA_REG_WIDTH-3)) and data_phase270_reg(DATA_REG_WIDTH-3);
    -- H to L transitions
    xor_n_clk0_next   <= (data_phase0_reg(DATA_REG_WIDTH-2) xor data_phase0_reg(DATA_REG_WIDTH-3)) and not(data_phase0_reg(DATA_REG_WIDTH-3));
    xor_n_clk90_next  <= (data_phase90_reg(DATA_REG_WIDTH-2) xor data_phase90_reg(DATA_REG_WIDTH-3)) and not(data_phase90_reg(DATA_REG_WIDTH-3));
    xor_n_clk180_next <= (data_phase180_reg(DATA_REG_WIDTH-2) xor data_phase180_reg(DATA_REG_WIDTH-3)) and not(data_phase180_reg(DATA_REG_WIDTH-3));
    xor_n_clk270_next <= (data_phase270_reg(DATA_REG_WIDTH-2) xor data_phase270_reg(DATA_REG_WIDTH-3)) and not(data_phase270_reg(DATA_REG_WIDTH-3));

  end process comb_process_xor;

  comb_process_sel_data : process(bit_sel_reg, data_phase0_reg,
                                  data_phase180_reg, data_phase270_reg,
                                  data_phase90_reg, ok_to_check_reg,
                                  xor_n_clk0_reg, xor_n_clk180_reg,
                                  xor_n_clk270_reg, xor_n_clk90_reg,
                                  xor_p_clk0_reg, xor_p_clk180_reg,
                                  xor_p_clk270_reg, xor_p_clk90_reg) is
  begin

    bit_sel_next          <= bit_sel_reg;
    transition_found_next <= '0';
    selected_bit_next     <= '0';

    if ok_to_check_reg = '1' then
      -- 0 degrees first to see the data, use actual 180 data
      if (xor_p_clk0_reg = '1' and xor_p_clk90_reg = '1' and xor_p_clk180_reg = '1' and xor_p_clk270_reg = '1') or (xor_n_clk0_reg = '1' and xor_n_clk90_reg = '1' and xor_n_clk180_reg = '1' and xor_n_clk270_reg = '1') then
        bit_sel_next          <= "10";
        transition_found_next <= '1';
      --90 degrees first to see the data, use actual 270 data
      elsif (xor_p_clk0_reg = '0' and xor_p_clk90_reg = '1' and xor_p_clk180_reg = '1' and xor_p_clk270_reg = '1') or (xor_n_clk0_reg = '0' and xor_n_clk90_reg = '1' and xor_n_clk180_reg = '1' and xor_n_clk270_reg = '1') then
        bit_sel_next          <= "11";
        transition_found_next <= '1';
      -- 180 degrees first to see the data, use next 0 data  
      elsif (xor_p_clk0_reg = '0' and xor_p_clk90_reg = '0' and xor_p_clk180_reg = '1' and xor_p_clk270_reg = '1') or (xor_n_clk0_reg = '0' and xor_n_clk90_reg = '0' and xor_n_clk180_reg = '1' and xor_n_clk270_reg = '1') then
        bit_sel_next          <= "00";
        transition_found_next <= '1';
      -- 270 degrees first to see the data, use next 90 data  
      elsif (xor_p_clk0_reg = '0' and xor_p_clk90_reg = '0' and xor_p_clk180_reg = '0' and xor_p_clk270_reg = '1') or (xor_n_clk0_reg = '0' and xor_n_clk90_reg = '0' and xor_n_clk180_reg = '0' and xor_n_clk270_reg = '1') then
        bit_sel_next          <= "01";
        transition_found_next <= '1';
      end if;
    end if;

    -- mux
    if bit_sel_reg = "00" then
      selected_bit_next <= data_phase0_reg(DATA_REG_WIDTH-2);
    elsif bit_sel_reg = "01" then
      selected_bit_next <= data_phase90_reg(DATA_REG_WIDTH-2);
    elsif bit_sel_reg = "10" then
      selected_bit_next <= data_phase180_reg(DATA_REG_WIDTH-1);
    elsif bit_sel_reg = "11" then
      selected_bit_next <= data_phase270_reg(DATA_REG_WIDTH-1);
    end if;

  end process comb_process_sel_data;


  comb_st : process (bit_counter_reg, bytes_counter_reg, data_out_reg,
                     flag_start_reg, ok_to_check_reg, pulse_counter_reg,
                     selected_bit_reg, shift_reg, st_dr_reg,
                     transition_found_reg) is
  begin
    st_dr_next           <= st_dr_reg;
    shift_next           <= shift_reg;
    data_out_next        <= data_out_reg;
    bit_counter_next     <= bit_counter_reg;
    flag_start_next      <= flag_start_reg;
    bytes_counter_next   <= bytes_counter_reg;
    ok_to_check_next     <= ok_to_check_reg;
    dv_next              <= '0';
    pulse_counter_next   <= pulse_counter_reg + 1;
    transition_true_next <= '0';
    valid_tor_flag_next  <= valid_tor_flag_reg;

    case st_dr_reg is

      when ST_WAIT_VALID =>
        ok_to_check_next <= '1';
        if transition_found_reg = '1' then
          st_dr_next          <= ST_FIRST_TRANSITION;
          ok_to_check_next    <= '0';
          valid_tor_flag_next <= '1';
        end if;

      when ST_FIRST_TRANSITION =>
        if selected_bit_reg = '1' then
          st_dr_next <= ST_WAIT_START_BIT_HIGH;
        else
          st_dr_next <= ST_WAIT_VALID;
        end if;
        pulse_counter_next <= (others => '0');

      when ST_WAIT_START_BIT_HIGH =>
        if selected_bit_reg = '1' then
          if pulse_counter_reg = MIN_START_PULSE_CYCLES - 1 then
            st_dr_next <= ST_WAIT_ZERO_TRANSITION;
          end if;
        else
          st_dr_next <= ST_WAIT_VALID;
        end if;

      when ST_WAIT_ZERO_TRANSITION =>
        if selected_bit_reg = '0' then
          st_dr_next           <= ST_SHIFT_REG;
          transition_true_next <= '1';
        else
          st_dr_next <= ST_WAIT_VALID;
        end if;

      when ST_SHIFT_REG =>
        shift_next       <= shift_reg(6 downto 0) & selected_bit_reg;
        bit_counter_next <= bit_counter_reg + 1;
        flag_start_next  <= '1';
        if bit_counter_reg = 0 and flag_start_reg = '1' then
          data_out_next      <= shift_reg;
          bytes_counter_next <= bytes_counter_reg + 1;

          -- bytes_counter_reg < 8 to ensure type of return will be sent to FIFO and 
          if valid_tor_flag_reg = '1' or bytes_counter_reg < 8 then
            dv_next <= '1';
          end if;

          -- TOR byte
          if bytes_counter_reg = 4 and TYPE_OF_RETURN = 1 then
            -- Check if TOR is not 0
            if shift_reg = x"00" then
              -- Set flag which will block data_valid from going up when TOR is equal to 0
              valid_tor_flag_next <= '0';
            end if;
          end if;
        end if;

        if bytes_counter_reg = BYTES_COUNTER then
          st_dr_next         <= ST_WAIT_VALID;
          bytes_counter_next <= (others => '0');
          flag_start_next    <= '0';
          bit_counter_next   <= (others => '0');
        end if;

    end case;

  end process comb_st;

end architecture data_recovery_rtl;
