# fpga-lib-comms-ad_module

Documentação que compreende o ad_module. Controla os sinais do CCD e do conversor AD e realiza a aquisição dos dados do AD

Repositório
======

Datasheets
======

CCD
----

[Datasheet TCD2564DG](https://trello.com/1/cards/615de9a5179d687835c95344/attachments/615deaa16ff6c8195692704b/download/TCD2564DG_Web_Datasheet_en_20190115_(9).pdf)
AD

----

[Datasheet AD9945](https://www.analog.com/media/en/technical-documentation/data-sheets/AD9945.PDF)
Pin Map CCD

--------

[Pin Map](https://trello.com/1/cards/615de9a5179d687835c95344/attachments/615ee9fb7d41a704a3f857a4/download/Pin_Map_CCD.xlsx)

Timings
=====

CCD
---

- **SH**: Sinal de Integração, tamanho de pulso deve ocorrer por 1us, sincronizado com o Sync. Habilita os outros sinais do ccd e ad.
- **1A**: quando desabilitado, mantém-se em nível alto. Só é habilitado após pelo menos 2us após a subida de SH. Quando habilitado envia um clock de 30 MHz sem defasagem.
- **2A**: quando desabilitado, mantém-se em nível baixo. Só é habilitado após pelo menos 2us após a subida de SH. Quando habilitado envia um clock de 30 MHz com defasagem de 180o.
- **2B**: quando desabilitado, mantém-se em nível baixo. Só é habilitado após pelo menos 2us após a subida de SH. Quando habilitado envia um clock de 30 MHz com defasagem de 180o.
- **RS**: quando desabilitado, mantém-se em nível baixo. Só é habilitado após pelo menos 2us após a subida de SH. Quando habilitado envia um clock de 30 MHz com defasagem de 180o e duty cycle de 25%.  Clock de Registro é o PLL 1.
- **CP**: quando desabilitado, mantém-se em nível baixo. Só é habilitado após pelo menos 2us após a subida de SH. Quando habilitado envia um clock de 30 MHz com defasagem de 180o . Clock de Registro é o PLL 1.

AD
---

- **Dataclk**: quando desabilitado, mantém-se em nível baixo. Só é habilitado após pelo menos 2us após a subida de SH. Quando habilitado envia um clock de 30 MHz com defasagem de 213.7o. 
- **CPLOB**: quando desabilitado, mantém-se em nível alto. Após 94.56 us após a descida de SH, é habilitado por um período de 260 ns;
- **PBLK**: quando desabilitado, mantém-se em nível alto. Após 1.66 us após a descida de SH, é habilitado por um período de 1.26 us;
- **SHP**: quando desabilitado, mantém-se em nível baixo. Só é habilitado após pelo menos 2us após a subida de SH. Quando habilitado envia um clock de 30 MHz com defasagem de 312.7o.
- **SHD**: quando desabilitado, mantém-se em nível baixo. Só é habilitado após pelo menos 2us após a subida de SH. Quando habilitado envia um clock de 30 MHz com defasagem de 173.2o.

Sinais do Módulo
===========

Sinais de Entrada
-----------

- **ad_i**: inputs do módulo AD à FPGA, devem ser conectados aos 12 bits de saída de cada AD no top-level. Cada AD entrega paralelamente os 12 bits de dados de cada aquisição do CCD. Os dados são registrados a cada rising edge de dataclk @ 30 MHz. Como cada canal de cor é representado por 2 ADs (pixels par e impar) de 8 bits, fazendo com que cada pixel tenha 24 bits. Assim  os dados são agrupados e uma FIFO de 48 bits, recebendo ambos os valores pares e impares (RparGparBparRimparGimparBimpar), sendo necessário apenas a manipulação de bytes na parte da análise;
- **sync_i**: entrada para sincronismo do módulo, espera um sync a cada ~100us para funcionamento correto dos sinais do CCD; 
- **avs_ad**: entrada para controle dos parâmetros de começo e fim das janelas de análise do CCD, deve ser configurado pelo NIOS no top-level, mas pode ser configurado pelo JTAG opcionalmente, recebendo 16 bits, padrão de mensagem avalon-memory mapped;
- **PLL_30_1**: clock de 30MHz para controle dos sinais do CCD (outclk4 na imagem acima);
- **PLL_30_2**: clock de 30MHz com DC 25% e PS 180o (outclk5 na imagem acima); 
- **PLL_30_3**: clock de 30MHz com DC 50% e PS 213,7o (outclk6 na imagem acima);
- **PLL_30_4**: clock de 30MHz com DC 75% e PS 312.7o (outclk7 na imagem acima);
- **PLL_30_5**: clock de 30MHz com DC 75% e PS 173.2o (outclk8 na imagem).
  

Sinais de Saída
-------------

- **ad_to_fifo**: streaming de dados que deve ser conectado a uma FIFO de 48 bits por mensagem com tamanho definindo pelos registradores **start_window** e **end_window**. Contém os valores RGB dos pixels n e n+1 por palavra. padrão de mensagem avalon streaming source sem backpressure;
- **ad_to_sdram**: streaming de dados que deve ser conectado a uma FIFO para SDRAM (conversor de 48 para 16 bits) de 48 bits por mensagem com tamanho definido pelos registradores**start_analysis_window** e **end_analysis_window**: Contém os valores RGB dos pixels n e n+1 por palavra, padrão de mensagem avalon streaming source sem backpressure;
- **ccd_o**: outputs da FPGA ao CCD, contendo os clocks de controle do CCD, devem ser conectados no top-leve;
- **ad_o**: outputs da FPGA aos ADs, como clocks e sinais de controle, além do SPI, sendo conectados no top-level;

Registradores do módulo
========

- Para controle dos parâmetros por avs, deve-se enviar o endereço junto ao dado que deve ser inserido. Os endereços são:
  -- **address_base|0x0002 - start_window**
  -- **address_base|0x0004 - start_analysis_window**
  -- **address_base|0x0006 - end_window**
  -- **address_base|0x0008 - end_analysis_window**
  -- **address_base|0x000A - enable_module**
- Para funcionamento correto, os registradores **start_analysis** deve ser menor que **end_analysis_window**, e  o registrador **start_window** deve ser menor que **end_window**. Esses registradores indicam o pixel inicial que o dado será considerado para a FIFO de análise ou SDRAM e o pixel final, descendo o sinal de válido para FIFO ou SDRAM. Idealmente os valores finais devem ser pelo menos igual ao valor inicial + 1024;
- O módulo só irá habilitar os sinais de saída assim que o **enable_module** for igual a "0001". Quando for igual a "0000" irá parar os sinais de saída. 

Clock de Registro
============

- O PLL_30_3 é utilizado para realizar os registros dos dados do AD e utilizado para gerar os sinais de 10KHz e clock_enable de todos os outros PLLs que são direcionados ao CCD e AD.
-  O PLL_30_1 é utilizado para realizar os registros dos dados dos sinais RS e CP.
- Como a FIFO de 48 bits deve estar "sincronizada" com os dados de saída do AD, o clock de escrita utilizado na FIFO deve ser PLL_30_3.

Atraso dos Pixels
===

Devido a distância entre as linhas (R, G e B) e o ponto focal de cada cor. Foi necessário introduzir atraso (em syncs) nos valores adquiridos em G (um atraso) e B (dois atrasos), para que a imagem seja amostrada corretamente.



Controle SPI do AD
============

O controle do ganho realizado pelo SPI deve ser feito no Top-Level, configurando os 6Ads distintamente.




