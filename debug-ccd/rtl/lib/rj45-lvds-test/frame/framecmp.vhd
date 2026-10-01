library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity framecmp is

  generic (
    BYTES_COUNTER : integer := 100;
    N_CYCLES      : integer := 5000
    );
  port (
    clk0         : in  std_logic;       -- clock from pll 0 degrees
    rst_n        : in  std_logic;
    status_o     : out std_logic;
    -- AVST RX
    s_avst_valid : in  std_logic;
    s_avst_ready : out std_logic;
    s_avst_sop   : in  std_logic;
    s_avst_eop   : in  std_logic;
    s_avst_data  : in  std_logic_vector(7 downto 0)
    );

end entity framecmp;

architecture framecmp_rtl of framecmp is

  signal cycles_counter_next, cycles_counter_reg : integer              := 0;
  signal word_counter_next, word_counter_reg     : integer              := BYTES_COUNTER - 1;
  signal data_counter_next, data_counter_reg     : unsigned(7 downto 0) := (others => '1');

  signal s_avst_ready_next, s_avst_ready_reg : std_logic := '0';

  signal status_next, status_reg   : std_logic := '0';
  signal failure_next, failure_reg : std_logic;

begin

  s_avst_ready <= s_avst_ready_reg;
  status_o     <= status_reg;

  process(clk0, rst_n)
  begin
    if rst_n = '0' then
      s_avst_ready_reg <= '0';
      status_reg       <= '0';
      data_counter_reg <= (others => '1');
      word_counter_reg <= BYTES_COUNTER - 1;
    elsif rising_edge(clk0) then
      s_avst_ready_reg   <= s_avst_ready_next;
      status_reg         <= status_next;
      failure_reg        <= failure_next;
      cycles_counter_reg <= cycles_counter_next;
      word_counter_reg   <= word_counter_next;
      data_counter_reg   <= data_counter_next;
    end if;
  end process;

  process(cycles_counter_reg, data_counter_reg, failure_reg, s_avst_data,
          s_avst_eop, s_avst_ready_reg, s_avst_sop, s_avst_valid, status_reg,
          word_counter_reg)
  begin
    s_avst_ready_next   <= s_avst_ready_reg;
    status_next         <= status_reg;
    failure_next        <= failure_reg;
    cycles_counter_next <= cycles_counter_reg;
    word_counter_next   <= word_counter_reg;
    data_counter_next   <= data_counter_reg;

    if cycles_counter_reg > 0 then
      cycles_counter_next <= cycles_counter_reg - 1;
    else
      status_next <= '0';
    end if;

    s_avst_ready_next <= '1';
    if s_avst_ready_reg = '1' and s_avst_valid = '1' then
      data_counter_next <= data_counter_reg - 1;
      word_counter_next <= word_counter_reg - 1;
      if s_avst_sop = '1' then
        failure_next <= '0';
      end if;
      if s_avst_eop = '1' then
        if failure_reg = '0' and word_counter_reg = 0 then
          cycles_counter_next <= N_CYCLES * 3 / 2;
          failure_next        <= 'X';
          status_next         <= '1';
        end if;
        -- Leave initialized for the next cycle
        data_counter_next <= (others => '1');
        word_counter_next <= BYTES_COUNTER - 1;
      end if;
      if unsigned(s_avst_data) /= data_counter_reg then
        failure_next <= '1';
        status_next  <= '0';
      end if;
    end if;

  end process;

end architecture framecmp_rtl;
