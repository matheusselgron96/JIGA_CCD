# Arquitetura do Projeto `debug-ccd`

> Jiga de teste e depuração da placa **CCD** (Selgron) — FPGA Intel Cyclone V + SoC Nios II,
> operada a partir do PC via JTAG pelo **System Console** da Intel, complementada pela IHM
> **`ccd_test`** (.NET 5 / WPF) que inspeciona o sinal do CCD pela rede.
>
> Última revisão: 28/09/2026. Cobre o *workspace* `JIGA_CCD/`, que agrupa dois repositórios
> Git independentes: `debug-ccd/` (jiga) e `ccd_test/` (fonte da IHM).

---

## 1. Propósito

O `debug-ccd` é a **bancada de validação de fabricação** da placa CCD. Ele grava um bitstream
de teste na placa e expõe ao operador uma interface gráfica (dashboard do System Console) que
executa, registra e emite laudo dos testes de aceitação de hardware:

| Teste | O que valida | Caminho de execução |
|---|---|---|
| **LEDs** | 4 LEDs de status da placa | PIO `nios_write_led` via JTAG-to-Avalon master |
| **DIP Switch** | 8 chaves de `board_id` | PIO `board_id` |
| **SRAM/SDRAM** | escrita, leitura, apagamento e verificação da SDRAM externa | firmware Nios II (`ccd.c`) comandado por PIO |
| **LVDS / RJ45** | 3 pares LVDS dos conectores CON1/CON2 | IP `rj45_tester` (Avalon-MM) |
| **CCD/AD** | captura dos canais R/G/B dos AFEs | IP `ad_module` + FIFOs `fifo_even`/`fifo_odd` (via JTAG) **ou** osciloscópio da IHM `ccd_test` (via rede) |

O resultado de cada sessão é gravado em `log/LOG_CCD_<MM_DD_AAAA>.txt`, junto com o nome do
operador e o identificador da placa ("Laudo").

Este repositório é **derivado do projeto de produção da placa CCD**: o RTL, o Qsys e o firmware
são os mesmos da aplicação real, com os blocos de processamento de imagem desativados e os
blocos de teste (`rj45_tester`, PIOs de debug, acesso JTAG direto) habilitados. Da mesma forma,
a IHM `ccd_test` é uma **versão reduzida da IHM da selecionadora**: mantém a biblioteca de
comunicação `WIZnetCOM` completa (modelos de placas CCD, CE e DRVLED) mas expõe só o
osciloscópio RGB e botões de ganho.

---

## 2. Visão em camadas

```
┌──────────────────────────────────────────────────────────────────────────┐
│ CAMADA 5 — IHM .NET `ccd_test` (opcional, PC do operador)                │
│   WPF MainWindow ─► WIZnetCOM (TCP 192.168.0.73:5001 → 192.168.0.1:5000) │
│   osciloscópio RGB 4096 px, ganhos R/G/B, start/stop de captura          │
└───────────────────────────────┬──────────────────────────────────────────┘
                                │ Ethernet (WIZnet) → pacotes 36 B / 580 B
┌───────────────────────────────▼──────────────────────────────────────────┐
│ CAMADA 4 — HOST (PC do operador)                                         │
│   Windows .bat  ─►  Nios II Command Shell  ─►  shell scripts (sh)        │
│   system-console ─► main_run.tcl ─► main_load.tcl                        │
│                       ├── boardInit.tcl   (grava SOF, reivindica master) │
│                       └── ctrlPIO.tcl     (dashboard, testes, laudo)     │
│   headers/test_sys_top_qsys.tcl  (mapa de endereços gerado do .sopcinfo) │
└───────────────────────────────┬──────────────────────────────────────────┘
                                │ JTAG (USB-Blaster) — serviços master/device
┌───────────────────────────────▼──────────────────────────────────────────┐
│ CAMADA 3 — SISTEMA Qsys `ccd_qsys` (dentro da FPGA)                      │
│   master_0 (JTAG-to-Avalon)        nios2_gen2_0 (CPU)                    │
│        └──────────── barramento Avalon-MM compartilhado ────────────┐    │
│   PIOs: board_id, nios_write_led, jtag_to_NIOS, return_nios,        │    │
│         SPI_value, save_fifo                                        │    │
│   IPs:  spi_0, ad_module_0, ad_split_data_0, rj45_tester_0,         │    │
│         fifo_even, fifo_odd, sdram_tri_controller_0,                │    │
│         onchip_memory2_0, jtag_uart_1, pll_0, pll_1                 │    │
└───────────────────────────────┬─────────────────────────────────────┴────┘
                                │ conduits
┌───────────────────────────────▼──────────────────────────────────────────┐
│ CAMADA 2 — RTL TOP-LEVEL `rtl/ccd.vhd`                                   │
│   Instancia ccd_qsys + sysclk_control (altclkctrl)                       │
│   Fan-out de sinais AD/CCD (6 AFEs), SPI, gerador de sync, LEDs          │
└───────────────────────────────┬──────────────────────────────────────────┘
                                │ pinos (2,5 V)
┌───────────────────────────────▼──────────────────────────────────────────┐
│ CAMADA 1 — HARDWARE: Cyclone V 5CEBA5F23C8, CCD TCD2564 (5400x3),        │
│   6x ADA4800 + 6x AD9945 (AFEs RGB par/ímpar), SDRAM AS4C16M16 (256 Mb), │
│   flash MT25QL128, 2x RJ45 LVDS, 8 DIP switches, 4 LEDs, JTAG            │
└──────────────────────────────────────────────────────────────────────────┘
```

A camada 5 **não passa pela cadeia JTAG**: a IHM conversa com a placa pela rede, usando o
bitstream de produção `scripts/sof/ccd_v3.0.0.sof`. O firmware do bitstream de teste
(`ccd.sof`) mantém o protocolo de pacotes como código morto (ver §6), portanto a IHM só
funciona com o SOF de produção carregado.

---

## 3. Estrutura de diretórios

### 3.1 Workspace `JIGA_CCD/`

```
JIGA_CCD/
├── debug-ccd/     # repositório da jiga (Quartus + Nios + Tcl) — este documento
└── ccd_test/      # repositório da IHM .NET 5 / WPF (fonte)
```

### 3.2 `debug-ccd/`

