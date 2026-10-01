library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Declaração da entidade
entity framecmp is

  -- Valores que podem ser ajustados na instancia
  generic (
    BYTES_COUNTER : integer := 100; -- Quantos bytes devem ser contados
    N_CYCLES      : integer := 5000 -- Numero de clocks que são esperados 
    );

  -- 
  port (
    clk0         : in  std_logic;       -- clock from pll 0 degrees
    rst_n        : in  std_logic;       -- porta de reset em (nivel baixo)
    status_o     : out std_logic;       -- status do sucesso
    frame_ok_o   : out std_logic;       -- pulso de 1 ciclo: frame recebido sem erro
    frame_err_o  : out std_logic;       -- pulso de 1 ciclo: frame recebido com erro
    -- AVST RX - Bloco Altera
    s_avst_valid : in  std_logic;       -- avisa que tem um byte valido
    s_avst_ready : out std_logic;       -- avisa que esta pronto para ler o byte
    s_avst_sop   : in  std_logic;       -- avisa que é inicio de um pacote
    s_avst_eop   : in  std_logic;       -- avisa que é fim de um pacote
    s_avst_data  : in  std_logic_vector(7 downto 0)  -- dado recebido
    );

end entity framecmp;

architecture framecmp_rtl of framecmp is

  signal cycles_counter_next, cycles_counter_reg : integer              := 0;  -- Contador de ciclos
  signal word_counter_next, word_counter_reg     : integer              := BYTES_COUNTER - 1; -- Contador de bytes restantes
  signal data_counter_next, data_counter_reg     : unsigned(7 downto 0) := (others => '1'); -- Valor esperado do byte

  signal s_avst_ready_next, s_avst_ready_reg : std_logic := '0'; -- Handshake

  signal status_next, status_reg   : std_logic := '0'; -- sinal de status
  signal failure_next, failure_reg : std_logic; -- Flag de falha
  
  signal frame_ok_next, frame_ok_reg   : std_logic := '0'; -- Pulso de frame OK
  signal frame_err_next, frame_err_reg : std_logic := '0'; -- Pulso de frame com erro

begin

  s_avst_ready <= s_avst_ready_reg; -- recebe o valor do registrador de preparado
  status_o     <= status_reg; -- recebe o valor do registrador de status
  frame_ok_o   <= frame_ok_reg; -- recebe o valor do registrador de frame OK
  frame_err_o  <= frame_err_reg; -- recebe o valor do registrador de frame com erro
  
  process(clk0, rst_n) -- declara que o processo ocorre sempre que o clk ou o rst mudar
  begin
    if rst_n = '0' then -- Se o reset for 0 ( RESET ATIVADO )
      s_avst_ready_reg <= '0'; -- marca a entidade como não preparada
      status_reg       <= '0'; -- marca o status como não valido
      frame_ok_reg     <= '0'; -- sem pulso de frame OK
      frame_err_reg    <= '0'; -- sem pulso de frame com erro
      data_counter_reg <= (others => '1'); -- coloca 1 em todos os bits do sinal
      word_counter_reg <= BYTES_COUNTER - 1; -- ajusta a contagem para o valor inicial
    elsif rising_edge(clk0) then -- se for borda de subida do clock
      -- Pega os novos valores na porta e guarda nos registradores
      s_avst_ready_reg   <= s_avst_ready_next; 
      status_reg         <= status_next;
      failure_reg        <= failure_next;
      frame_ok_reg       <= frame_ok_next;
      frame_err_reg      <= frame_err_next;
      cycles_counter_reg <= cycles_counter_next;
      word_counter_reg   <= word_counter_next;
      data_counter_reg   <= data_counter_next;
    end if;
  end process;


  process(cycles_counter_reg, data_counter_reg, failure_reg, s_avst_data,
          s_avst_eop, s_avst_ready_reg, s_avst_sop, s_avst_valid, status_reg,
          word_counter_reg) -- processo que inicia se alguns desses sinais mudarem
  begin

    -- le os valores dos registradores e passa para a "Variavel"
    s_avst_ready_next   <= s_avst_ready_reg;
    status_next         <= status_reg;
    failure_next        <= failure_reg;
    cycles_counter_next <= cycles_counter_reg;
    word_counter_next   <= word_counter_reg;
    data_counter_next   <= data_counter_reg;

    -- Pulsos de fim de frame: valem '0' por padrao e sobem por um unico ciclo
    frame_ok_next  <= '0';
    frame_err_next <= '0';


    if cycles_counter_reg > 0 then -- if (contador de ciclos > 0)
      cycles_counter_next <= cycles_counter_reg - 1; -- contador de ciclos -1
    else
      status_next <= '0'; -- senão, coloca o status como 0
    end if;

    s_avst_ready_next <= '1'; -- Indica que está disponivel

    if s_avst_ready_reg = '1' and s_avst_valid = '1' then  -- fonte tem dado e receptor pode receber
      data_counter_next <= data_counter_reg - 1; -- subtrai o contador do valor esperado
      word_counter_next <= word_counter_reg - 1; -- subtrai o contador dos bytes restantes
      if s_avst_sop = '1' then -- se for um inicio de pacote
        failure_next <= '0'; -- zera a falha
      end if;
      if unsigned(s_avst_data) /= data_counter_reg then -- compara o byte recebido com o byte esperado
        failure_next <= '1';
        status_next  <= '0';
      end if;
      if s_avst_eop = '1' then -- se for o final de pacote: veredito do frame inteiro
        -- Frame OK = nenhum byte anterior falhou, tamanho bateu e o ultimo byte confere
        if failure_reg = '0' and word_counter_reg = 0 and unsigned(s_avst_data) = data_counter_reg then
          cycles_counter_next <= N_CYCLES * 3 / 2;  -- Reinicio o watchdog
          failure_next        <= '0';
          status_next         <= '1'; -- Marco como valido o pacote
          frame_ok_next       <= '1'; -- Pulso: frame recebido sem erro
        else
          frame_err_next      <= '1'; -- Pulso: frame com byte errado ou tamanho errado
        end if;
        -- Leave initialized for the next cycle
        data_counter_next <= (others => '1');
        word_counter_next <= BYTES_COUNTER - 1;
      end if;
    end if;

  end process;

end architecture framecmp_rtl;
