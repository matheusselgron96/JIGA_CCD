/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'nios2_gen2_0' in SOPC Builder design 'ccd_qsys'
 * SOPC Builder design path: ../../ccd_qsys.sopcinfo
 *
 * Generated: Fri Oct 27 14:30:50 GMT-03:00 2023
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_gen2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x00001020
#define ALT_CPU_CPU_ARCH_NIOS2_R1
#define ALT_CPU_CPU_FREQ 125000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "tiny"
#define ALT_CPU_DATA_ADDR_WIDTH 0x1a
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x00020020
#define ALT_CPU_FLASH_ACCELERATOR_LINES 0
#define ALT_CPU_FLASH_ACCELERATOR_LINE_SIZE 0
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 125000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 0
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 0
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_ICACHE_SIZE 0
#define ALT_CPU_INST_ADDR_WIDTH 0x12
#define ALT_CPU_NAME "nios2_gen2_0"
#define ALT_CPU_OCI_VERSION 1
#define ALT_CPU_RESET_ADDR 0x00020000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x00001020
#define NIOS2_CPU_ARCH_NIOS2_R1
#define NIOS2_CPU_FREQ 125000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "tiny"
#define NIOS2_DATA_ADDR_WIDTH 0x1a
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x00020020
#define NIOS2_FLASH_ACCELERATOR_LINES 0
#define NIOS2_FLASH_ACCELERATOR_LINE_SIZE 0
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 0
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 0
#define NIOS2_ICACHE_LINE_SIZE_LOG2 0
#define NIOS2_ICACHE_SIZE 0
#define NIOS2_INST_ADDR_WIDTH 0x12
#define NIOS2_OCI_VERSION 1
#define NIOS2_RESET_ADDR 0x00020000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __AD_MODULE
#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_SPI
#define __ALTERA_NIOS2_GEN2
#define __ALTERA_SDRAM_TRI_CONTROLLER


/*
 * SPI_value configuration
 *
 */

#define ALT_MODULE_CLASS_SPI_value altera_avalon_pio
#define SPI_VALUE_BASE 0x100
#define SPI_VALUE_BIT_CLEARING_EDGE_REGISTER 0
#define SPI_VALUE_BIT_MODIFYING_OUTPUT_REGISTER 0
#define SPI_VALUE_CAPTURE 0
#define SPI_VALUE_DATA_WIDTH 8
#define SPI_VALUE_DO_TEST_BENCH_WIRING 0
#define SPI_VALUE_DRIVEN_SIM_VALUE 0
#define SPI_VALUE_EDGE_TYPE "NONE"
#define SPI_VALUE_FREQ 10000000
#define SPI_VALUE_HAS_IN 0
#define SPI_VALUE_HAS_OUT 0
#define SPI_VALUE_HAS_TRI 1
#define SPI_VALUE_IRQ -1
#define SPI_VALUE_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SPI_VALUE_IRQ_TYPE "NONE"
#define SPI_VALUE_NAME "/dev/SPI_value"
#define SPI_VALUE_RESET_VALUE 0
#define SPI_VALUE_SPAN 16
#define SPI_VALUE_TYPE "altera_avalon_pio"


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone V"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart_1"
#define ALT_STDERR_BASE 0x0
#define ALT_STDERR_DEV jtag_uart_1
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart_1"
#define ALT_STDIN_BASE 0x0
#define ALT_STDIN_DEV jtag_uart_1
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart_1"
#define ALT_STDOUT_BASE 0x0
#define ALT_STDOUT_DEV jtag_uart_1
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "ccd_qsys"


/*
 * ad_module_0 configuration
 *
 */

#define AD_MODULE_0_BASE 0xa0
#define AD_MODULE_0_IRQ -1
#define AD_MODULE_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define AD_MODULE_0_NAME "/dev/ad_module_0"
#define AD_MODULE_0_SPAN 32
#define AD_MODULE_0_TYPE "ad_module"
#define ALT_MODULE_CLASS_ad_module_0 ad_module


/*
 * board_id configuration
 *
 */

#define ALT_MODULE_CLASS_board_id altera_avalon_pio
#define BOARD_ID_BASE 0xc0
#define BOARD_ID_BIT_CLEARING_EDGE_REGISTER 0
#define BOARD_ID_BIT_MODIFYING_OUTPUT_REGISTER 0
#define BOARD_ID_CAPTURE 0
#define BOARD_ID_DATA_WIDTH 8
#define BOARD_ID_DO_TEST_BENCH_WIRING 0
#define BOARD_ID_DRIVEN_SIM_VALUE 0
#define BOARD_ID_EDGE_TYPE "NONE"
#define BOARD_ID_FREQ 50000000
#define BOARD_ID_HAS_IN 1
#define BOARD_ID_HAS_OUT 0
#define BOARD_ID_HAS_TRI 0
#define BOARD_ID_IRQ -1
#define BOARD_ID_IRQ_INTERRUPT_CONTROLLER_ID -1
#define BOARD_ID_IRQ_TYPE "NONE"
#define BOARD_ID_NAME "/dev/board_id"
#define BOARD_ID_RESET_VALUE 0
#define BOARD_ID_SPAN 16
#define BOARD_ID_TYPE "altera_avalon_pio"