```
debug-ccd/
├── rtl/                          # RTL do top-level
│   ├── ccd.vhd                   # entidade `ccd` (top)
│   ├── components.ipx            # search path de IPs Qsys (aponta para lib/)
│   └── lib/                      # submódulos Git com os IPs proprietários
│       ├── fpga-utils-ad_module/ # IP ad_module (timing CCD + captura AFE)
│       ├── ad-split-data/        # IP ad_split_data (separa pixels par/ímpar)
│       └── rj45-lvds-test/       # IP rj45_tester (teste dos pares LVDS)
│
├── syn/altera/                   # projeto Quartus + Qsys + software Nios
│   ├── ccd.qpf / ccd.qsf         # projeto e pinagem (176 assignments, 2,5 V)
│   ├── ccd.sdc                   # constraints (sysclk 40 MHz, SDRAM, false paths)
│   ├── ccd_qsys.qsys             # sistema Qsys principal
│   ├── sysclk_control.qsys       # buffer de clock (altclkctrl)
│   ├── components.ipx            # redireciona para ../../rtl/components.ipx
│   └── software/
│       ├── ccd/ccd.c             # aplicação Nios II (firmware)
│       └── ccd_bsp/              # BSP HAL gerado (drivers Altera)
│
├── scripts/                      # camada host (Tcl + shell + bat)
│   ├── main_run.tcl              # ponto de entrada do System Console
│   ├── main_load.tcl             # carrega boardInit + ctrlPIO
│   ├── boardInit.tcl             # grava SOF e reivindica o master JTAG
│   ├── ctrlPIO.tcl               # dashboard, testes e geração de laudo
│   ├── build_tcl_header.sh       # gera headers/ a partir do .sopcinfo
│   ├── headers/                  # mapas de endereço gerados (sh + tcl)
│   ├── unlock_flash.tcl/.sh/.bat # destrava a flash EPCQ (via bootloader)
│   ├── progjic.sh                # grava a flash com o .jic
│   ├── start_ihm.sh / ihm_gui.bat# grava SOF volátil para uso com a IHM .NET
│   ├── start_everything.sh       # sobe o System Console
│   ├── sof/                      # ccd.sof (jiga) e ccd_v3.0.0.sof (IHM) — não versionado
│   └── sofs/                     # ccd.sof de 29/08/2025 — não versionado (ver §13)
│
├── Docs/
│   ├── arquitetura.md            # este documento
│   └── Diagrama de Blocos- Selgron.pdf   # diagrama de blocos do hardware (§4)
├── Informativo_CCD.pdf           # material informativo da placa (nov/2023)
├── videos/                       # referência visual do comportamento esperado
│   ├── led_apos_gravacao.mp4     # animação dos LEDs após gravar o bitstream
│   └── osciloscopio_esperado.mp4 # forma de onda esperada no osciloscópio da IHM
├── bitstream/ccd.v2.3.4.jic      # imagem de flash (produção) — não versionada
├── log/                          # laudos gerados pela jiga
├── net5.0-windows/net5.0-windows/# IHM compilada (ccd_test.exe + DLLs) — binário de 25/03/2025
├── net5.0-windows.zip            # mesmo binário zipado (31/01/2025)
├── ccd_test.exe - Atalho.lnk     # atalho para a IHM (caminho absoluto obsoleto, ver §13)
└── progboard.bat, start.sh, run_debug_ccd.sh   # atalhos de nível raiz
```

### 3.3 `ccd_test/`

```
ccd_test/
├── ccd_test.sln                  # solução VS 2022 (2 projetos)
├── ccd_test/                     # projeto WPF (net5.0-windows, WinExe)
│   ├── MainWindow.xaml(.cs)      # única janela: osciloscópio + botões
│   ├── Communication/InterfaceCOM.cs   # singleton da instância WIZnetCOM
│   ├── Custom_Controls/OsciloscopeGraphic.xaml(.cs)  # gráfico RGB (Polyline sobre Canvas)
│   ├── Models/OscilloscopeConfig.cs    # flags ShowR/ShowG/ShowB
│   ├── App_Code/GlobalData.cs          # estado global herdado da IHM da selecionadora
│   ├── Custom_Controls/, UC_Screens/, Windows/, Themes/  # controles herdados (pouco usados)
│   └── ccd_test.csproj           # DefineConstants NEW_COMMS; referencia WIZnetCOM
├── WIZnetCOM/                    # biblioteca de comunicação (net5.0, Library)
│   ├── WIZnetCOM.cs              # cliente TCP + fila de transmissão (MicroTimer)
│   ├── WIZnetData.cs             # parser dos pacotes recebidos (osciloscópio, imagem, dump)
│   ├── TxData.cs / TxPacket.cs   # formato de um comando (34 B) e de um pacote (0x55 0xAA + N x 34 B)
│   ├── MicroTimer.cs             # timer de alta resolução para o envio periódico
│   ├── Boards/CCD.cs             # modelo da placa CCD: um objeto por comando (LED, SDRAM, AD, ...)
│   ├── Boards/Interface.cs       # modelo da placa de interface (WIZnet): debouncers e ejeção
│   ├── Boards/CE.cs, DRVLED.cs   # outras placas da selecionadora (instanciadas, não usadas)
│   └── LogSystem/                # LogWriter (arquivo "<data>_WIZnet Log.txt" em LogDir)
└── external/ImageHelper.dll      # dependência binária (sem fonte), referenciada por HintPath
```

---

## 4. Camada de hardware — `Docs/Diagrama de Blocos- Selgron.pdf`

Resumo do diagrama de blocos da placa (fonte para entender o que cada teste da jiga exercita):

| Bloco | Componente | Observações |
|---|---|---|
| FPGA | Cyclone V `5CEBA5F23C8` | centro de tudo; JTAG protegido por TVS; XTAL externo |
| Sensor | CCD linear **TCD2564** (5400 x 3) | três linhas de cor; acionado por **4x 74ACT245** (drivers de clock/fase) |
| Front-end analógico | **6x ADA4800** (amplificadores) → **6x AD9945** (AFEs/ADC 12 bits) | dois por cor (par/ímpar): R, G, B — casa com os 6 slave selects SPI e os 6 barramentos de 12 bits do RTL (§5.2, §5.3) |
| Memória | SDRAM **AS4C16M16** (256 Mb x16) | o teste "SRAM" da jiga escreve/lê esse dispositivo |
| Configuração | NOR flash **MT25QL128** (128 Mb) | "configuração + dados"; é a EPCQ que `unlock_flash.tcl` destrava (§10.3) |
| Comunicação | 2x RJ45 (LVDS) | pares testados pelo `rj45_tester` (§5.6) |
| Interface humana | 8 DIP switches (`board_id`), 4 LEDs | testes de LED e DIP switch da jiga |
| Alimentação | 24 V → **MAX20457** (+10,5 VD, +5 VD, +3,3 VD, +1,1 VD) → **ADP7118** (+10 VA), **ADP125** (+3,3 VA, +2,5 VA) → +2,5 VD | os I/Os da FPGA usam 2,5 V (pinagem no `.qsf`) |

A placa **não tem Ethernet própria**: a IHM `ccd_test` a alcança através de uma placa de
interface com módulo WIZnet, que repassa os pacotes pelos pares LVDS (é o que o esquema de
endereçamento por *HW line* + *board ID* do `WIZnetCOM` reflete, §8.3).

---

## 5. Camada RTL — `rtl/ccd.vhd`

Entidade `ccd`, top-level do projeto Quartus. Responsabilidades:

