library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rjtester is
  -- Parametros do componente
  generic (
    PERIOD_SYNC_US       : integer := 100; -- Periodo entre um pacote e outro
    LINK_0_FREQUENCY_MHZ : integer := 50;  -- Frequencia em MHz do Link0 e Link1
    LINK_0_NUM_BYTES     : integer := 500; -- Numero de Bytes do Link0 e Link1
    LINK_2_FREQUENCY_MHZ : integer := 20;  -- Frequencia em MHz do Link2
    LINK_2_NUM_BYTES     : integer := 80   -- Numero de Bytes do Link2
    );
  port (
    rst_n : in std_logic; -- reset do componente (reset em zero)

    -- avmm
    sysclk         : in  std_logic; -- clock do sistema
    avmm_address   : in  std_logic_vector(3 downto 0); -- Endereço do registrador
    avmm_write     : in  std_logic; -- flag de escrita
    avmm_writedata : in  std_logic_vector(31 downto 0); -- Dado escrito
    avmm_read      : in  std_logic; -- flag de leitura
    avmm_readdata  : out std_logic_vector(31 downto 0); -- Dado lido

    -- Par serial 0
    clk0_0       : in  std_logic;       -- clock do PLL, fase de 0 graus
    clk0_90      : in  std_logic;       -- clock do PLL, fase de 90 graus
    tx0_serial_o : out std_logic;       -- conector RJ45 A, transmissão 0
    rx0_serial_i : in  std_logic;       -- conector RJ45 B, recepção 0
    -- Par serial 1
    tx1_serial_o : out std_logic;       -- conector RJ45 B, transmissão 1
    rx1_serial_i : in  std_logic;       -- conector RJ45 A, recepção 1
    -- Par serial 2
    clk2_0       : in  std_logic;       -- clock do PLL, fase de 0 graus
    clk2_90      : in  std_logic;       -- clock do PLL, fase de 90 graus
    tx2_serial_o : out std_logic;       -- conector RJ45 A, transmissão 2
    rx2_serial_i : in  std_logic        -- conector RJ45 B, recepção 2
    );

end entity rjtester;