/*
 * hal configuration
 *
 */

#define ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
#define ALT_MAX_FD 4
#define ALT_SYS_CLK none
#define ALT_TIMESTAMP_CLK none


/*
 * jtag_to_NIOS configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_to_NIOS altera_avalon_pio
#define JTAG_TO_NIOS_BASE 0x110
#define JTAG_TO_NIOS_BIT_CLEARING_EDGE_REGISTER 0
#define JTAG_TO_NIOS_BIT_MODIFYING_OUTPUT_REGISTER 0
#define JTAG_TO_NIOS_CAPTURE 0
#define JTAG_TO_NIOS_DATA_WIDTH 4
#define JTAG_TO_NIOS_DO_TEST_BENCH_WIRING 0
#define JTAG_TO_NIOS_DRIVEN_SIM_VALUE 0
#define JTAG_TO_NIOS_EDGE_TYPE "NONE"
#define JTAG_TO_NIOS_FREQ 10000000
#define JTAG_TO_NIOS_HAS_IN 0
#define JTAG_TO_NIOS_HAS_OUT 0
#define JTAG_TO_NIOS_HAS_TRI 1
#define JTAG_TO_NIOS_IRQ -1
#define JTAG_TO_NIOS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define JTAG_TO_NIOS_IRQ_TYPE "NONE"
#define JTAG_TO_NIOS_NAME "/dev/jtag_to_NIOS"
#define JTAG_TO_NIOS_RESET_VALUE 0
#define JTAG_TO_NIOS_SPAN 16
#define JTAG_TO_NIOS_TYPE "altera_avalon_pio"


/*
 * jtag_uart_1 configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart_1 altera_avalon_jtag_uart
#define JTAG_UART_1_BASE 0x0
#define JTAG_UART_1_IRQ 0
#define JTAG_UART_1_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_1_NAME "/dev/jtag_uart_1"
#define JTAG_UART_1_READ_DEPTH 64
#define JTAG_UART_1_READ_THRESHOLD 8
#define JTAG_UART_1_SPAN 8
#define JTAG_UART_1_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_1_WRITE_DEPTH 64
#define JTAG_UART_1_WRITE_THRESHOLD 8


/*
 * nios_write_led configuration
 *
 */

#define ALT_MODULE_CLASS_nios_write_led altera_avalon_pio
#define NIOS_WRITE_LED_BASE 0xd0
#define NIOS_WRITE_LED_BIT_CLEARING_EDGE_REGISTER 0
#define NIOS_WRITE_LED_BIT_MODIFYING_OUTPUT_REGISTER 0
#define NIOS_WRITE_LED_CAPTURE 0
#define NIOS_WRITE_LED_DATA_WIDTH 4
#define NIOS_WRITE_LED_DO_TEST_BENCH_WIRING 0
#define NIOS_WRITE_LED_DRIVEN_SIM_VALUE 0
#define NIOS_WRITE_LED_EDGE_TYPE "NONE"
#define NIOS_WRITE_LED_FREQ 50000000
#define NIOS_WRITE_LED_HAS_IN 0
#define NIOS_WRITE_LED_HAS_OUT 1
#define NIOS_WRITE_LED_HAS_TRI 0
#define NIOS_WRITE_LED_IRQ -1
#define NIOS_WRITE_LED_IRQ_INTERRUPT_CONTROLLER_ID -1
#define NIOS_WRITE_LED_IRQ_TYPE "NONE"
#define NIOS_WRITE_LED_NAME "/dev/nios_write_led"
#define NIOS_WRITE_LED_RESET_VALUE 0
#define NIOS_WRITE_LED_SPAN 16
#define NIOS_WRITE_LED_TYPE "altera_avalon_pio"


/*
 * onchip_memory2_0 configuration
 *
 */