**5.1 Instanciação.** Duas instâncias:
- `u0 : ccd_qsys` — todo o SoC;
- `u1 : sysclk_control` — buffer global de clock (`altclkctrl`) que gera `clk_int` a partir de
  `sysclk` e alimenta o domínio `clk_ad` do Qsys.

O Nios II, os PIOs e os IPs **não** são instanciados aqui: ficam todos dentro de `ccd_qsys`
(§6). Detalhes relevantes do `port map` de `u0`:

- `clk_system_clk` recebe o `sysclk` cru do pino; `clk_ad_clk` recebe o `clk_int` bufferizado.
- `clock_bridge_0_out_clk_clk` **devolve** ao top o `clock_byte` = `pll_0.outclk0` (**50 MHz**),
  clock de todos os processos locais (§5.5).
- `reset_system_reset_n` e `reset_ad_reset_n` estão fixos em `'1'`: **não há reset**; o projeto
  depende só dos valores iniciais (`:= '0'`) carregados com o bitstream.
- `spi_0_external_MISO` está fixo em `'0'`: o SPI é **só de escrita** — não há como ler de volta
  a configuração/ganho gravado nos AFEs.
- `save_to_debug_export(0)` (PIO `save_fifo`) sai como `save_int`, passa pelo `sync_gen` e volta
  como `ad_module_0_packet_save_save_to_fifo_co` (`save_reg`).

**5.2 Fan-out para os 6 AFEs.** O `ad_module` gera **um** conjunto de sinais de timing
(`cplob`, `dataclk`, `pblk`, `shd`, `shp`) e de acionamento do CCD (`theta_1a`, `theta_2a`,
`theta_2b`, `rs`, `sh`, `cp`). O top replica cada um para os 6 conversores
(`(others => sinal_int)`), assim como `mosi` e `sclk` do SPI. Os *slave selects* (`ss_int(0..5)`)
são individuais e mapeiam, nessa ordem: **red even, red odd, green even, green odd, blue even,
blue odd**.

**5.3 Entrada dos conversores.** Seis barramentos de 12 bits (`ad_red_e_i`, `ad_red_o_i`,
`ad_green_e_i`, ...) entram diretamente no `ad_module_0`.

**5.4 Interface SDRAM.** Todos os sinais do `tristate_conduit_bridge_0` são levados aos pinos;
`sdram_udqm_o` é espelhado de `sdram_dqm_o`, e `sdram_clk_o` vem da saída dedicada `pll_sdram_clk`.

**5.5 Lógica local (padrão `*_reg` / `*_next` de duas fases, registrado em `clock_byte` = 50 MHz):**

| Processo | Função |
|---|---|
| `reg_process` | único processo com clock: copia todos os `*_next` para os `*_reg` |
| `comb_process` | **inversão do DIP switch** (`board_id_next <= not board_id_i`), registrada **sem debounce**. Contém também uma FSM `ST_WAIT_SYNC` / `ST_COUNT` que é **código morto**: só sai de `ST_WAIT_SYNC` com `transition_reg = '1'`, mas `transition_int` nunca é atribuído (o Quartus o amarra a `0`), e a saída `start_packet_reg` não é usada |
| `led_process` | os LEDs **espelham o PIO `nios_write_led`** (`led_int`) com um ciclo de atraso. O código de animação (rotação a cada volta do contador de 24 bits + inversão do LED 0 no boot) é **sempre sobrescrito** pela última atribuição, cuja condição `unsigned(led_int) >= 0` é sempre verdadeira — a síntese remove o contador |
| `sync_gen` | (1) gerador de `sync` interno: contador 0..5999 → linha de **120 µs** (~8,3 kHz), pulso alto nos primeiros 100 ciclos (**2 µs**), entregue ao `ad_module` como gatilho de linha. (2) *one-shot* de captura: cada **subida** de `save_int` gera `save_reg` alto por **exatamente uma linha**, alinhado a `sync_count = 0`; `start_reg` trava novos disparos até `save_int` voltar a `0` (durante a janela `sync_count < 100`) |

**5.6 Conectores RJ45 (LVDS).** Os pares são exportados do `rj45_tester_0`:

| Porta do top | Conector | Sentido / taxa (comentários do RTL) |
|---|---|---|
| `lvds_to_ccd_o` | CON1 tx0 | transmite @ 50 MHz |
| `lvds_serial_i` | CON1 rx1 | recebe @ 50 MHz |
| `lvds_to_ejection_o` | CON1 tx2 | transmite @ 20 MHz |
| `lvds_from_ccd_i` | CON2 rx0 | recebe @ 50 MHz |
| `lvds_serial_o` | CON2 tx1 | transmite @ 50 MHz |
| `lvds_from_ejection_i` | CON2 rx2 | recebe @ 20 MHz |

**5.7 Código herdado sem uso.** O arquivo é uma adaptação do top-level de produção (o cabeçalho
ainda diz `File: poc_serdes.vhd`) e carrega declarações que não ligam em nada e são removidas na
síntese: `CTE_COUNT`, o tipo `POC_ST_SYNC`/`st_sync_*`, `data_int`, `pll_sync_125`, `we_sync_*`,
`pio_ok_*`, `flag_*`, `count_pio_*`, `sync_*`/`sync_old_*`, `count_sync_*`, `miso_int`,
`before/after_buffer_int`, `after_sim_int`, `debug_*_int`, `ad_to_fifo_*_int`, além da FSM de
debounce e da animação de LEDs descritas em §5.5.

---

## 6. Camada Qsys — `syn/altera/ccd_qsys.qsys`

### 6.1 Módulos instanciados

| Módulo | Tipo | Papel |
|---|---|---|
| `nios2_gen2_0` | `altera_nios2_gen2` | CPU que roda `ccd.c` |
| `master_0` | `altera_jtag_avalon_master` | **acesso direto do PC ao barramento** (usado pelo Tcl) |
| `onchip_memory2_0` | on-chip RAM | memória de programa/dados do Nios (40 KB @ `0x20000`) |
| `sdram_tri_controller_0` | controlador SDRAM | SDRAM externa de 16 bits (32 MB @ `0x2000000`) |
| `tristate_conduit_bridge_0` | ponte tristate | leva o barramento SDRAM aos pinos |
| `spi_0` | `altera_avalon_spi` | mestre SPI de 16 bits, 6 slaves, 1 MHz, LSB-first — configura os AFEs |
| `ad_module_0` | IP próprio | gera o timing do CCD e captura os AFEs |
| `ad_split_data_0` | IP próprio | separa o fluxo em pixels pares/ímpares (Avalon-ST) |
| `fifo_even` / `fifo_odd` | `altera_avalon_fifo` | 2048 x 32 bits, dual-clock — buffer lido pelo host |
| `rj45_tester_0` | IP próprio | gerador/verificador de padrão nos pares LVDS |
| `rj45_tester_1` | IP próprio | segunda instância, **desabilitada** (`enabled="0"`) |
| `board_id`, `nios_write_led`, `jtag_to_NIOS`, `return_nios`, `SPI_value`, `save_fifo` | PIO | canais de controle/status entre host, Nios e RTL |
| `jtag_uart_1` | JTAG UART | `stdout` do Nios (`nios2-terminal`) |
| `pll_0`, `pll_1` | `altera_pll` | árvore de clocks |
| `clock_bridge_0` / `clock_bridge_1` | ponte de clock | exporta `clock_byte` ao RTL |

