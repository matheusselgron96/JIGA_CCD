library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ser is
  generic (
    BYTES_COUNTER : integer := 100
    );
  port (
    clk0         : in  std_logic;       -- TX clock 
    rst_n        : in  std_logic;
    -- AVST TX
    s_avst_valid : in  std_logic;
    s_avst_ready : out std_logic;
    s_avst_sop   : in  std_logic;
    s_avst_eop   : in  std_logic;
    s_avst_data  : in  std_logic_vector(7 downto 0);
    -- Serial Interface
    tx_serial_o  : out std_logic
    );


end entity ser;

architecture ser_rtl of ser is

  constant PREAMBLE_LEN : integer                                     := 8;
  constant PREAMBLE     : std_logic_vector(PREAMBLE_LEN - 1 downto 0) := "11111110";

  signal s_avst_ready_next, s_avst_ready_reg : std_logic;
  signal dbuffer_next, dbuffer_reg           : std_logic_vector(PREAMBLE_LEN + 7 downto 0) := (others => '0');

  -- By using two counters we avoid doing strange aritmethics
  signal num_pending_bits_next, num_pending_bits_reg   : integer := 0;
  signal num_buffered_bits_next, num_buffered_bits_reg : integer := 0;

  -- main state machine
  type ST_TYPE is (
    ST_WAIT_SOP,
    ST_WAIT_WORD_TX,
    ST_FETCH_NEXT_WORD,
    ST_WAIT_EOP,
    ST_WAIT_TX_END);

  signal st_next, st_reg : ST_TYPE := ST_WAIT_SOP;

begin

  s_avst_ready <= s_avst_ready_reg;

  process(clk0, rst_n)
  begin
    if rst_n = '0' then
      s_avst_ready_reg <= '0';
      st_reg           <= ST_WAIT_SOP;
      dbuffer_reg      <= (others => '0');
    elsif rising_edge(clk0) then
      s_avst_ready_reg      <= s_avst_ready_next;
      dbuffer_reg           <= dbuffer_next;
      num_pending_bits_reg  <= num_pending_bits_next;
      num_buffered_bits_reg <= num_buffered_bits_next;
      st_reg                <= st_next;
    end if;
  end process;

  -- We always push data out
  tx_serial_o <= dbuffer_reg(dbuffer_reg'high);

  process(dbuffer_reg, num_buffered_bits_reg, num_pending_bits_reg,
          s_avst_data, s_avst_eop, s_avst_ready_reg, s_avst_sop, s_avst_valid,
          st_reg)
  begin

    s_avst_ready_next      <= s_avst_ready_reg;
    dbuffer_next           <= dbuffer_reg;
    num_pending_bits_next  <= num_pending_bits_reg;
    num_buffered_bits_next <= num_buffered_bits_reg;
    st_next                <= st_reg;

    -- At the end the buffer will be padded with zeros
    dbuffer_next <= dbuffer_reg(dbuffer_reg'high - 1 downto 0) & '0';

    -- Saturate counters at 0
    -- The counters have a unique value set
    -- Or a saturated decrement
    if num_pending_bits_reg > 0 then
      num_pending_bits_next <= num_pending_bits_reg - 1;
    end if;
    if num_buffered_bits_reg > 0 then
      num_buffered_bits_next <= num_buffered_bits_reg - 1;
    end if;

    case st_reg is

      when ST_WAIT_SOP =>
        s_avst_ready_next <= '1';
        -- AXIST don't have sop, but avalon-st_reg has it and we need to wait
        if s_avst_valid = '1' and s_avst_ready_reg = '1' and s_avst_sop = '1' then
          dbuffer_next           <= PREAMBLE & s_avst_data;
          s_avst_ready_next      <= '0';
          num_pending_bits_next  <= BYTES_COUNTER * 8 + PREAMBLE_LEN;
          num_buffered_bits_next <= 8;
          st_next                <= ST_WAIT_WORD_TX;
        end if;

      when ST_WAIT_WORD_TX =>
        -- Wait until we have space on the buffer to fetch the next data
        if num_buffered_bits_reg = 2 then
          s_avst_ready_next <= '1';
          st_next           <= ST_FETCH_NEXT_WORD;
        end if;
        -- If we already transmited the entire buffer
        -- We flush the rest of the data
        if num_pending_bits_reg < dbuffer_reg'length then
          st_next <= ST_WAIT_EOP;
        end if;

      when ST_FETCH_NEXT_WORD =>

        if s_avst_valid = '1' then
          s_avst_ready_next               <= '0';
          dbuffer_next(s_avst_data'range) <= s_avst_data;
          num_buffered_bits_next          <= 8;
          st_next                         <= ST_WAIT_WORD_TX;
          if s_avst_eop = '1' then
            -- This is the no error path - ideally we alyways end up here
            st_next <= ST_WAIT_TX_END;
          end if;
        else
          -- If we reach this point it means that we needed data to be available
          -- but it wasn't - so we flush the rest of the frame cause it's going to
          -- be corrupted anyway
          st_next <= ST_WAIT_EOP;
        end if;

      when ST_WAIT_EOP =>
        s_avst_ready_next <= '1';
        if s_avst_valid = '1' and s_avst_eop = '1' then
          st_next <= ST_WAIT_TX_END;
        end if;

      when ST_WAIT_TX_END =>
        if num_pending_bits_reg = 0 then
          st_next <= ST_WAIT_SOP;
        end if;
    end case;

  end process;

end architecture ser_rtl;