#define ALT_MODULE_CLASS_onchip_memory2_0 altera_avalon_onchip_memory2
#define ONCHIP_MEMORY2_0_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define ONCHIP_MEMORY2_0_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define ONCHIP_MEMORY2_0_BASE 0x20000
#define ONCHIP_MEMORY2_0_CONTENTS_INFO ""
#define ONCHIP_MEMORY2_0_DUAL_PORT 0
#define ONCHIP_MEMORY2_0_GUI_RAM_BLOCK_TYPE "AUTO"
#define ONCHIP_MEMORY2_0_INIT_CONTENTS_FILE "ccd_qsys_onchip_memory2_0"
#define ONCHIP_MEMORY2_0_INIT_MEM_CONTENT 1
#define ONCHIP_MEMORY2_0_INSTANCE_ID "NONE"
#define ONCHIP_MEMORY2_0_IRQ -1
#define ONCHIP_MEMORY2_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ONCHIP_MEMORY2_0_NAME "/dev/onchip_memory2_0"
#define ONCHIP_MEMORY2_0_NON_DEFAULT_INIT_FILE_ENABLED 0
#define ONCHIP_MEMORY2_0_RAM_BLOCK_TYPE "AUTO"
#define ONCHIP_MEMORY2_0_READ_DURING_WRITE_MODE "DONT_CARE"
#define ONCHIP_MEMORY2_0_SINGLE_CLOCK_OP 0
#define ONCHIP_MEMORY2_0_SIZE_MULTIPLE 1
#define ONCHIP_MEMORY2_0_SIZE_VALUE 40960
#define ONCHIP_MEMORY2_0_SPAN 40960
#define ONCHIP_MEMORY2_0_TYPE "altera_avalon_onchip_memory2"
#define ONCHIP_MEMORY2_0_WRITABLE 1


/*
 * return_nios configuration
 *
 */

#define ALT_MODULE_CLASS_return_nios altera_avalon_pio
#define RETURN_NIOS_BASE 0xf0
#define RETURN_NIOS_BIT_CLEARING_EDGE_REGISTER 0
#define RETURN_NIOS_BIT_MODIFYING_OUTPUT_REGISTER 0
#define RETURN_NIOS_CAPTURE 0
#define RETURN_NIOS_DATA_WIDTH 8
#define RETURN_NIOS_DO_TEST_BENCH_WIRING 0
#define RETURN_NIOS_DRIVEN_SIM_VALUE 0
#define RETURN_NIOS_EDGE_TYPE "NONE"
#define RETURN_NIOS_FREQ 10000000
#define RETURN_NIOS_HAS_IN 0
#define RETURN_NIOS_HAS_OUT 0
#define RETURN_NIOS_HAS_TRI 1
#define RETURN_NIOS_IRQ -1
#define RETURN_NIOS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define RETURN_NIOS_IRQ_TYPE "NONE"
#define RETURN_NIOS_NAME "/dev/return_nios"
#define RETURN_NIOS_RESET_VALUE 0
#define RETURN_NIOS_SPAN 16
#define RETURN_NIOS_TYPE "altera_avalon_pio"


/*
 * sdram_tri_controller_0 configuration
 *
 */

#define ALT_MODULE_CLASS_sdram_tri_controller_0 altera_sdram_tri_controller
#define SDRAM_TRI_CONTROLLER_0_BASE 0x2000000
#define SDRAM_TRI_CONTROLLER_0_IRQ -1
#define SDRAM_TRI_CONTROLLER_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDRAM_TRI_CONTROLLER_0_NAME "/dev/sdram_tri_controller_0"
#define SDRAM_TRI_CONTROLLER_0_SPAN 33554432
#define SDRAM_TRI_CONTROLLER_0_TYPE "altera_sdram_tri_controller"


/*
 * spi_0 configuration
 *
 */

#define ALT_MODULE_CLASS_spi_0 altera_avalon_spi
#define SPI_0_BASE 0x80
#define SPI_0_CLOCKMULT 1
#define SPI_0_CLOCKPHASE 0
#define SPI_0_CLOCKPOLARITY 0
#define SPI_0_CLOCKUNITS "Hz"
#define SPI_0_DATABITS 16
#define SPI_0_DATAWIDTH 16
#define SPI_0_DELAYMULT "1.0E-9"
#define SPI_0_DELAYUNITS "ns"
#define SPI_0_EXTRADELAY 0
#define SPI_0_INSERT_SYNC 0
#define SPI_0_IRQ -1
#define SPI_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SPI_0_ISMASTER 1
#define SPI_0_LSBFIRST 1
#define SPI_0_NAME "/dev/spi_0"
#define SPI_0_NUMSLAVES 6
#define SPI_0_PREFIX "spi_"
#define SPI_0_SPAN 32
#define SPI_0_SYNC_REG_DEPTH 2
#define SPI_0_TARGETCLOCK 1000000u
#define SPI_0_TARGETSSDELAY "0.0"
#define SPI_0_TYPE "altera_avalon_spi"

#endif /* __SYSTEM_H_ */