### 6.2 Árvore de clocks

- `sysclk` = **40 MHz** (SDC: período 25 ns), passa pelo `sysclk_control` (`altclkctrl`).
- `pll_0` (ref. 40 MHz, 8 saídas): 50, 50, 125, 20, 20, 75, **75 → `sdram_clk`**, 10 MHz.
  O `ccd.sdc` cria `sdram_clk` como *generated clock* a partir de `pll_0 general[6]`.
- `pll_1` (ref. 40 MHz, 7 saídas): 50, 30, 30, 30, 30, 30, 15 MHz.
  A saída `general[3]` (30 MHz) é a referência dos `set_input_delay` dos 6 barramentos do AD.
- `altera_reserved_tck` (JTAG) é declarado assíncrono aos demais.

### 6.3 Mapa de endereços

Há **dois masters distintos, com mapas diferentes** — essa é a principal sutileza do projeto.

**Master JTAG (`master_0`) — usado pelos scripts Tcl do host:**

| Base | Span | Escravo |
|---|---|---|
| `0x000` | 64 | `rj45_tester_1` *(instância hoje desabilitada)* |
| `0x040` | 64 | `rj45_tester_0` |
| `0x080` | 32 | `spi_0` |
| `0x0a0` | 32 | `ad_module_0` |
| `0x0c0` | 16 | `board_id` |
| `0x0d0` | 16 | `nios_write_led` |
| `0x0e0` | 16 | `save_fifo` |
| `0x0f0` | 16 | `return_nios` |
| `0x100` | 16 | `SPI_value` |
| `0x110` | 16 | `jtag_to_NIOS` |
| `0x120` | 8 | `fifo_even` |
| `0x128` | 8 | `fifo_odd` |

**Master do Nios II (`nios2_gen2_0`) — usado por `ccd.c`:**

| Base | Escravo |
|---|---|
| `0x0` | `jtag_uart_1` |
| `0x80` | `spi_0` |
| `0xa0` | `ad_module_0` |
| `0xc0` | `board_id` |
| `0xd0` | `nios_write_led` |
| `0xf0` | `return_nios` |
| `0x100` | `SPI_value` |
| `0x110` | `jtag_to_NIOS` |
| `0x20000` | `onchip_memory2_0` (40 KB) |
| `0x2000000` | `sdram_tri_controller_0` (32 MB) |

Os endereços **não são escritos à mão**: `scripts/build_tcl_header.sh` roda
`sopc-create-header-files` sobre `syn/altera/ccd_qsys.sopcinfo` e produz
`scripts/headers/*.sh` (para shell) e `scripts/headers/test_sys_top_qsys.tcl`
(namespace `::QSYS_HEADER`, consumido por `boardInit.tcl` e `ctrlPIO.tcl`).
O `.sopcinfo` é ignorado pelo Git, então **os headers versionados são o contrato efetivo**
entre host e hardware.

### 6.4 Mapas de registradores dos IPs de teste

`rj45_tester_0` (offsets relativos à base, usados em `ctrlPIO::testLVDS`):

| Offset | Acesso | Função |
|---|---|---|
| `+0x00` | W | inicia teste do par LVDS 1 |
| `+0x04` | R | status do par 1 (**2 = OK**) |
| `+0x08` | W | inicia teste do par LVDS 2 |
| `+0x0c` | R | status do par 2 |
| `+0x10` | W | inicia teste do par LVDS 3 |
| `+0x14` | R | status do par 3 |

`ad_module_0` (usado em `ctrlPIO::enableAD`, no `case 7` do firmware e no comando `0x7` da IHM):

| Offset | Campo | Valor usado pela jiga (Tcl) | Valor enviado pela IHM `ccd_test` |
|---|---|---|---|
| `+0x02` | início da janela | `0x01AE` | `400` |
| `+0x04` | início da análise | `0x01AE` | `400` |
| `+0x06` | fim da janela | `0x09AD` | `2447` (= 400 + 2047) |
| `+0x08` | fim da análise | `0x09AD` | `2447` |
| `+0x0A` | enable | `0x0001` | `0` e depois `1` |

---

## 7. Camada de firmware — `syn/altera/software/ccd/ccd.c`

Aplicação bare-metal (HAL Altera, sem RTOS), versão declarada `FW 2.1.1`.

**Inicialização.** Reset/configuração dos AFEs por SPI (comandos `0x838D` e `0x0002`) e ganhos
iniciais por cor (R = `0x0503` nos slaves `0x0003`, G = `0x0283` em `0x000C`,
B = `0x0823` em `0x0030`), depois leitura de `board_id`.

**Laço principal.** Duas metades:

1. **Protocolo de pacotes (`if (fifoLevel >= 8)`)** — herdado do firmware de produção. Um
   `switch` sobre `data_bytes[1]` implementa os comandos abaixo. O pacote só é aceito se
   `data_bytes[0]` for igual ao `board_id` da placa ou se o bit de *broadcast* correspondente
   estiver setado. **Neste build o bloco é código morto**: `fifoLevel` é inicializado em
   zero e nunca atualizado, `data_bytes` nunca é preenchido e a maior parte dos `IOWR` já está
   comentada. Serve como referência do protocolo real da placa — e é exatamente o protocolo que
   a IHM `ccd_test` fala (§8.3):

| `data_bytes[1]` | Comando | Classe correspondente na IHM (`WIZnetCOM/Boards/CCD.cs`) |
|---|---|---|
| 0 | CONFIG LED (`0x0F & data_bytes[2]` → PIO LED) | `LedConfigData` |
| 2 | CONFIG PACKET IHM (último da cadeia, fim do pacote, enable de retorno) | `HMIReturnPacketData` |
| 3 | CONFIG EJECTION (burst start/end, enable) | `EjectionPacketData` |
| 4 | CONFIG FIFO TO PACKET (osciloscópio: bytes por sync, enable) | `OscilloscopeConfigData` |
| 5 | CONFIG SDRAM (npixels, nlines, captura, tipo de retorno) | `SDRAMConfigData` |
| 6 | CONFIG SDRAM TO PACKET | — |
| 7 | CONFIG AD MODULE (**único que ainda escreve no hardware**: janela/análise/enable do `ad_module`) | `ADConfigData` / `SendStartEndPixels` |
| 10 / 11 / 12 | GAIN AD RED / GREEN / BLUE | botões "R/G/B Gain" (`SendRGBGains`) |
| 40 | CAPTURE OSC | — (na IHM o start/stop vai para a placa de interface, cmd `0x12`) |
| 41 | CAPTURE SDRAM | — |
| 42 | CAPTURE DUMP | — |
| 49 | CAPTURE RAM TO JTAG | — |
| 50 | EJECTION SIMULATION | `EjectionSimData` |

   Comandos que a IHM sabe montar mas que **não existem** neste firmware: 1 (sync buffer),
   8 (white balance), 18/19 (fundo RGB/HSL) e 30 (classificação). Com `ccd_v3.0.0.sof` eles
   são tratados pelo firmware de produção.

