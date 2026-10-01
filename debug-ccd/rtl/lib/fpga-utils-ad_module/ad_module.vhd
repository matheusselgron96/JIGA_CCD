-------------------------------------------------------------------------------
-- Title      : ad_module
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ad_module.vhd
-- Author     :   <soly@SEL079>
-- Company    : 
-- Created    : 2021-08-11
-- Last update: 2022-11-18
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-08-11  1.0      soly    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ad_module is
  port(

    --  sysclk : in std_logic;
    reset                    : in  std_logic;
    -- Sync Input
    sync_i                   : in  std_logic;
    -- AVS Input Config
    avs_ad_data_i            : in  std_logic_vector(15 downto 0);
    avs_ad_addr_i            : in  std_logic_vector(3 downto 0);
    avs_ad_write_i           : in  std_logic;
    -- DataOut
    aso_ad_data_analysis0_o  : out std_logic_vector(47 downto 0);
    aso_ad_valid_analysis0_o : out std_logic;
    aso_ad_data_analysis1_o  : out std_logic_vector(47 downto 0);
    aso_ad_valid_analysis1_o : out std_logic;
    aso_ad_data_analysis2_o  : out std_logic_vector(47 downto 0);
    aso_ad_valid_analysis2_o : out std_logic;
    aso_ad_data_analysis3_o  : out std_logic_vector(47 downto 0);
    aso_ad_valid_analysis3_o : out std_logic;

    --
    aso_ad_data_window_o  : out std_logic_vector(47 downto 0);
    aso_ad_valid_window_o : out std_logic;
    -- PLL
    pll_30_1_input        : in  std_logic;
    pll_30_2_input        : in  std_logic;
    pll_30_3_input        : in  std_logic;
    pll_30_4_input        : in  std_logic;
    pll_30_5_input        : in  std_logic;
    -- AD input
    ad_0_data_i           : in  std_logic_vector(11 downto 0);  -- Red Even
    ad_1_data_i           : in  std_logic_vector(11 downto 0);  -- Red Odd
    ad_2_data_i           : in  std_logic_vector(11 downto 0);  -- Green Even
    ad_3_data_i           : in  std_logic_vector(11 downto 0);  -- Green Odd
    ad_4_data_i           : in  std_logic_vector(11 downto 0);  -- Blue Even
    ad_5_data_i           : in  std_logic_vector(11 downto 0);  -- Blue Odd
    -- CCD signals
    ccd_theta_1a_o        : out std_logic;
    ccd_theta_2a_o        : out std_logic;
    ccd_theta_2b_o        : out std_logic;
    ccd_rs_o              : out std_logic;
    ccd_cp_o              : out std_logic;
    ccd_sh_o              : out std_logic;
    --sinais de clock  para cada módulo ad
    ad_dataclk_o          : out std_logic;
    ad_shp_o              : out std_logic;
    ad_shd_o              : out std_logic;
    ad_pblk_o             : out std_logic;
    ad_cplob_o            : out std_logic;
    -- sinais para fifo_to_packet
    aso_ad_data_fifo_o    : out std_logic_vector(47 downto 0);
    aso_ad_valid_fifo_o   : out std_logic;
    save_to_fifo_i        : in  std_logic
    );
end entity ad_module;

