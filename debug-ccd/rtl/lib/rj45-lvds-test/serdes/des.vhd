library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity des is

  generic (
    BYTES_COUNTER : integer := 100
    );
  port (
    clk0         : in  std_logic;       -- clock from pll 0 degrees
    clk90        : in  std_logic;       -- clock from pll 90 degrees
    rst_n        : in  std_logic;
    sync_o       : out std_logic;
    -- AVST RX
    m_avst_valid : out std_logic;
    m_avst_ready : in  std_logic;
    m_avst_sop   : out std_logic;
    m_avst_eop   : out std_logic;
    m_avst_data  : out std_logic_vector(7 downto 0);
    -- Serial Interfaces
    rx_serial_i  : in  std_logic
    );
end entity des;

architecture des_rtl of des is

  constant MIN_START_PULSE_CYCLES : integer := 6;  -- It's suppose to be 7
  constant TYPE_OF_RETURN         : integer := 0;

  signal parallel_data_int : std_logic_vector(7 downto 0);
  signal data_valid_int    : std_logic;
  signal sop_int           : std_logic;

  signal m_avst_sop_next, m_avst_sop_reg     : std_logic;
  signal m_avst_eop_next, m_avst_eop_reg     : std_logic;
  signal m_avst_valid_next, m_avst_valid_reg : std_logic := '0';
  signal m_avst_data_next, m_avst_data_reg   : std_logic_vector(7 downto 0);

  signal counter_next, counter_reg : integer;

begin

  sync_o       <= sop_int;
  m_avst_sop   <= m_avst_sop_reg;
  m_avst_eop   <= m_avst_eop_reg;
  m_avst_valid <= m_avst_valid_reg;
  m_avst_data  <= m_avst_data_reg;

  DATA_RECOVERY : entity work.data_recovery
    generic map (
      BYTES_COUNTER          => BYTES_COUNTER,
      MIN_START_PULSE_CYCLES => MIN_START_PULSE_CYCLES,
      TYPE_OF_RETURN         => TYPE_OF_RETURN)
    port map (
      clk0            => clk0,
      clk90           => clk90,
      rst_n           => rst_n,
      sop_o           => sop_int,
      serial_data_i   => rx_serial_i,
      parallel_data_o => parallel_data_int,
      data_valid_o    => data_valid_int);

  process(clk0, rst_n)
  begin
    if rst_n = '0' then
      m_avst_valid_reg <= '0';
    elsif rising_edge(clk0) then
      m_avst_sop_reg   <= m_avst_sop_next;
      m_avst_eop_reg   <= m_avst_eop_next;
      m_avst_valid_reg <= m_avst_valid_next;
      m_avst_data_reg  <= m_avst_data_next;
      counter_reg      <= counter_next;
    end if;
  end process;

  process(counter_reg, data_valid_int, m_avst_data_reg, m_avst_eop_reg,
          m_avst_ready, m_avst_sop_reg, m_avst_valid_reg, parallel_data_int,
          sop_int)
  begin

    m_avst_sop_next   <= m_avst_sop_reg;
    m_avst_eop_next   <= m_avst_eop_reg;
    m_avst_valid_next <= m_avst_valid_reg;
    m_avst_data_next  <= m_avst_data_reg;
    counter_next      <= counter_reg;

    if sop_int = '1' then
      m_avst_sop_next <= '1';
      m_avst_eop_next <= '0';
      counter_next    <= 0;
    end if;
    if data_valid_int = '1' then
      m_avst_data_next  <= parallel_data_int;
      m_avst_valid_next <= '1';
      if counter_reg >= BYTES_COUNTER - 1 then
        m_avst_eop_next <= '1';
      else
        m_avst_eop_next <= '0';
        counter_next    <= counter_reg + 1;
      end if;
    end if;
    if m_avst_valid_reg = '1' and m_avst_ready = '1' then
      m_avst_eop_next   <= '0';
      m_avst_sop_next   <= '0';
      m_avst_valid_next <= '0';
    end if;
  end process;

end architecture des_rtl;