2. **Canal de depuração JTAG (ativo)** — o firmware lê os PIOs `SPI_VALUE` e `JTAG_TO_NIOS` a
   cada volta e despacha o comando que o host escreveu:

| `jtag_to_NIOS` | Ação | Retorno em `return_nios` |
|---|---|---|
| 1–6 | escreve `(spi_debug << 4) \| 0x3` no AFE de índice 0–5 (slave select `0x01`…`0x20`) — ajuste de ganho por canal | `0x00` |
| 7 | escreve `0x5A5A` em 200 000 bytes da SDRAM | `0x01` ao terminar |
| 8 | lê e compara a SDRAM com `0x5A5A`; incrementa um contador a cada divergência | `3` durante, depois `1` = OK ou `>1` = nº de erros |
| 9 | zera 200 000 bytes da SDRAM | `0x01` ao terminar |
| 10 | lê e compara com `0x0000` | idem ao comando 8 |

Esse é exatamente o mecanismo que `ctrlPIO::writeRam` / `readRam` / `cleanRam` / `readcleanRam`
acionam: o host escreve o código do comando, faz *polling* em `return_nios` e pinta o LED
correspondente no dashboard.

O BSP (`ccd_bsp/`) é gerado pelo Nios II EDS (HAL + drivers `altera_avalon_spi`, `_fifo`,
`_jtag_uart`, `_pio`); `create-this-app` e `create-this-bsp` regeneram aplicação e BSP.

---

## 8. Camada IHM — `ccd_test/` (.NET 5 / WPF)

### 8.1 Composição

Dois projetos na solução `ccd_test.sln` (VS 2022, formato 17.12):

| Projeto | Tipo | Conteúdo |
|---|---|---|
| `ccd_test` | `net5.0-windows`, WPF, WinExe, `Nullable` habilitado | `MainWindow` + controle `OsciloscopeGraphic` + resquícios da IHM da selecionadora |
| `WIZnetCOM` | `net5.0`, Library | cliente TCP, fila de envio, parser de recepção, modelos das placas |

Ambos compilam com `NEW_COMMS` definido em todas as configurações (`Debug`, `Release`, e no
`WIZnetCOM` também `Debug_NewComms`/`Release_NewComms`). `WIZnetData.cs` ainda reforça com
`#define NEW_COMMS` no topo. O símbolo escolhe o **formato novo** dos pacotes de retorno
(32 pacotes x 128 pixels) em vez do antigo (23 pacotes x 186 pixels).

Dependências: `System.Drawing.Common 5.0.3` (NuGet) e `external/ImageHelper.dll` (binário sem
fonte, usado só para salvar imagens em BMP — caminho de captura de imagem que a janela atual não
aciona).

### 8.2 Fluxo de execução da `MainWindow`

```
construtor
  ├─ cria OsciloscopeGraphic (X 0..4095, Y 0..255, grade 512 x 50)
  ├─ InterfaceCOM.COMInstance.UpdateTimerInterval(100)   → envio a cada 100 ms
  ├─ NumberOfChutes = 1, NumberOfDRVLEDs = 1 → InitModules()
  │     (cria FrontCCDs/RearCCDs/IRCCDs[1], CEs[1], DRVLEDFront — só FrontCCDs[0] é usado)
  ├─ Connect(192.168.0.73:5001 → 192.168.0.1:5000)   (bloqueante, .Result)
  └─ se conectou: liga DispatcherTimer de 50 ms (leitura do socket) e pinta "WIZnet" de verde

ContentRendered
  ├─ DrawGrid()
  ├─ SendDefaultWIZnetValues()  → cmd de interface 0xA (debouncers) + reenvia toda a
  │                                configuração de FrontCCDs[0] (LED 0xA, sync buffer, SDRAM,
  │                                retorno IHM, ejeção, osciloscópio, WB, AD, LED 0x5)
  ├─ SendStartEndPixels()       → cmd CCD 0x7: janela 400..2447, enable 0 e depois 1
  └─ DisableWB()                → cmd CCD 0x8: enableWB 0 → 1, saída de WB desligada

Botões
  ├─ Start / Stop               → cmd de interface 0x12 com enable 1 / 0 (captura de osciloscópio)
  └─ R/G/B Gain "1" e "500"     → cmds CCD 0xA / 0xB / 0xC com o ganho de 16 bits

Recepção (tick de 50 ms)
  └─ lê até 16 KB do socket, sincroniza no cabeçalho 55 AA FF 3C, corta pacotes de 580 B
     e chama WIZnetData.ProcessRxData → OnOscilloscopeChanged → redesenha as 3 Polylines
```

### 8.3 Protocolo de rede (`WIZnetCOM`)

**Transmissão.** Cada comando é um `TxData` de **34 bytes**; ao entrar na fila vira um
`TxPacket` com o cabeçalho `0x55 0xAA` na frente (**36 bytes**). Comandos consecutivos são
concatenados no mesmo pacote até `PacketsPerTransmission` (20) comandos; um `MicroTimer`
descarrega um pacote por período (100 ms). Layout do `TxData`:

| Byte | Campo |
|---|---|
| 0 | flags: bit 0 = *is request*, bit 1 = *broadcast* para todas as CCDs |
| 1 | HW line: 0 = placa de interface, 1 = CCD frontal, 2 = CCD traseira, 3 = CCD IR |
| 2 | board ID (1..8) — na jiga sempre 1 |
| 3 | comando da **placa de interface** (`0xA` debouncers, `0x11` ejeção, `0x12` start/stop osciloscópio) |
| 4 | comando da **placa CCD** (tabela do §7) |
| 6.. | payload, campos de 16 bits *little-endian* (comandos de CCD) ou *big-endian* (comandos de interface) |

**Recepção.** Pacotes fixos de **580 bytes**: cabeçalho `55 AA FF 3C`, byte 4 = tipo de
retorno, bytes 6–9 = *package ID*, 14–15 = *line ID*, 16 = board ID, 18 = HW line, 20.. = 558
bytes de dados.

| Tipo de retorno | Conteúdo | Tratamento |
|---|---|---|
| 3 | taxa de ejeção | evento `OnEjectionRateChanged` (sem consumidor na IHM) |
| 4 | osciloscópio | `FillOscilloscope`: 128 pixels RGB (384 B) por pacote; 32 pacotes = 4096 pixels; o 32º dispara o redesenho |
| 5 | dump de parâmetros | `OnDumpChanged` (sem consumidor) |
| 6 | linha de imagem | `FillLine`/`FillImage`: monta imagem 4096 x 1600, aplica WB e salva BMP em `D:\Imagens` (sem consumidor na janela atual) |