architecture ad_module_rtl of ad_module is

  type SYNC_ST_TYPE is (WAIT_SYNC, WAIT_VALID, RECEIVE_CCD);
  subtype DATA_VEC_SUB is std_logic_vector(15 downto 0);
  type DATA_VEC_TYPE is array (1 to 5) of DATA_VEC_SUB;
  constant DATA_WIDTH                              : integer                       := 12;
  constant START_SH                                : integer                       := 0;
  constant END_SH                                  : integer                       := 30;
  constant START_CPLOB                             : integer                       := 79;
  constant END_CPLOB                               : integer                       := 120;
  constant START_PBLK                              : integer                       := 2830;
  constant END_PBLK                                : integer                       := 2838;
  constant END_COUNTER                             : integer                       := 3000;
  constant START_WINDOW_OFFSET                     : integer                       := 32;
  constant START_ANALYSIS_OFFSET                   : integer                       := 32;
  constant END_ANALYSIS_OFFSET                     : integer                       := 1040;
  constant END_WINDOW_OFFSET                       : integer                       := 1356;
  constant START_CLK                               : integer                       := 65;  --
  --starts at 1166 ns
  constant END_CLK                                 : integer                       := 2900;
  signal address_reg, address_next                 : unsigned(3 downto 0)          := (others => '0');
  signal data_i_reg, data_i_next                   : std_logic_vector(15 downto 0) := (others => '0');
  signal av_write_reg, av_write_next               : std_logic                     := '0';
  signal data_vec_reg, data_vec_next               : DATA_VEC_TYPE                 := (others => (others => '0'));
  signal sync_st_reg, sync_st_next                 : SYNC_ST_TYPE                  := WAIT_SYNC;
  signal pll_0, pll_1, pll_2, pll_3, pll_4, pll_5  : std_logic                     := '0';
  signal bit_counter_reg, bit_counter_next         : unsigned(16 downto 0)         := (others => '0');
  signal data_0_reg, data_0_next                   : std_logic_vector(11 downto 0) := (others => '0');
  signal data_1_reg, data_1_next                   : std_logic_vector(11 downto 0) := (others => '0');
  signal data_2_reg, data_2_next                   : std_logic_vector(11 downto 0) := (others => '0');
  signal data_3_reg, data_3_next                   : std_logic_vector(11 downto 0) := (others => '0');
  signal data_4_reg, data_4_next                   : std_logic_vector(11 downto 0) := (others => '0');
  signal data_5_reg, data_5_next                   : std_logic_vector(11 downto 0) := (others => '0');
  signal cplob_reg, cplob_next                     : std_logic                     := '1';
  signal pblk_reg, pblk_next                       : std_logic                     := '1';
  signal sh_reg, sh_next                           : std_logic                     := '0';
  signal shp_reg, shp_next                         : std_logic                     := '0';
  signal shd_reg, shd_next                         : std_logic                     := '0';
  signal sync_reg, sync_next                       : std_logic                     := '0';
  signal sync_old_reg, sync_old_next               : std_logic                     := '0';
  signal clock_enable_reg, clock_enable_next       : std_logic                     := '0';
  signal pixel_counter_reg, pixel_counter_next     : unsigned(16 downto 0)         := (others => '0');
  signal save_pixel_a_reg, save_pixel_a_next       : std_logic                     := '0';
  signal save_pixel_w_reg, save_pixel_w_next       : std_logic                     := '0';
  signal st_w_offset_reg, st_w_offset_next         : unsigned(15 downto 0)         := (others => '0');
  signal st_a_offset_reg, st_a_offset_next         : unsigned(15 downto 0)         := (others => '0');
  signal end_w_offset_reg, end_w_offset_next       : unsigned(15 downto 0)         := (others => '0');
  signal end_a_offset_reg, end_a_offset_next       : unsigned(15 downto 0)         := (others => '0');
  signal enable_reg, enable_next                   : std_logic                     := '0';
  signal temp_ad_data_1                            : unsigned(11 downto 0)         := (others => '0');
  signal temp_ad_data_2                            : unsigned(11 downto 0)         := (others => '0');
  signal temp_ad_data_3                            : unsigned(11 downto 0)         := (others => '0');
  signal temp_ad_data_4                            : unsigned(11 downto 0)         := (others => '0');
  signal temp_ad_data_5                            : unsigned(11 downto 0)         := (others => '0');
  signal temp_ad_data_0                            : unsigned(11 downto 0)         := (others => '0');
  signal save_to_fifo_reg, save_to_fifo_next       : std_logic                     := '0';
  signal save_pixel_fifo_reg, save_pixel_fifo_next : std_logic                     := '0';

  signal data_gb_prev_reg, data_gb_prev_next : std_logic_vector(31 downto 0) := (others => '0');
  signal data_b_prev_reg, data_b_prev_next   : std_logic_vector(15 downto 0) := (others => '0');
  signal data_out_gb_int                     : std_logic_vector(31 downto 0) := (others => '0');
  signal data_out_b_int                      : std_logic_vector(15 downto 0) := (others => '0');
  signal rdreq_gb_reg, rdreq_gb_next         : std_logic                     := '0';
  signal wreq_gb_reg, wreq_gb_next           : std_logic                     := '0';
  signal rdreq_b_reg, rdreq_b_next           : std_logic                     := '0';
  signal wreq_b_reg, wreq_b_next             : std_logic                     := '0';
  signal fifo_clear_reg, fifo_clear_next     : std_logic                     := '0';
  signal used_gb_int                         : std_logic_vector(11 downto 0) := (others => '0');
  signal used_b_int                          : std_logic_vector(11 downto 0) := (others => '0');
  signal start_gb_reg, start_gb_next         : std_logic                     := '0';
  signal start_b_reg, start_b_next           : std_logic                     := '0';
  signal aux_fifo_reg, aux_fifo_next         : std_logic_vector(15 downto 0) := (others => '0');
  signal aux_fifo_gb_reg, aux_fifo_gb_next   : std_logic_vector(31 downto 0) := (others => '0');

