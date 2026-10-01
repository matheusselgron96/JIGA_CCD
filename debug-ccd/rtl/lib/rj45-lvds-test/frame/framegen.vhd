library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity framegen is

  generic (
    BYTES_COUNTER : integer := 100;
    N_CYCLES      : integer := 5000
    );
  port (
    clk0         : in  std_logic;       -- clock from pll 0 degrees
    rst_n        : in  std_logic;
    enable_i     : in  std_logic;
    -- AVST RX
    m_avst_valid : out std_logic;
    m_avst_ready : in  std_logic;
    m_avst_sop   : out std_logic;
    m_avst_eop   : out std_logic;
    m_avst_data  : out std_logic_vector(7 downto 0)
    );

end entity framegen;

architecture framegen_rtl of framegen is

  signal cycles_counter_next, cycles_counter_reg : integer := 0;
  signal word_counter_next, word_counter_reg     : integer := 0;
  signal data_counter_next, data_counter_reg     : unsigned(7 downto 0);

  -- main state machine
  type ST_TYPE is (
    ST_WAIT_ENABLE,
    ST_PUSH,
    ST_WAIT_HANDSHAKE,
    ST_WAIT);

  signal st_next, st_reg : ST_TYPE := ST_WAIT_ENABLE;

  signal m_avst_sop_next, m_avst_sop_reg     : std_logic;
  signal m_avst_eop_next, m_avst_eop_reg     : std_logic;
  signal m_avst_data_next, m_avst_data_reg   : std_logic_vector(7 downto 0);
  signal m_avst_valid_next, m_avst_valid_reg : std_logic := '0';

begin

  m_avst_valid <= m_avst_valid_reg;
  m_avst_sop   <= m_avst_sop_reg;
  m_avst_eop   <= m_avst_eop_reg;
  m_avst_data  <= m_avst_data_reg;


  process(clk0, rst_n)
  begin
    if rst_n = '0' then
      st_reg           <= ST_WAIT_ENABLE;
      m_avst_valid_reg <= '0';
    elsif rising_edge(clk0) then
      st_reg             <= st_next;
      m_avst_sop_reg     <= m_avst_sop_next;
      m_avst_eop_reg     <= m_avst_eop_next;
      m_avst_data_reg    <= m_avst_data_next;
      m_avst_valid_reg   <= m_avst_valid_next;
      cycles_counter_reg <= cycles_counter_next;
      word_counter_reg   <= word_counter_next;
      data_counter_reg   <= data_counter_next;
    end if;
  end process;

  process(cycles_counter_reg, data_counter_reg, enable_i, m_avst_data_reg,
          m_avst_eop_reg, m_avst_ready, m_avst_sop_reg, m_avst_valid_reg,
          st_reg, word_counter_reg)
  begin
    st_next             <= st_reg;
    m_avst_sop_next     <= m_avst_sop_reg;
    m_avst_eop_next     <= m_avst_eop_reg;
    m_avst_data_next    <= m_avst_data_reg;
    m_avst_valid_next   <= m_avst_valid_reg;
    cycles_counter_next <= cycles_counter_reg;
    word_counter_next   <= word_counter_reg;
    data_counter_next   <= data_counter_reg;

    if cycles_counter_reg > 0 then
      cycles_counter_next <= cycles_counter_reg - 1;
    end if;

    case st_reg is

      when ST_WAIT_ENABLE =>

        if enable_i = '1' then
          st_next             <= ST_PUSH;
          cycles_counter_next <= N_CYCLES;
          word_counter_next   <= BYTES_COUNTER - 1;
          data_counter_next   <= (others => '1');
          m_avst_sop_next     <= '1';
          m_avst_eop_next     <= '0';
        end if;

      when ST_PUSH =>
        m_avst_data_next  <= std_logic_vector(data_counter_reg);
        m_avst_valid_next <= '1';
        st_next           <= ST_WAIT_HANDSHAKE;
        if word_counter_reg = 0 then
          m_avst_eop_next <= '1';
        end if;

      when ST_WAIT_HANDSHAKE =>
        if m_avst_ready = '1' then
          m_avst_valid_next <= '0';
          m_avst_sop_next   <= '0';
          m_avst_eop_next   <= '0';
          if word_counter_reg = 0 then
            st_next <= ST_WAIT;
          else
            word_counter_next <= word_counter_reg - 1;
            data_counter_next <= data_counter_reg - 1;
            st_next           <= ST_PUSH;
          end if;
        end if;

      when ST_WAIT =>
        if cycles_counter_reg = 0 then
          st_next <= ST_WAIT_ENABLE;
        end if;

    end case;

  end process;

end architecture framegen_rtl;