### 8.4 Distribuição

- O binário entregue com a jiga fica em `debug-ccd/net5.0-windows/net5.0-windows/`
  (`ccd_test.exe`, `ccd_test.dll`, `WIZnetCOM.dll`, `ImageHelper.dll`,
  `System.Drawing.Common.dll`), com data de **25/03/2025**; `net5.0-windows.zip` é uma cópia de
  31/01/2025.
- O fonte em `ccd_test/` tem *commits* de 12/12/2025 (retorno IHM, debouncers, caminho do
  `ImageHelper`) e de **28/09/2026** ("Added oscilloscope start stop buttons"), e *builds* locais
  em `ccd_test/ccd_test/bin/{Debug,Release}/net5.0-windows/` de fev/2026. **O binário
  distribuído é anterior a essas mudanças** (ver §13).
- Compilar: abrir `ccd_test.sln` no Visual Studio 2022 com o SDK .NET 5 instalado, ou
  `dotnet build ccd_test.sln -c Release`; copiar a saída de `ccd_test/bin/Release/net5.0-windows/`
  para `debug-ccd/net5.0-windows/net5.0-windows/`.

---

## 9. Camada host — scripts Tcl

### 9.1 Cadeia de carregamento

```
main_run.tcl
  └─ source main_load.tcl
       ├─ source boardInit.tcl      → namespace ::boardInit
       ├─ source ctrlPIO.tcl        → namespace ::ctrlPIO
       ├─ ::ctrlPIO::dashBoard      (constrói a UI)
       └─ myVal → ::boardInit::init + ::ctrlPIO::dashBoard
```

### 9.2 `boardInit.tcl`

Idempotente (flag `initialized`). Passos: verifica a existência de `sof/ccd.sof`; exige
**exatamente um** dispositivo JTAG visível; grava o SOF com `device_download_sof`; reivindica o
primeiro serviço `master` (`claim_service master ... mylib`) guardando o handle em
`::boardInit::masterPath`; carrega `headers/test_sys_top_qsys.tcl` se o namespace
`::QSYS_HEADER` ainda não existir; e finalmente escreve `0xFF` em `NIOS_WRITE_LED_BASE` —
**é isso que acende todos os LEDs no início do teste**. No working tree atual há também a
variável `sofFilename2 = "sof/ccd_v3.0.0.sof"`, declarada mas ainda sem uso.

### 9.3 `ctrlPIO.tcl`

Núcleo da jiga (≈870 linhas no working tree; a versão *commitada* tem ≈220 linhas a mais,
ver §13). Três blocos:

**(a) Acesso ao hardware** — funções finas sobre `master_read_32` / `master_write_32` usando as
constantes de `::QSYS_HEADER`: `toggleLed`, `sendRGBGain`, `writeRam`, `readRam`, `cleanRam`,
`readcleanRam`, `testLVDS`, `updateCCDdata`, `enableAD`.

**(b) Dashboard** (`dashBoard`) — cria o serviço `dashboard` e a hierarquia de widgets:

```
ctrlPIO
├── IOGroup ─── ledsGroup      (4 botões Toggle + 4 LEDs + LED "Status Teste Leds")
│           └── switchGroup    (8 LEDs de interruptor + LED de status)
├── ComponentsGroup ── SRAMGroup      (botão "Executar Teste SRAM" + 4 LEDs de etapa)
│                  └── ConnectorGroup (3 LEDs de par LVDS + botão "LVDS Test")
└── FileGroup       (campo operador, campo ID da placa, botão "Salvar Laudo")
```

`controlButtons` desabilita todos os botões durante um teste longo (usado pelo teste LVDS) e os
reabilita ao final.

**(c) Laço de atualização** (`updateDashboard`) — reagenda a si mesmo a cada 300 ms
(1 s enquanto não inicializado). A cada volta relê os PIOs e atualiza as cores; na primeira
execução chama `enableAD`, cria o arquivo de log do dia e registra o estado inicial da placa.

### 9.4 Critérios de aprovação implementados

| Teste | Critério |
|---|---|
| LEDs | a placa inicia com `0xF` (todos acesos, escritos por `boardInit`); o operador apaga os 4 pelos botões e, ao chegar em `0`, `validLeds` registra "OK". Se o valor inicial **não** for `0xF`, marca `LEDError` e o laudo sai como ERROR |
| DIP Switch | como o RTL inverte `board_id`, a leitura inicial esperada é `0xFF` (todas as chaves em `0`); o operador aciona as 8 e a passagem por `0` valida o teste. Início diferente de `0xFF` marca `switchError` |
| SRAM | as 4 etapas (write / read / erase / read-erased) precisam retornar `1`; `return_nios > 10` durante a leitura pinta o LED de vermelho e aborta |
| LVDS | cada par deve ler `2` no registrador de status após 5000 iterações de *polling* |
| CCD | `CCDRed` / `CCDGreen` / `CCDBlue` confirmados manualmente pelo operador (`validateCCD*`) |

`writeData` consolida tudo e anexa o laudo ao arquivo de log, com data/hora, operador e ID da placa.
Os laudos existentes em `log/` (fev, mar, jun e dez/2025) mostram que o erro mais comum de
partida é o DIP switch fora de `0xFF` ("Teste Switchs: started with error!!"): as 8 chaves
precisam estar em `0` **antes** de iniciar a jiga.

---

## 10. Fluxos operacionais

### 10.1 Rodar a jiga (fluxo principal)

```
scripts/start_gui.bat            (ou ./run_debug_ccd.sh)
  └─ Nios II Command Shell
       └─ scripts/start_everything.sh
            └─ system-console --desktop_script=main_run.tcl
                 └─ grava sof/ccd.sof, abre o dashboard, inicia os testes
```
Para ver o `stdout` do Nios, abrir `nios2-terminal` em paralelo. O vídeo
`videos/led_apos_gravacao.mp4` mostra o comportamento de LEDs esperado logo após a gravação;
como o RTL só espelha o PIO `nios_write_led` (§5.5), qualquer animação ali vem de escritas no
PIO (firmware/Tcl), não do `led_process`.

### 10.2 Gravar a flash de produção

```
progboard.bat → scripts/progjic.sh → quartus_pgm -m jtag -o "ipv;bitstream/ccd.v2.3.4.jic"
```

### 10.3 Destravar a flash antes de gravar

O firmware `fpga-bootloader` protege **todos** os setores da EPCQ (MT25QL128) ao inicializar, e
os bits de proteção são não-voláteis — `quartus_pgm` falha ao apagar. `unlock_flash.tcl`
replica pelo PC o `unprotectAll()` do bootloader, escrevendo `UNPROTECT_ALL_SECTORS` (`0x1003`)
no registrador `MEM_OP` (`+0xc`) do controlador EPCQ em `0xe0`, via System Console.