begin  -- architecture ad_module_rtl


  fifo_serdes_gb : entity work.fifo_serdes_gb
    port map(
      clock => pll_3,
      data  => data_gb_prev_reg,
      rdreq => rdreq_gb_next,
      wrreq => wreq_gb_reg,
      q     => data_out_gb_int,
      sclr  => fifo_clear_reg,
      usedw => used_gb_int);

  fifo_serdes_b : entity work.fifo_serdes_b
    port map(
      clock => pll_3,
      data  => data_b_prev_reg,
      rdreq => rdreq_b_next,
      wrreq => wreq_b_reg,
      q     => data_out_b_int,
      sclr  => fifo_clear_reg,
      usedw => used_b_int);



  pll_0          <= pll_30_1_input;
  pll_1          <= not pll_30_1_input;
  pll_2          <= pll_30_2_input;
  pll_3          <= pll_30_3_input;
  pll_4          <= pll_30_4_input;
  pll_5          <= pll_30_5_input;
  --
  ccd_theta_1a_o <= pll_0 when clock_enable_reg = '1' else '1';
  ccd_theta_2a_o <= pll_1 when clock_enable_reg = '1' else '0';
  ccd_theta_2b_o <= pll_1 when clock_enable_reg = '1' else '0';
  ccd_cp_o       <= pll_1 when clock_enable_reg = '1' else '0';
  ccd_rs_o       <= pll_2 when clock_enable_reg = '1' else '0';
  --
  ad_dataclk_o   <= pll_3 when clock_enable_reg = '1' else '0';
  ad_shp_o       <= pll_4 when clock_enable_reg = '1' else '0';
  ad_shd_o       <= pll_5 when clock_enable_reg = '1' else '0';
  ad_cplob_o     <= cplob_reg;
  ad_pblk_o      <= pblk_reg;
  ccd_sh_o       <= sh_reg;
  --
  aso_ad_data_window_o(47 downto 40) <= data_1_reg(11 downto 4);        -- R
  aso_ad_data_window_o(39 downto 32) <= data_out_gb_int(31 downto 24);  -- G
  aso_ad_data_window_o(31 downto 24) <= aux_fifo_reg(15 downto 8);    -- B
  aso_ad_data_window_o(23 downto 16) <= data_0_reg(11 downto 4);        -- R
  aso_ad_data_window_o(15 downto 8)  <= data_out_gb_int(23 downto 16);  -- G
  aso_ad_data_window_o(7 downto 0)   <= aux_fifo_reg(7 downto 0);     -- B

  aso_ad_data_analysis0_o(47 downto 40) <= data_1_reg(11 downto 4);      -- R 
  aso_ad_data_analysis0_o(39 downto 32) <= data_out_gb_int(31 downto 24);  -- G 
  aso_ad_data_analysis0_o(31 downto 24) <= aux_fifo_reg(15 downto 8);  -- B 
  aso_ad_data_analysis0_o(23 downto 16) <= data_0_reg(11 downto 4);      -- R 
  aso_ad_data_analysis0_o(15 downto 8)  <= data_out_gb_int(23 downto 16);  -- G 
  aso_ad_data_analysis0_o(7 downto 0)   <= aux_fifo_reg(7 downto 0);   -- B 

  aso_ad_data_analysis1_o(47 downto 40) <= data_1_reg(11 downto 4);      -- R 
  aso_ad_data_analysis1_o(39 downto 32) <= data_out_gb_int(31 downto 24);  -- G 
  aso_ad_data_analysis1_o(31 downto 24) <= aux_fifo_reg(15 downto 8);  -- B 
  aso_ad_data_analysis1_o(23 downto 16) <= data_0_reg(11 downto 4);      -- R 
  aso_ad_data_analysis1_o(15 downto 8)  <= data_out_gb_int(23 downto 16);  -- G 
  aso_ad_data_analysis1_o(7 downto 0)   <= aux_fifo_reg(7 downto 0);   -- B 

  aso_ad_data_analysis2_o(47 downto 40) <= data_1_reg(11 downto 4);      -- R 
  aso_ad_data_analysis2_o(39 downto 32) <= data_out_gb_int(31 downto 24);  -- G 
  aso_ad_data_analysis2_o(31 downto 24) <= aux_fifo_reg(15 downto 8);  -- B 
  aso_ad_data_analysis2_o(23 downto 16) <= data_0_reg(11 downto 4);      -- R 
  aso_ad_data_analysis2_o(15 downto 8)  <= data_out_gb_int(23 downto 16);  -- G 
  aso_ad_data_analysis2_o(7 downto 0)   <= aux_fifo_reg(7 downto 0);   -- B 

  aso_ad_data_analysis3_o(47 downto 40) <= data_1_reg(11 downto 4);      -- R 
  aso_ad_data_analysis3_o(39 downto 32) <= data_out_gb_int(31 downto 24);  -- G 
  aso_ad_data_analysis3_o(31 downto 24) <= aux_fifo_reg(15 downto 8);  -- B 
  aso_ad_data_analysis3_o(23 downto 16) <= data_0_reg(11 downto 4);      -- R 
  aso_ad_data_analysis3_o(15 downto 8)  <= data_out_gb_int(23 downto 16);  -- G 
  aso_ad_data_analysis3_o(7 downto 0)   <= aux_fifo_reg(7 downto 0);   -- B 
  --
  aso_ad_data_fifo_o(47 downto 40)      <= data_1_reg(11 downto 4);      -- R 
  aso_ad_data_fifo_o(39 downto 32)      <= data_out_gb_int(31 downto 24);  -- G 
  aso_ad_data_fifo_o(31 downto 24)      <= aux_fifo_reg(15 downto 8);  -- B 
  aso_ad_data_fifo_o(23 downto 16)      <= data_0_reg(11 downto 4);      -- R 
  aso_ad_data_fifo_o(15 downto 8)       <= data_out_gb_int(23 downto 16);  -- G 
  aso_ad_data_fifo_o(7 downto 0)        <= aux_fifo_reg(7 downto 0);   -- B   

  aso_ad_valid_analysis0_o <= '1' when save_pixel_a_reg = '1'    else '0';
  aso_ad_valid_analysis1_o <= '1' when save_pixel_a_reg = '1'    else '0';
  aso_ad_valid_analysis2_o <= '1' when save_pixel_a_reg = '1'    else '0';
  aso_ad_valid_analysis3_o <= '1' when save_pixel_a_reg = '1'    else '0';
  aso_ad_valid_window_o    <= '1' when save_pixel_w_reg = '1'    else '0';
  aso_ad_valid_fifo_o      <= '1' when save_pixel_fifo_reg = '1' else '0';
  save_to_fifo_next        <= save_to_fifo_i;


  --
  av_comb_process : process (address_reg, av_write_reg, avs_ad_addr_i,
                             avs_ad_data_i, avs_ad_write_i, data_i_reg,
                             data_vec_reg) is
  begin  -- process av_comb_process
    data_vec_next <= data_vec_reg;
    data_i_next   <= avs_ad_data_i;
    av_write_next <= avs_ad_write_i;
    address_next  <= unsigned(avs_ad_addr_i);
    if av_write_reg = '1' then
      data_vec_next(to_integer(address_reg)) <= data_i_reg;
    end if;
  end process av_comb_process;

  comb_window_process : process(clock_enable_reg, end_a_offset_reg,
                                end_w_offset_reg, pixel_counter_reg,
                                save_pixel_a_reg, save_pixel_fifo_reg,
                                save_pixel_w_reg, save_to_fifo_reg,
                                st_a_offset_reg, st_w_offset_reg, start_b_reg,
                                start_gb_reg, used_b_int, used_gb_int) is
  begin
    pixel_counter_next   <= pixel_counter_reg;
    save_pixel_a_next    <= save_pixel_a_reg;
    save_pixel_w_next    <= save_pixel_w_reg;
    save_pixel_fifo_next <= save_pixel_fifo_reg;
    wreq_gb_next         <= '0';
    rdreq_gb_next        <= '0';
    wreq_b_next          <= '0';
    rdreq_b_next         <= '0';
    start_b_next         <= start_b_reg;
    start_gb_next        <= start_gb_reg;

    if unsigned(used_gb_int) >= 2047 then
      start_gb_next <= '1';
    end if;

    if unsigned(used_b_int) >= 2047 then
      start_b_next <= '1';
    end if;

    if clock_enable_reg = '1' then
      pixel_counter_next                                            <= pixel_counter_reg + 1;
      -- Not using end_offsets to keep consistence during simulations
      if pixel_counter_reg >= st_w_offset_reg and pixel_counter_reg <= end_w_offset_reg then
        save_pixel_w_next <= '1';
      else
        save_pixel_w_next <= '0';
      end if;



      if pixel_counter_reg >= st_a_offset_reg and pixel_counter_reg <= end_a_offset_reg then
        save_pixel_a_next <= '1';
        wreq_gb_next      <= '1';

        if start_gb_reg = '1' then
          wreq_b_next   <= '1';
          rdreq_gb_next <= '1';

        end if;

        if start_b_reg = '1' then
          rdreq_b_next <= '1';
          rdreq_b_next <= '1';

        end if;

        if save_to_fifo_reg = '1' then
          save_pixel_fifo_next <= '1';
        end if;
      else
        save_pixel_a_next    <= '0';
        save_pixel_fifo_next <= '0';
      end if;

    else
      pixel_counter_next <= (others => '0');
    end if;
  end process comb_window_process;

  reg_clock_enable : process (pll_1) is
  begin  -- process reg_clock_enable
    if rising_edge(pll_1) then
      clock_enable_reg <= clock_enable_next;
    end if;
  end process reg_clock_enable;

  data_process : process(pll_3) is
  begin
    -- data_in is registered based on DATACLK
    if rising_edge(pll_3) then
      data_0_reg          <= data_0_next;
      data_1_reg          <= data_1_next;
      data_2_reg          <= data_2_next;
      data_3_reg          <= data_3_next;
      data_4_reg          <= data_4_next;
      data_5_reg          <= data_5_next;
      pixel_counter_reg   <= pixel_counter_next;
      save_pixel_a_reg    <= save_pixel_a_next;
      save_pixel_w_reg    <= save_pixel_w_next;
      bit_counter_reg     <= bit_counter_next;
      sh_reg              <= sh_next;
      cplob_reg           <= cplob_next;
      pblk_reg            <= pblk_next;
      sync_old_reg        <= sync_old_next;
      sync_reg            <= sync_next;
      sync_st_reg         <= sync_st_next;
      av_write_reg        <= av_write_next;
      data_i_reg          <= data_i_next;
      data_vec_reg        <= data_vec_next;
      address_reg         <= address_next;
      enable_reg          <= enable_next;
      st_w_offset_reg     <= st_w_offset_next;
      st_a_offset_reg     <= st_a_offset_next;
      end_a_offset_reg    <= end_a_offset_next;
      end_w_offset_reg    <= end_w_offset_next;
      save_to_fifo_reg    <= save_to_fifo_next;
      save_pixel_fifo_reg <= save_pixel_fifo_next;
      --
      data_gb_prev_reg    <= data_gb_prev_next;
      data_b_prev_reg     <= data_b_prev_next;
      rdreq_gb_reg        <= rdreq_gb_next;
      wreq_gb_reg         <= wreq_gb_next;
      rdreq_b_reg         <= rdreq_b_next;
      wreq_b_reg          <= wreq_b_next;
      fifo_clear_reg      <= fifo_clear_next;
      start_b_reg         <= start_b_next;
      start_gb_reg        <= start_gb_next;
      aux_fifo_reg        <= aux_fifo_next;
      aux_fifo_gb_reg <= aux_fifo_gb_next;
    end if;
  end process data_process;

  comb_process : process(ad_0_data_i, ad_1_data_i, ad_2_data_i, ad_3_data_i,
                         ad_4_data_i, ad_5_data_i, aux_fifo_reg,
                         data_b_prev_reg, data_out_gb_int, rdreq_gb_reg)
  begin
    --  aquisita o dado
    data_0_next <= ad_0_data_i;         -- R2
    data_1_next <= ad_1_data_i;         -- R1
    data_2_next <= ad_2_data_i;         -- G2
    data_3_next <= ad_3_data_i;         -- G1
    data_4_next <= ad_4_data_i;         -- B2
    data_5_next <= ad_5_data_i;         -- B1

    -- aquisiçao do data_gb
    data_gb_prev_next(31 downto 24) <= ad_3_data_i(11 downto 4);
    data_gb_prev_next(23 downto 16) <= ad_2_data_i(11 downto 4);
    data_gb_prev_next(15 downto 8)  <= ad_5_data_i(11 downto 4);
    data_gb_prev_next(7 downto 0)   <= ad_4_data_i(11 downto 4);

    aux_fifo_gb_next <= data_out_gb_int;

    data_b_prev_next <= data_b_prev_reg;
    aux_fifo_next    <= data_out_gb_int(15 downto 0);

    if rdreq_gb_reg = '1' then
      data_b_prev_next <= aux_fifo_reg;

    end if;
  end process comb_process;

  bit_count_process : process(bit_counter_reg, clock_enable_reg, cplob_reg,
                              pblk_reg, sh_reg, sync_st_reg) is
  begin
    sh_next           <= sh_reg;
    cplob_next        <= cplob_reg;
    pblk_next         <= pblk_reg;
    clock_enable_next <= clock_enable_reg;
    case sync_st_reg is
      when WAIT_SYNC =>
        sh_next    <= '0';
        cplob_next <= '1';
        pblk_next  <= '1';

      when WAIT_VALID =>
        sh_next    <= '0';
        cplob_next <= '1';
        pblk_next  <= '1';

      when RECEIVE_CCD =>
        if bit_counter_reg = START_SH then
          sh_next <= '1';
        end if;
        if bit_counter_reg = END_SH then
          sh_next <= '0';
        end if;
        if bit_counter_reg = START_CLK then
          clock_enable_next <= '1';
        end if;
        if bit_counter_reg = START_CPLOB then
          cplob_next <= '0';
        end if;
        if bit_counter_reg = END_CPLOB then
          cplob_next <= '1';
        end if;
        if bit_counter_reg = START_PBLK then
          pblk_next <= '0';
        end if;
        if bit_counter_reg = END_PBLK then
          pblk_next <= '1';
        end if;
        if bit_counter_reg = END_CLK then
          clock_enable_next <= '0';
        end if;
    end case;

  end process bit_count_process;


  sync_st : process(bit_counter_reg, data_vec_reg(1), data_vec_reg(2),
                    data_vec_reg(3), data_vec_reg(4), data_vec_reg(5)(0),
                    enable_reg, end_a_offset_reg, end_w_offset_reg,
                    st_a_offset_reg, st_w_offset_reg, sync_i, sync_old_reg,
                    sync_reg, sync_st_reg) is
  begin

    bit_counter_next  <= bit_counter_reg;
    sync_st_next      <= sync_st_reg;
    st_w_offset_next  <= st_w_offset_reg;
    st_a_offset_next  <= st_a_offset_reg;
    end_w_offset_next <= end_w_offset_reg;
    end_a_offset_next <= end_a_offset_reg;
    enable_next       <= enable_reg;
    sync_next         <= sync_i;
    sync_old_next     <= sync_reg;

    case sync_st_reg is

      when WAIT_SYNC =>
        if sync_old_reg = '0' and sync_reg = '1' then
          sync_st_next      <= WAIT_VALID;
          st_w_offset_next  <= unsigned(data_vec_reg(1));
          st_a_offset_next  <= unsigned(data_vec_reg(2));
          end_w_offset_next <= unsigned(data_vec_reg(3));
          end_a_offset_next <= unsigned(data_vec_reg(4));
          enable_next       <= data_vec_reg(5)(0);
        end if;

      when WAIT_VALID =>
        if enable_reg = '0' then
          bit_counter_next <= (others => '0');
          sync_st_next     <= WAIT_SYNC;
        else
          sync_st_next <= RECEIVE_CCD;
        end if;

      when RECEIVE_CCD =>
        enable_next        <= data_vec_reg(5)(0);
        if bit_counter_reg <= END_COUNTER then
          bit_counter_next <= bit_counter_reg + 1;
        end if;
        if sync_reg = '1' and sync_old_reg = '0' then
          bit_counter_next <= (others => '0');
        end if;
        if enable_reg = '0' then
          sync_st_next     <= WAIT_SYNC;
          bit_counter_next <= (others => '0');
        end if;

    end case;
  end process sync_st;

end architecture ad_module_rtl;