architecture serdes_rtl of rjtester is

  -- Constantes do link 1
  constant LINK_1_FREQUENCY_MHZ : integer := LINK_0_FREQUENCY_MHZ;
  constant LINK_1_NUM_BYTES     : integer := LINK_0_NUM_BYTES;

  -- Ciclos por período
  constant LINK_0_N_CYCLES : integer := PERIOD_SYNC_US * LINK_0_FREQUENCY_MHZ;
  constant LINK_1_N_CYCLES : integer := PERIOD_SYNC_US * LINK_1_FREQUENCY_MHZ;
  constant LINK_2_N_CYCLES : integer := PERIOD_SYNC_US * LINK_1_FREQUENCY_MHZ;

  -- component ports
  signal tx0_avst_valid_int : std_logic; -- "tenho um byte pronto em data" | framegen --> ser
  signal tx0_avst_ready_int : std_logic; -- "posso receber um byte agora"  | ser --> framegen
  signal tx0_avst_sop_int   : std_logic; -- "este byte é o primeiro do pacote" | framegen --> ser
  signal tx0_avst_eop_int   : std_logic; --  "este byte é o último do pacote" | framegen --> ser
  signal tx0_avst_data_int  : std_logic_vector(7 downto 0); --  o byte em si, 8 bits | framegen --> ser

  signal rx0_avst_valid_int : std_logic;  
  signal rx0_avst_ready_int : std_logic;  
  signal rx0_avst_sop_int   : std_logic;
  signal rx0_avst_eop_int   : std_logic;
  signal rx0_avst_data_int  : std_logic_vector(7 downto 0);
   signal rx0_status_int     : std_logic;  -- saída status_o
  signal rx0_sync_int       : std_logic; -- usado na simulação

  -- Sinal 1
  signal tx1_avst_valid_int : std_logic;
  signal tx1_avst_ready_int : std_logic;
  signal tx1_avst_sop_int   : std_logic;
  signal tx1_avst_eop_int   : std_logic;
  signal tx1_avst_data_int  : std_logic_vector(7 downto 0);

  signal rx1_avst_valid_int : std_logic;
  signal rx1_avst_ready_int : std_logic;
  signal rx1_avst_sop_int   : std_logic;
  signal rx1_avst_eop_int   : std_logic;
  signal rx1_avst_data_int  : std_logic_vector(7 downto 0);
  signal rx1_status_int     : std_logic;
  signal rx1_sync_int       : std_logic;

  -- Sinal 2
  signal tx2_avst_valid_int : std_logic;
  signal tx2_avst_ready_int : std_logic;
  signal tx2_avst_sop_int   : std_logic;
  signal tx2_avst_eop_int   : std_logic;
  signal tx2_avst_data_int  : std_logic_vector(7 downto 0);

  signal rx2_avst_valid_int : std_logic;
  signal rx2_avst_ready_int : std_logic;
  signal rx2_avst_sop_int   : std_logic;
  signal rx2_avst_eop_int   : std_logic;
  signal rx2_avst_data_int  : std_logic_vector(7 downto 0);
  signal rx2_sync_int       : std_logic;
  signal rx2_status_int     : std_logic;

  -- Contadores de frames por link (dominio de clock do proprio link).
  -- Incrementam nos pulsos frame_ok / frame_err do framecmp, saturam em
  -- 2^32-1 e sao zerados pelo registrador de controle (+0x18).
  signal rx0_frames_ok_reg  : unsigned(31 downto 0) := (others => '0'); -- link 0: frames recebidos sem erro
  signal rx0_frames_err_reg : unsigned(31 downto 0) := (others => '0'); -- link 0: frames recebidos com erro
  signal rx1_frames_ok_reg  : unsigned(31 downto 0) := (others => '0'); -- link 1: frames recebidos sem erro
  signal rx1_frames_err_reg : unsigned(31 downto 0) := (others => '0'); -- link 1: frames recebidos com erro
  signal rx2_frames_ok_reg  : unsigned(31 downto 0) := (others => '0'); -- link 2: frames recebidos sem erro
  signal rx2_frames_err_reg : unsigned(31 downto 0) := (others => '0'); -- link 2: frames recebidos com erro

  -- Sinais dos registradores de enable dos canais --> Processador muda esses valores
  signal tx0_enable_next, tx0_enable_reg       : std_logic := '0';
  signal tx1_enable_next, tx1_enable_reg       : std_logic := '0';
  signal tx2_enable_next, tx2_enable_reg       : std_logic := '0';
  -- Local que o processador lé o valor
  signal avmm_readdata_next, avmm_readdata_reg : std_logic_vector(avmm_readdata'range); 

-- CDC usando 1 registrador porque todos os clocks vêm da mesma fonte.
-- Assim, o Quartus consegue garantir que não teremos metaestabilidade.
-- Um registrador adicional é necessário para facilitar o fechamento de timing.
  signal tx0_enable_clk0_reg   : std_logic := '0';
  signal tx1_enable_clk1_reg   : std_logic := '0';
  signal tx2_enable_clk2_reg   : std_logic := '0';
  signal rx0_status_sysclk_reg : std_logic;
  signal rx1_status_sysclk_reg : std_logic;
  signal rx2_status_sysclk_reg : std_logic;
  signal rx0_frames_ok_sysclk_reg  : unsigned(31 downto 0) := (others => '0');
  signal rx0_frames_err_sysclk_reg : unsigned(31 downto 0) := (others => '0');
  signal rx1_frames_ok_sysclk_reg  : unsigned(31 downto 0) := (others => '0');
  signal rx1_frames_err_sysclk_reg : unsigned(31 downto 0) := (others => '0');
  signal rx2_frames_ok_sysclk_reg  : unsigned(31 downto 0) := (others => '0');
  signal rx2_frames_err_sysclk_reg : unsigned(31 downto 0) := (others => '0');
  
  -- link 1 will use the same clock as link 0
  signal clk1_0  : std_logic;           -- clock from pll 0 degrees
  signal clk1_90 : std_logic;           -- clock from pll 90 degrees

  -- Pulsos de fim de frame vindos do framecmp (1 ciclo, no clock do link)
  signal rx0_frame_ok_int  : std_logic; -- link 0: frame recebido sem erro
  signal rx0_frame_err_int : std_logic; -- link 0: frame recebido com erro
  signal rx1_frame_ok_int  : std_logic; -- link 1: frame recebido sem erro
  signal rx1_frame_err_int : std_logic; -- link 1: frame recebido com erro
  signal rx2_frame_ok_int  : std_logic; -- link 2: frame recebido sem erro
  signal rx2_frame_err_int : std_logic; -- link 2: frame recebido com erro

  signal clear_sync0_clk0_reg : std_logic := '0';
  signal clear_sync1_clk0_reg : std_logic := '0';
  signal clear_sync2_clk0_reg : std_logic := '0';
  signal clear_sync0_clk2_reg : std_logic := '0';
  signal clear_sync1_clk2_reg : std_logic := '0';
  signal clear_sync2_clk2_reg : std_logic := '0';
  signal clear_clk0 : std_logic; -- clear para os links 0 e 1 (ambos em clk0_0)
  signal clear_clk2 : std_logic; -- clear para o link 2 (clk2_0)

  signal clear_req_next, clear_req_reg         : std_logic := '0';
  signal clear_toggle_reg : std_logic := '0';

  

begin

  clk1_0  <= clk0_0;
  clk1_90 <= clk0_90;
  -- Pulso de clear em cada dominio: 1 ciclo quando o toggle sincronizado muda
  clear_clk0 <= clear_sync1_clk0_reg xor clear_sync2_clk0_reg;
  clear_clk2 <= clear_sync1_clk2_reg xor clear_sync2_clk2_reg;

  FRAMEGEN_0 : entity work.framegen
    generic map (
      BYTES_COUNTER => LINK_0_NUM_BYTES,
      N_CYCLES      => LINK_0_N_CYCLES)
    port map (
      clk0         => clk0_0,
      rst_n        => rst_n,
      enable_i     => tx0_enable_clk0_reg,
      m_avst_valid => tx0_avst_valid_int,
      m_avst_ready => tx0_avst_ready_int,
      m_avst_sop   => tx0_avst_sop_int,
      m_avst_eop   => tx0_avst_eop_int,
      m_avst_data  => tx0_avst_data_int);

  SER_0 : entity work.ser
    generic map (
      BYTES_COUNTER => LINK_0_NUM_BYTES)
    port map (
      clk0         => clk0_0,
      rst_n        => rst_n,
      s_avst_valid => tx0_avst_valid_int,
      s_avst_ready => tx0_avst_ready_int,
      s_avst_sop   => tx0_avst_sop_int,
      s_avst_eop   => tx0_avst_eop_int,
      s_avst_data  => tx0_avst_data_int,
      tx_serial_o  => tx0_serial_o);

  DES_0 : entity work.des
    generic map (
      BYTES_COUNTER => LINK_0_NUM_BYTES)
    port map (
      clk0         => clk0_0,
      clk90        => clk0_90,
      rst_n        => rst_n,
      sync_o       => rx0_sync_int,
      m_avst_valid => rx0_avst_valid_int,
      m_avst_ready => rx0_avst_ready_int,
      m_avst_sop   => rx0_avst_sop_int,
      m_avst_eop   => rx0_avst_eop_int,
      m_avst_data  => rx0_avst_data_int,
      rx_serial_i  => rx0_serial_i);

   FRAMECMP_0 : entity work.framecmp
    generic map (
      BYTES_COUNTER => LINK_0_NUM_BYTES,
      N_CYCLES      => LINK_0_N_CYCLES)
    port map (
      clk0         => clk0_0,
      rst_n        => rst_n,
      status_o     => rx0_status_int,
      frame_ok_o   => rx0_frame_ok_int,
      frame_err_o  => rx0_frame_err_int,
      s_avst_valid => rx0_avst_valid_int,
      s_avst_ready => rx0_avst_ready_int,
      s_avst_sop   => rx0_avst_sop_int,
      s_avst_eop   => rx0_avst_eop_int,
      s_avst_data  => rx0_avst_data_int);

  FRAMEGEN_1 : entity work.framegen
    generic map (
      BYTES_COUNTER => LINK_1_NUM_BYTES,
      N_CYCLES      => LINK_1_N_CYCLES)
    port map (
      clk0         => clk1_0,
      rst_n        => rst_n,
      enable_i     => tx1_enable_clk1_reg,
      m_avst_valid => tx1_avst_valid_int,
      m_avst_ready => tx1_avst_ready_int,
      m_avst_sop   => tx1_avst_sop_int,
      m_avst_eop   => tx1_avst_eop_int,
      m_avst_data  => tx1_avst_data_int);

  SER_1 : entity work.ser
    generic map (
      BYTES_COUNTER => LINK_1_NUM_BYTES)
    port map (
      clk0         => clk1_0,
      rst_n        => rst_n,
      s_avst_valid => tx1_avst_valid_int,
      s_avst_ready => tx1_avst_ready_int,
      s_avst_sop   => tx1_avst_sop_int,
      s_avst_eop   => tx1_avst_eop_int,
      s_avst_data  => tx1_avst_data_int,
      tx_serial_o  => tx1_serial_o);

  DES_1 : entity work.des
    generic map (
      BYTES_COUNTER => LINK_1_NUM_BYTES)
    port map (
      clk0         => clk1_0,
      clk90        => clk1_90,
      rst_n        => rst_n,
      sync_o       => rx1_sync_int,
      m_avst_valid => rx1_avst_valid_int,
      m_avst_ready => rx1_avst_ready_int,
      m_avst_sop   => rx1_avst_sop_int,
      m_avst_eop   => rx1_avst_eop_int,
      m_avst_data  => rx1_avst_data_int,
      rx_serial_i  => rx1_serial_i);

  FRAMECMP_1 : entity work.framecmp
    generic map (
      BYTES_COUNTER => LINK_1_NUM_BYTES,
      N_CYCLES      => LINK_1_N_CYCLES)
    port map (
      clk0         => clk1_0,
      rst_n        => rst_n,
      status_o     => rx1_status_int,
      frame_ok_o   => rx1_frame_ok_int,
      frame_err_o  => rx1_frame_err_int,
      s_avst_valid => rx1_avst_valid_int,
      s_avst_ready => rx1_avst_ready_int,
      s_avst_sop   => rx1_avst_sop_int,
      s_avst_eop   => rx1_avst_eop_int,
      s_avst_data  => rx1_avst_data_int);

  FRAMEGEN_2 : entity work.framegen
    generic map (
      BYTES_COUNTER => LINK_2_NUM_BYTES,
      N_CYCLES      => LINK_2_N_CYCLES)
    port map (
      clk0         => clk2_0,
      rst_n        => rst_n,
      enable_i     => tx2_enable_clk2_reg,
      m_avst_valid => tx2_avst_valid_int,
      m_avst_ready => tx2_avst_ready_int,
      m_avst_sop   => tx2_avst_sop_int,
      m_avst_eop   => tx2_avst_eop_int,
      m_avst_data  => tx2_avst_data_int);

  SER_2 : entity work.ser
    generic map (
      BYTES_COUNTER => LINK_2_NUM_BYTES)
    port map (
      clk0         => clk2_0,
      rst_n        => rst_n,
      s_avst_valid => tx2_avst_valid_int,
      s_avst_ready => tx2_avst_ready_int,
      s_avst_sop   => tx2_avst_sop_int,
      s_avst_eop   => tx2_avst_eop_int,
      s_avst_data  => tx2_avst_data_int,
      tx_serial_o  => tx2_serial_o);

  DES_2 : entity work.des
    generic map (
      BYTES_COUNTER => LINK_2_NUM_BYTES)
    port map (
      clk0         => clk2_0,
      clk90        => clk2_90,
      rst_n        => rst_n,
      sync_o       => rx2_sync_int,
      m_avst_valid => rx2_avst_valid_int,
      m_avst_ready => rx2_avst_ready_int,
      m_avst_sop   => rx2_avst_sop_int,
      m_avst_eop   => rx2_avst_eop_int,
      m_avst_data  => rx2_avst_data_int,
      rx_serial_i  => rx2_serial_i);

 FRAMECMP_2 : entity work.framecmp
    generic map (
      BYTES_COUNTER => LINK_2_NUM_BYTES,
      N_CYCLES      => LINK_2_N_CYCLES)
    port map (
      clk0         => clk2_0,
      rst_n        => rst_n,
      status_o     => rx2_status_int,
      frame_ok_o   => rx2_frame_ok_int,
      frame_err_o  => rx2_frame_err_int,
      s_avst_valid => rx2_avst_valid_int,
      s_avst_ready => rx2_avst_ready_int,
      s_avst_sop   => rx2_avst_sop_int,
      s_avst_eop   => rx2_avst_eop_int,
      s_avst_data  => rx2_avst_data_int);


 -- Avalon-MM register bank + status capture (sysclk domain)
process(sysclk, rst_n)
  begin
    if rst_n = '0' then
      tx0_enable_reg   <= '0';
      tx1_enable_reg   <= '0';
      tx2_enable_reg   <= '0';
      clear_req_reg    <= '0';
      clear_toggle_reg <= '0';
    elsif rising_edge(sysclk) then
      avmm_readdata_reg     <= avmm_readdata_next;
      tx0_enable_reg        <= tx0_enable_next;
      tx1_enable_reg        <= tx1_enable_next;
      tx2_enable_reg        <= tx2_enable_next;
      clear_req_reg         <= clear_req_next;
      -- Cada pedido de clear inverte o toggle (pulso -> mudanca de nivel)
      if clear_req_reg = '1' then
        clear_toggle_reg <= not clear_toggle_reg;
      end if;
      -- CDC link -> sysclk (1 register: all clocks share the same PLL)
      rx0_status_sysclk_reg <= rx0_status_int;
      rx1_status_sysclk_reg <= rx1_status_int;
      rx2_status_sysclk_reg <= rx2_status_int;
      -- CDC link -> sysclk dos contadores (ver regra de uso na declaracao)
      rx0_frames_ok_sysclk_reg  <= rx0_frames_ok_reg;
      rx0_frames_err_sysclk_reg <= rx0_frames_err_reg;
      rx1_frames_ok_sysclk_reg  <= rx1_frames_ok_reg;
      rx1_frames_err_sysclk_reg <= rx1_frames_err_reg;
      rx2_frames_ok_sysclk_reg  <= rx2_frames_ok_reg;
      rx2_frames_err_sysclk_reg <= rx2_frames_err_reg;
    end if;
  end process;

 -- CDC sysclk -> clk0 (link 0 enable + toggle de clear)
  process(clk0_0)
  begin
    if rising_edge(clk0_0) then
      tx0_enable_clk0_reg  <= tx0_enable_reg;
      -- sincronizador de 2 registros + atraso para detectar a borda
      clear_sync0_clk0_reg <= clear_toggle_reg;
      clear_sync1_clk0_reg <= clear_sync0_clk0_reg;
      clear_sync2_clk0_reg <= clear_sync1_clk0_reg;
    end if;
  end process;

  -- CDC sysclk -> clk1 (link 1 enable)
  process(clk1_0)
  begin
    if rising_edge(clk1_0) then
      tx1_enable_clk1_reg <= tx1_enable_reg;
    end if;
  end process;

process(clk2_0)
  begin
    if rising_edge(clk2_0) then
      tx2_enable_clk2_reg  <= tx2_enable_reg;
      -- sincronizador de 2 registros + atraso para detectar a borda
      clear_sync0_clk2_reg <= clear_toggle_reg;
      clear_sync1_clk2_reg <= clear_sync0_clk2_reg;
      clear_sync2_clk2_reg <= clear_sync1_clk2_reg;
    end if;
  end process;

    -- Contadores de frames dos links 0 e 1 (dominio clk0_0).
  -- Prioridade: reset > clear > incremento. Saturam em COUNTER_MAX.
  process(clk0_0, rst_n)
  begin
    if rst_n = '0' then
      rx0_frames_ok_reg  <= (others => '0');
      rx0_frames_err_reg <= (others => '0');
      rx1_frames_ok_reg  <= (others => '0');
      rx1_frames_err_reg <= (others => '0');
    elsif rising_edge(clk0_0) then
      if clear_clk0 = '1' then
        rx0_frames_ok_reg  <= (others => '0');
        rx0_frames_err_reg <= (others => '0');
        rx1_frames_ok_reg  <= (others => '0');
        rx1_frames_err_reg <= (others => '0');
      else
        -- Link 0
        if rx0_frame_ok_int = '1' and rx0_frames_ok_reg /= COUNTER_MAX then
          rx0_frames_ok_reg <= rx0_frames_ok_reg + 1;
        end if;
        if rx0_frame_err_int = '1' and rx0_frames_err_reg /= COUNTER_MAX then
          rx0_frames_err_reg <= rx0_frames_err_reg + 1;
        end if;
        -- Link 1
        if rx1_frame_ok_int = '1' and rx1_frames_ok_reg /= COUNTER_MAX then
          rx1_frames_ok_reg <= rx1_frames_ok_reg + 1;
        end if;
        if rx1_frame_err_int = '1' and rx1_frames_err_reg /= COUNTER_MAX then
          rx1_frames_err_reg <= rx1_frames_err_reg + 1;
        end if;
      end if;
    end if;
  end process;

   -- Contadores de frames dos links 2 (dominio clk2_0).
  -- Prioridade: reset > clear > incremento. Saturam em COUNTER_MAX.
  process(clk2_0, rst_n)
  begin
    if rst_n = '0' then
      rx2_frames_ok_reg  <= (others => '0');
      rx2_frames_err_reg <= (others => '0');
    elsif rising_edge(clk2_0) then
      if clear_clk2 = '1' then
        rx2_frames_ok_reg  <= (others => '0');
        rx2_frames_err_reg <= (others => '0');
      else
        if rx2_frame_ok_int = '1' and rx2_frames_ok_reg /= COUNTER_MAX then
          rx2_frames_ok_reg <= rx2_frames_ok_reg + 1;
        end if;
        if rx2_frame_err_int = '1' and rx2_frames_err_reg /= COUNTER_MAX then
          rx2_frames_err_reg <= rx2_frames_err_reg + 1;
        end if;
      end if;
    end if;
  end process;


   process(avmm_address, avmm_read, avmm_readdata_reg, avmm_write,
          avmm_writedata(0), rx0_status_sysclk_reg, rx1_status_sysclk_reg,
          rx2_status_sysclk_reg, tx0_enable_reg, tx1_enable_reg,
          tx2_enable_reg,
          rx0_frames_ok_sysclk_reg, rx0_frames_err_sysclk_reg,
          rx1_frames_ok_sysclk_reg, rx1_frames_err_sysclk_reg,
          rx2_frames_ok_sysclk_reg, rx2_frames_err_sysclk_reg)
  begin
    avmm_readdata_next <= avmm_readdata_reg;
    tx0_enable_next    <= tx0_enable_reg;
    tx1_enable_next    <= tx1_enable_reg;
    tx2_enable_next    <= tx2_enable_reg;
    clear_req_next     <= '0';          -- pulso: so vale '1' no ciclo da escrita
    if avmm_read = '1' then
      case to_integer(unsigned(avmm_address)) is
        when 0 =>
          avmm_readdata_next <= (0 => tx0_enable_reg, others => '0');
        when 1 =>
          if rx0_status_sysclk_reg = '1' then
            avmm_readdata_next <= std_logic_vector(to_unsigned(2, 32));
          else
            avmm_readdata_next <= std_logic_vector(to_unsigned(1, 32));
          end if;
        when 2 =>
          avmm_readdata_next <= (0 => tx1_enable_reg, others => '0');
        when 3 =>
          if rx1_status_sysclk_reg = '1' then
            avmm_readdata_next <= std_logic_vector(to_unsigned(2, 32));
          else
            avmm_readdata_next <= std_logic_vector(to_unsigned(1, 32));
          end if;
        when 4 =>
          avmm_readdata_next <= (0 => tx2_enable_reg, others => '0');
        when 5 =>
          if rx2_status_sysclk_reg = '1' then
            avmm_readdata_next <= std_logic_vector(to_unsigned(2, 32));
          else
            avmm_readdata_next <= std_logic_vector(to_unsigned(1, 32));
          end if;
        when 6 =>
          -- Registrador de controle: so escrita. Le 0 para nao ficar indefinido.
          avmm_readdata_next <= (others => '0');
        -- Contadores de frames (copias no dominio do sysclk; ler com TX desligados)
        when 7 =>
          avmm_readdata_next <= std_logic_vector(rx0_frames_ok_sysclk_reg);
        when 8 =>
          avmm_readdata_next <= std_logic_vector(rx0_frames_err_sysclk_reg);
        when 9 =>
          avmm_readdata_next <= std_logic_vector(rx1_frames_ok_sysclk_reg);
        when 10 =>
          avmm_readdata_next <= std_logic_vector(rx1_frames_err_sysclk_reg);
        when 11 =>
          avmm_readdata_next <= std_logic_vector(rx2_frames_ok_sysclk_reg);
        when 12 =>
          avmm_readdata_next <= std_logic_vector(rx2_frames_err_sysclk_reg);
        when others =>
          avmm_readdata_next <= (others => '0');
      end case;
    else
      avmm_readdata_next <= (others => 'X');
    end if;
    if avmm_write = '1' then
      case to_integer(unsigned(avmm_address)) is
        when 0 =>
          tx0_enable_next <= avmm_writedata(0);
        when 2 =>
          tx1_enable_next <= avmm_writedata(0);
        when 4 =>
          tx2_enable_next <= avmm_writedata(0);
        when 6 =>
          clear_req_next <= avmm_writedata(0);  -- escrever 1 em +0x18 pede o clear
        when others =>
          null;
      end case;
    end if;
  end process;

  avmm_readdata <= avmm_readdata_reg;

end architecture serdes_rtl;