```
scripts/unlock_flash.bat → unlock_flash.sh → system-console --cli --script=unlock_flash.tcl
```
Requisito: a placa precisa estar rodando **o design do bootloader** (o design de aplicação não
tem controlador EPCQ; o script se recusa a rodar se detectar o `master_0` da aplicação).

### 10.4 Inspecionar o sinal do CCD pela IHM .NET

```
scripts/ihm_gui.bat → start_ihm.sh → quartus_pgm -m jtag -o "p;sof/ccd_v3.0.0.sof"
                                   → abrir net5.0-windows/net5.0-windows/ccd_test.exe
```

Pré-requisitos e sequência:

1. A interface de rede do PC deve ter o IP **192.168.0.73** (a IHM faz *bind* nesse endereço,
   porta 5001) e a placa de interface WIZnet deve responder em **192.168.0.1:5000**. Sem isso
   a conexão falha silenciosamente: o indicador "WIZnet" fica vermelho e o gráfico não atualiza.
2. Com a conexão verde, a janela envia sozinha a configuração inicial (§8.2). Clicar **Start**
   para iniciar o envio contínuo do osciloscópio e **Stop** para interromper.
3. Os botões de ganho aplicam 1 ou 500 a cada cor; a forma de onda esperada está em
   `videos/osciloscopio_esperado.mp4`.
4. O log da comunicação é gravado em `<LogDir>/<data>_WIZnet Log.txt` (`LogWriter`).

### 10.5 Regerar o mapa de endereços após mexer no Qsys

```
# depois de gerar o sistema no Qsys (o que produz ccd_qsys.sopcinfo)
cd scripts && ./build_tcl_header.sh
```
O script falha explicitamente se qualquer macro esperada estiver ausente — é a proteção contra
renomear ou remover um periférico no Qsys sem atualizar o Tcl. No working tree atual
`start_everything.sh` **não chama mais** `build_tcl_header.sh` automaticamente (a chamada foi
removida, alteração ainda não *commitada*), portanto esse passo é sempre manual.

---

## 11. Dependências externas

| Dependência | Versão / caminho usado |
|---|---|
| Intel Quartus Prime Lite | `C:\intelFPGA_lite\18.1` (caminho fixo nos `.bat`) |
| Nios II Command Shell / EDS | `nios2eds\Nios II Command Shell.bat` |
| System Console (`system-console`) | vem com o Quartus |
| `quartus_pgm`, `sopc-create-header-files` | vêm com o Quartus |
| Driver USB-Blaster | necessário para o JTAG |
| .NET 5 Desktop Runtime | para **executar** a IHM `ccd_test.exe` |
| .NET 5 SDK + Visual Studio 2022 (17.12) | para **compilar** `ccd_test.sln` |
| `System.Drawing.Common 5.0.3` | NuGet, restaurado no build do `WIZnetCOM` |
| `ImageHelper.dll` | binário em `ccd_test/external/` (sem fonte; não versionado — aparece como `??` no `git status`) |
| Placa de interface WIZnet em `192.168.0.1:5000` | necessária apenas para a IHM |

**Submódulos Git** (`.gitmodules` do `debug-ccd`) — os três IPs proprietários usados pelo Qsys:

| Submódulo | Repositório |
|---|---|
| `rtl/lib/fpga-utils-ad_module` | `https://github.com/Selgron/fpga-utils-ad_module.git` |
| `rtl/lib/ad-split-data` | `git@github.com:Selgron/ad-split-data.git` |
| `rtl/lib/rj45-lvds-test` | `git@github.com:Selgron/rj45-lvds-test.git` |

`rtl/components.ipx` registra os três como componentes Qsys (`ad_module`, `ad_split_data`,
`rj45_tester`) apontando para os respectivos `*_hw.tcl`. **Sem o código dos três submódulos o
sistema Qsys não gera.** Estado real do clone (verificado em 28/09/2026):

| Submódulo | Commit registrado | Código-fonte presente | Metadados Git |
|---|---|---|---|
| `ad-split-data` | `6bf6d0c` | ✅ `ad_split_data.vhd`, `ad_split_data_hw.tcl` | ❌ `.git/modules/rtl/lib/ad-split-data` inexistente |
| `rj45-lvds-test` | `bc2ae90` | ✅ `rjtester.vhd`, `rj45_tester_hw.tcl`, `serdes/`, `frame/`, `sim/` | ❌ `.git/modules/rtl/lib/rj45-lvds-test` inexistente |
| `fpga-utils-ad_module` | `846022c` | ✅ restaurado em 28/09/2026 (antes só `README.md`) | ✅ íntegros |

- `ad-split-data` e `rj45-lvds-test` **têm os arquivos** (parecem ter sido copiados sem os
  metadados): o Quartus/Qsys os encontra normalmente, mas `git submodule status` falha com
  `fatal: not a git repository` e não é possível atualizá-los via Git. Para regularizar, apagar
  os dois diretórios e rodar `git submodule update --init --recursive` (exige acesso SSH aos
  repositórios da Selgron).
- `fpga-utils-ad_module` era o **único bloqueio real para gerar o Qsys**: o ponteiro tinha sido
  avançado sem *commit* de `846022c` para `04fa26c` ("Initial commit", só com o README), e com
  isso o `ad_module_hw.tcl` referenciado por `rtl/components.ipx` sumia do working tree.
  **Resolvido em 28/09/2026** com `git submodule update rtl/lib/fpga-utils-ad_module`, que
  voltou ao `846022c` (`ad_module.vhd`, `ad_module_hw.tcl`, `fifo_serdes_b.vhd`,
  `fifo_serdes_gb.vhd`, `scripts_ad_module/`). Se o ponteiro voltar a divergir, repetir o comando.

Nada disso afeta **rodar** a jiga: `scripts/sof/*.sof` e `bitstream/*.jic` já vêm compilados;
os submódulos só importam para recompilar.

---

## 12. Convenções do código

- **VHDL**: sufixos `_i` / `_o` para portas de entrada e saída, `_int` para sinais internos e o
  par `*_reg` / `*_next` para o padrão de duas fases (processo síncrono puro + processo
  combinacional). Estados de FSM com prefixo `ST_`.
- **Tcl**: tudo dentro de `namespace eval`, variáveis de estado declaradas no topo do namespace,
  acesso a endereços sempre via `${::QSYS_HEADER::...}` — nunca literais.
- **C# (`ccd_test`)**: um objeto por comando de placa (`*Data`), com propriedades cujo *setter*
  dispara `OnPropertyChanged()` → monta um `TxData` → evento `PropertyChanged` → a classe da
  placa (`CCD`, `Interface`) preenche HW line/board ID e repassa a `WIZnetCOM.SendCommand_OnRequested`.
  Regiões `#region Properties`; XML doc comments em inglês; `#if NEW_COMMS` para o formato de pacote.
