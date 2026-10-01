# fpga-lib-comms-data_recovery



**Descrição Funcional do Submódulo**

Este submódulo tem como objetivo recuperar os dados da comunicação pelo RJ45. Transformando dados do formato serial para o formato paralelo.

**Port Map**

- sop_o: sinal de saída indicando a transição encontrada pelo sync;

- serial_data_i: entrada com o dado serial;

- parallel_data_o[8]: saída com o dados paralelos;

- data_valid_o: saída indicando quando há dado válido;

- clk0 e clk90: clocks com defasagem de 90o para capturar o pacote de ejeção no momento correto, devem possuir a mesma frequência;
- rst_n: reset.

O submódulo não necessita a configuração de parâmetros em tempo real para funcionamento. Porém, existe a possibilidade de modificar os valores generic no Qsys, são eles,  BYTES_COUNTER, que indica o tamanho máximo do pacote recebido e MIN_START_PULSE_CYCLES, que indica o mínimo de pulsos necessários para a transição do sync ser reconhecida, evitando reconhecer a transição a partir de ruídos.