- **Mensagens ao operador**: em português, no dashboard e nos logs; comentários de código
  misturam português e inglês.
- **Commits**: no `debug-ccd`, prefixos `Feat(escopo)`, `Fix(escopo)`, `RM(escopo)`, `Git(escopo)`;
  no `ccd_test`, frases curtas em inglês sem prefixo ("Added ...", "Updated ...", "Fixed ...").

---

## 13. Estado atual e pontos de atenção

Levantados na leitura do código — úteis para quem for dar manutenção:

**Jiga (`debug-ccd`)**

1. **Alterações não *commitadas* no working tree.** `git status` mostra modificações em
   `scripts/ctrlPIO.tcl` (remoção de ~220 linhas: o grupo "CCD" do dashboard com botões de
   ganho SPI e validação de cor), `scripts/boardInit.tcl` (`sofFilename2`),
   `scripts/start_everything.sh` (sem geração automática de headers), `scripts/headers/*.sh`
   (macros de `rj45_tester_1` reintroduzidas). O ponteiro do submódulo `fpga-utils-ad_module`,
   que também estava alterado, foi restaurado em 28/09/2026 (ver §11).
   `Docs/` e `Informativo_CCD.pdf` estão sem rastreamento. Este documento descreve o
   **working tree**, não o último *commit* (`c4eba7c`).
2. **`start.sh` está obsoleto.** Referencia `scripts/progboard.sh`, `scripts/make_qsys_header.sh`
   e `scripts/main_init.tcl`, que não existem mais. Os pontos de entrada válidos são
   `run_debug_ccd.sh` e `scripts/start_gui.bat`.
3. **Teste de CCD sem interface no dashboard.** `updateCCDdata`, `validateCCDRed/Green/Blue` e
   o gráfico `colorChart` existem no código, mas a seção `# CCD` de `dashBoard` está vazia —
   nenhum widget de CCD é criado, então essas funções estão inalcançáveis pela UI. O laudo,
   porém, continua exigindo os três canais confirmados, o que faz o teste de CCD sair sempre
   como ERROR. Na prática a inspeção do CCD migrou para a IHM `ccd_test` (§8), que não escreve
   no laudo.
4. **Bug no teste LVDS.** No par 2, tanto o ramo de sucesso quanto o de falha atribuem
   `LVDSTest2 = 1` (`scripts/ctrlPIO.tcl`), então uma falha nesse par é registrada como aprovação
   no laudo — embora o LED do dashboard fique vermelho corretamente.
5. **Polling por contagem fixa.** `testLVDS` amostra o status 5000 vezes em laço apertado e usa
   apenas o último valor; os testes de RAM fazem *busy-wait* sem timeout — um Nios travado
   congela o System Console.
6. **`rj45_tester_1` desabilitado** no `.qsys` (`enabled="0"`), mas presente no header
   versionado com base `0x0`, gerado quando a instância estava ativa.
7. **Dois diretórios de SOF.** `scripts/sof/` (usado por `boardInit.tcl` e `start_ihm.sh`,
   arquivos de 30/01/2025) e `scripts/sofs/` (`ccd.sof` de 29/08/2025, mais novo e maior),
   ambos não versionados. Vale confirmar qual é o bitstream válido e consolidar.
8. **Versões descoordenadas.** Firmware `2.1.1` (`ccd.c`), bitstream de flash `v2.3.4`
   (`ccd.v2.3.4.jic`) e SOF da IHM `v3.0.0` não seguem a mesma numeração.
9. **Artefatos fora do controle de versão.** `bitstream/`, `log/`, `net5.0-windows/`,
   `net5.0-windows.zip`, `videos/`, `Docs/`, `*.sof`, `hs_err_pid*.log`, `ctrlPIO.tcl~` e o
   `.lnk` estão no diretório mas não no `.gitignore` — aparecem como não rastreados.

**IHM (`ccd_test`)**

10. **Binário distribuído desatualizado.** `net5.0-windows/net5.0-windows/ccd_test.exe` é de
    25/03/2025; o fonte recebeu *commits* em 12/12/2025 e 28/09/2026 (botões Start/Stop do
    osciloscópio). Quem usar o binário da pasta **não tem os botões Start/Stop** nem as
    correções de retorno IHM/debouncers. Recompilar e substituir (§8.4).
11. **Atalho com caminho absoluto de outra máquina.** `ccd_test.exe - Atalho.lnk` aponta para
    `C:\Users\matheus.souza\Documents\ES\Arquivos\att_produza\pulse_gigas\att_pulse\debug-ccd\...`
    com diretório de trabalho em `C:\Users\fabricio\...`. Não funciona neste clone; usar o
    caminho relativo `net5.0-windows\net5.0-windows\ccd_test.exe`.
12. **IPs, portas e caminhos fixos no código.** `192.168.0.73:5001` / `192.168.0.1:5000` em
    `MainWindow.xaml.cs`; imagens em `D:\Imagens` (`WIZnetData.SaveImage`). Não há arquivo de
    configuração; mudar exige recompilar.
13. **Conexão bloqueante e sem reconexão.** `Connect(...).Result` no construtor trava a UI
    até o timeout do TCP se a placa não responder; após uma queda (`IOException` no envio) o
    timer de transmissão é desligado e não há tentativa de reconectar.
14. **Código herdado sem uso.** `GlobalData`, `EDisableConditions`, `NumericKeyboard`,
    `NumericUpDown`, `BaseUCScreen`, as placas `CE`/`DRVLED` e o caminho de imagem/WB do
    `WIZnetData` vieram da IHM da selecionadora e não são alcançados pela janela atual. Os
    *handlers* `btConfig_Click` e `OnDumpChanged`/`OnEjectionRateChanged` estão vazios ou sem
    assinante.
15. **`ImageHelper.dll` sem fonte e sem versionamento.** Está em `ccd_test/external/`, fora
    do Git (`??`). Sem ele o `WIZnetCOM` não compila; guardar uma cópia junto com a entrega.

**RTL (`rtl/ccd.vhd`)**

16. **Debounce e animação de LEDs sem efeito.** Ver §5.5: a FSM de debounce nunca é disparada
    e a animação é sobrescrita por `if unsigned(led_int) >= 0`.
17. **Travessias de clock sem sincronizador.** `save_int` nasce em 10 MHz (`pll_0.outclk7`,
    clock do PIO `save_fifo`) e `board_id_i` vem de pino assíncrono; ambos são lidos direto no
    domínio de 50 MHz, sem sincronizador de 2 flip-flops. Risco baixo (sinais lentos), mas é
    CDC não tratado.
18. **Sem reset e SPI sem MISO** (§5.1): um estado inconsistente só se resolve regravando o
    bitstream, e o ganho dos AFEs só pode ser conferido indiretamente pelo sinal capturado.
19. **Sensitivity lists incompletas** em `led_process` e `sync_gen` (faltam `led_int`,
    `save_reg` etc.): irrelevante para a síntese, mas a simulação pode divergir do hardware.
