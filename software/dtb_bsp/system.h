/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'cpu' in SOPC Builder design 'dtb_system'
 * SOPC Builder design path: ../../dtb/dtb_system.sopcinfo
 *
 * Generated: Thu Jul 11 00:06:20 CEST 2013
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

#define ALT_CPU_ARCHITECTURE "altera_nios2_qsys"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x8000820
#define ALT_CPU_CPU_FREQ 50000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "fast"
#define ALT_CPU_DATA_ADDR_WIDTH 0x1c
#define ALT_CPU_DCACHE_LINE_SIZE 32
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_DCACHE_SIZE 4096
#define ALT_CPU_EXCEPTION_ADDR 0x120
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 50000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 1
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 1
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 32
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_ICACHE_SIZE 4096
#define ALT_CPU_INITDA_SUPPORTED
#define ALT_CPU_INST_ADDR_WIDTH 0x1c
#define ALT_CPU_NAME "cpu"
#define ALT_CPU_NUM_OF_SHADOW_REG_SETS 0
#define ALT_CPU_RESET_ADDR 0x8000000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x8000820
#define NIOS2_CPU_FREQ 50000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "fast"
#define NIOS2_DATA_ADDR_WIDTH 0x1c
#define NIOS2_DCACHE_LINE_SIZE 32
#define NIOS2_DCACHE_LINE_SIZE_LOG2 5
#define NIOS2_DCACHE_SIZE 4096
#define NIOS2_EXCEPTION_ADDR 0x120
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 1
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 1
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 32
#define NIOS2_ICACHE_LINE_SIZE_LOG2 5
#define NIOS2_ICACHE_SIZE 4096
#define NIOS2_INITDA_SUPPORTED
#define NIOS2_INST_ADDR_WIDTH 0x1c
#define NIOS2_NUM_OF_SHADOW_REG_SETS 0
#define NIOS2_RESET_ADDR 0x8000000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ADC
#define __ADV3224
#define __ALTERA_AVALON_EPCS_FLASH_CONTROLLER
#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_AVALON_PERFORMANCE_COUNTER
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_SGDMA
#define __ALTERA_AVALON_SYSID_QSYS
#define __ALTERA_AVALON_TIMER
#define __ALTERA_NIOS2_QSYS
#define __ALTMEMDDR2
#define __DAQ_DMA
#define __DELAY_OUT
#define __FT232H
#define __I2C_MASTER
#define __LVDS2LCDS
#define __PATTERNGENERATOR
#define __PROBE
#define __PSI2C
#define __SPI_MASTER
#define __TRIPLE_SPEED_ETHERNET


/*
 * LCDS_io configuration
 *
 */

#define ALT_MODULE_CLASS_LCDS_io lvds2lcds
#define LCDS_IO_BASE 0x8100040
#define LCDS_IO_IRQ -1
#define LCDS_IO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define LCDS_IO_NAME "/dev/LCDS_io"
#define LCDS_IO_SPAN 1
#define LCDS_IO_TYPE "lvds2lcds"


/*
 * LED configuration
 *
 */

#define ALT_MODULE_CLASS_LED altera_avalon_pio
#define LED_BASE 0x8100020
#define LED_BIT_CLEARING_EDGE_REGISTER 0
#define LED_BIT_MODIFYING_OUTPUT_REGISTER 0
#define LED_CAPTURE 0
#define LED_DATA_WIDTH 4
#define LED_DO_TEST_BENCH_WIRING 0
#define LED_DRIVEN_SIM_VALUE 0x0
#define LED_EDGE_TYPE "NONE"
#define LED_FREQ 50000000u
#define LED_HAS_IN 0
#define LED_HAS_OUT 1
#define LED_HAS_TRI 0
#define LED_IRQ -1
#define LED_IRQ_INTERRUPT_CONTROLLER_ID -1
#define LED_IRQ_TYPE "NONE"
#define LED_NAME "/dev/LED"
#define LED_RESET_VALUE 0x0
#define LED_SPAN 16
#define LED_TYPE "altera_avalon_pio"


/*
 * PSI2C configuration
 *
 */

#define ALT_MODULE_CLASS_PSI2C psi2c
#define PSI2C_BASE 0x8108000
#define PSI2C_IRQ -1
#define PSI2C_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PSI2C_NAME "/dev/PSI2C"
#define PSI2C_SPAN 32
#define PSI2C_TYPE "psi2c"


/*
 * ROC_addr configuration
 *
 */

#define ALT_MODULE_CLASS_ROC_addr altera_avalon_pio
#define ROC_ADDR_BASE 0x8100070
#define ROC_ADDR_BIT_CLEARING_EDGE_REGISTER 0
#define ROC_ADDR_BIT_MODIFYING_OUTPUT_REGISTER 0
#define ROC_ADDR_CAPTURE 0
#define ROC_ADDR_DATA_WIDTH 4
#define ROC_ADDR_DO_TEST_BENCH_WIRING 0
#define ROC_ADDR_DRIVEN_SIM_VALUE 0x0
#define ROC_ADDR_EDGE_TYPE "NONE"
#define ROC_ADDR_FREQ 50000000u
#define ROC_ADDR_HAS_IN 0
#define ROC_ADDR_HAS_OUT 1
#define ROC_ADDR_HAS_TRI 0
#define ROC_ADDR_IRQ -1
#define ROC_ADDR_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ROC_ADDR_IRQ_TYPE "NONE"
#define ROC_ADDR_NAME "/dev/ROC_addr"
#define ROC_ADDR_RESET_VALUE 0x0
#define ROC_ADDR_SPAN 16
#define ROC_ADDR_TYPE "altera_avalon_pio"


/*
 * SDC_SPI2 configuration
 *
 */

#define ALT_MODULE_CLASS_SDC_SPI2 spi_master
#define SDC_SPI2_BASE 0x8100080
#define SDC_SPI2_IRQ -1
#define SDC_SPI2_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDC_SPI2_NAME "/dev/SDC_SPI2"
#define SDC_SPI2_SPAN 16
#define SDC_SPI2_TYPE "spi_master"


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone III"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart"
#define ALT_STDERR_BASE 0x8002020
#define ALT_STDERR_DEV jtag_uart
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart"
#define ALT_STDIN_BASE 0x8002020
#define ALT_STDIN_DEV jtag_uart
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart"
#define ALT_STDOUT_BASE 0x8002020
#define ALT_STDOUT_DEV jtag_uart
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "dtb_system"


/*
 * USB configuration
 *
 */

#define ALT_MODULE_CLASS_USB ft232h
#define USB_BASE 0x8001100
#define USB_IRQ -1
#define USB_IRQ_INTERRUPT_CONTROLLER_ID -1
#define USB_NAME "/dev/USB"
#define USB_SPAN 4
#define USB_TYPE "ft232h"


/*
 * adc_0 configuration
 *
 */

#define ADC_0_BASE 0x8108090
#define ADC_0_IRQ -1
#define ADC_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ADC_0_NAME "/dev/adc_0"
#define ADC_0_SPAN 8
#define ADC_0_TYPE "adc"
#define ALT_MODULE_CLASS_adc_0 adc


/*
 * button configuration
 *
 */

#define ALT_MODULE_CLASS_button altera_avalon_pio
#define BUTTON_BASE 0x8100030
#define BUTTON_BIT_CLEARING_EDGE_REGISTER 0
#define BUTTON_BIT_MODIFYING_OUTPUT_REGISTER 0
#define BUTTON_CAPTURE 1
#define BUTTON_DATA_WIDTH 2
#define BUTTON_DO_TEST_BENCH_WIRING 0
#define BUTTON_DRIVEN_SIM_VALUE 0x0
#define BUTTON_EDGE_TYPE "ANY"
#define BUTTON_FREQ 50000000u
#define BUTTON_HAS_IN 1
#define BUTTON_HAS_OUT 0
#define BUTTON_HAS_TRI 0
#define BUTTON_IRQ 9
#define BUTTON_IRQ_INTERRUPT_CONTROLLER_ID 0
#define BUTTON_IRQ_TYPE "EDGE"
#define BUTTON_NAME "/dev/button"
#define BUTTON_RESET_VALUE 0x0
#define BUTTON_SPAN 16
#define BUTTON_TYPE "altera_avalon_pio"


/*
 * crosspoint_switch configuration
 *
 */

#define ALT_MODULE_CLASS_crosspoint_switch adv3224
#define CROSSPOINT_SWITCH_BASE 0x8100050
#define CROSSPOINT_SWITCH_IRQ -1
#define CROSSPOINT_SWITCH_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CROSSPOINT_SWITCH_NAME "/dev/crosspoint_switch"
#define CROSSPOINT_SWITCH_SPAN 8
#define CROSSPOINT_SWITCH_TYPE "adv3224"


/*
 * daq_dma_0 configuration
 *
 */

#define ALT_MODULE_CLASS_daq_dma_0 daq_dma
#define DAQ_DMA_0_BASE 0x8002040
#define DAQ_DMA_0_IRQ -1
#define DAQ_DMA_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DAQ_DMA_0_NAME "/dev/daq_dma_0"
#define DAQ_DMA_0_SPAN 32
#define DAQ_DMA_0_TYPE "daq_dma"


/*
 * delay_clk configuration
 *
 */

#define ALT_MODULE_CLASS_delay_clk delay_out
#define DELAY_CLK_BASE 0x8108020
#define DELAY_CLK_IRQ -1
#define DELAY_CLK_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DELAY_CLK_NAME "/dev/delay_clk"
#define DELAY_CLK_SPAN 8
#define DELAY_CLK_TYPE "delay_out"


/*
 * delay_ctr configuration
 *
 */

#define ALT_MODULE_CLASS_delay_ctr delay_out
#define DELAY_CTR_BASE 0x8108030
#define DELAY_CTR_IRQ -1
#define DELAY_CTR_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DELAY_CTR_NAME "/dev/delay_ctr"
#define DELAY_CTR_SPAN 8
#define DELAY_CTR_TYPE "delay_out"


/*
 * delay_sda configuration
 *
 */

#define ALT_MODULE_CLASS_delay_sda delay_out
#define DELAY_SDA_BASE 0x8108028
#define DELAY_SDA_IRQ -1
#define DELAY_SDA_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DELAY_SDA_NAME "/dev/delay_sda"
#define DELAY_SDA_SPAN 8
#define DELAY_SDA_TYPE "delay_out"


/*
 * delay_tin configuration
 *
 */

#define ALT_MODULE_CLASS_delay_tin delay_out
#define DELAY_TIN_BASE 0x8108038
#define DELAY_TIN_IRQ -1
#define DELAY_TIN_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DELAY_TIN_NAME "/dev/delay_tin"
#define DELAY_TIN_SPAN 8
#define DELAY_TIN_TYPE "delay_out"


/*
 * descriptor_memory configuration
 *
 */

#define ALT_MODULE_CLASS_descriptor_memory altera_avalon_onchip_memory2
#define DESCRIPTOR_MEMORY_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define DESCRIPTOR_MEMORY_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define DESCRIPTOR_MEMORY_BASE 0x8402000
#define DESCRIPTOR_MEMORY_CONTENTS_INFO ""
#define DESCRIPTOR_MEMORY_DUAL_PORT 0
#define DESCRIPTOR_MEMORY_GUI_RAM_BLOCK_TYPE "Automatic"
#define DESCRIPTOR_MEMORY_INIT_CONTENTS_FILE "descriptor_memory"
#define DESCRIPTOR_MEMORY_INIT_MEM_CONTENT 1
#define DESCRIPTOR_MEMORY_INSTANCE_ID "NONE"
#define DESCRIPTOR_MEMORY_IRQ -1
#define DESCRIPTOR_MEMORY_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DESCRIPTOR_MEMORY_NAME "/dev/descriptor_memory"
#define DESCRIPTOR_MEMORY_NON_DEFAULT_INIT_FILE_ENABLED 0
#define DESCRIPTOR_MEMORY_RAM_BLOCK_TYPE "Auto"
#define DESCRIPTOR_MEMORY_READ_DURING_WRITE_MODE "DONT_CARE"
#define DESCRIPTOR_MEMORY_SINGLE_CLOCK_OP 0
#define DESCRIPTOR_MEMORY_SIZE_MULTIPLE 1
#define DESCRIPTOR_MEMORY_SIZE_VALUE 1024u
#define DESCRIPTOR_MEMORY_SPAN 1024
#define DESCRIPTOR_MEMORY_TYPE "altera_avalon_onchip_memory2"
#define DESCRIPTOR_MEMORY_WRITABLE 1


/*
 * deser160 configuration
 *
 */

#define ALT_MODULE_CLASS_deser160 altera_avalon_pio
#define DESER160_BASE 0x8108070
#define DESER160_BIT_CLEARING_EDGE_REGISTER 0
#define DESER160_BIT_MODIFYING_OUTPUT_REGISTER 0
#define DESER160_CAPTURE 0
#define DESER160_DATA_WIDTH 4
#define DESER160_DO_TEST_BENCH_WIRING 0
#define DESER160_DRIVEN_SIM_VALUE 0x0
#define DESER160_EDGE_TYPE "NONE"
#define DESER160_FREQ 40000000u
#define DESER160_HAS_IN 0
#define DESER160_HAS_OUT 1
#define DESER160_HAS_TRI 0
#define DESER160_IRQ -1
#define DESER160_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DESER160_IRQ_TYPE "NONE"
#define DESER160_NAME "/dev/deser160"
#define DESER160_RESET_VALUE 0x0
#define DESER160_SPAN 16
#define DESER160_TYPE "altera_avalon_pio"


/*
 * epcs_controller configuration
 *
 */

#define ALT_MODULE_CLASS_epcs_controller altera_avalon_epcs_flash_controller
#define EPCS_CONTROLLER_BASE 0x8000000
#define EPCS_CONTROLLER_IRQ -1
#define EPCS_CONTROLLER_IRQ_INTERRUPT_CONTROLLER_ID -1
#define EPCS_CONTROLLER_NAME "/dev/epcs_controller"
#define EPCS_CONTROLLER_REGISTER_OFFSET 1024
#define EPCS_CONTROLLER_SPAN 2048
#define EPCS_CONTROLLER_TYPE "altera_avalon_epcs_flash_controller"


/*
 * fifo configuration
 *
 */

#define ALT_MODULE_CLASS_fifo altera_avalon_pio
#define FIFO_BASE 0x8108080
#define FIFO_BIT_CLEARING_EDGE_REGISTER 0
#define FIFO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define FIFO_CAPTURE 0
#define FIFO_DATA_WIDTH 1
#define FIFO_DO_TEST_BENCH_WIRING 0
#define FIFO_DRIVEN_SIM_VALUE 0x0
#define FIFO_EDGE_TYPE "NONE"
#define FIFO_FREQ 40000000u
#define FIFO_HAS_IN 0
#define FIFO_HAS_OUT 1
#define FIFO_HAS_TRI 0
#define FIFO_IRQ -1
#define FIFO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define FIFO_IRQ_TYPE "NONE"
#define FIFO_NAME "/dev/fifo"
#define FIFO_RESET_VALUE 0x0
#define FIFO_SPAN 16
#define FIFO_TYPE "altera_avalon_pio"


/*
 * hal configuration
 *
 */

#define ALT_MAX_FD 32
#define ALT_SYS_CLK SYS_TIMER
#define ALT_TIMESTAMP_CLK none


/*
 * i2c_main configuration
 *
 */

#define ALT_MODULE_CLASS_i2c_main i2c_master
#define I2C_MAIN_BASE 0x8100060
#define I2C_MAIN_IRQ 0
#define I2C_MAIN_IRQ_INTERRUPT_CONTROLLER_ID 0
#define I2C_MAIN_NAME "/dev/i2c_main"
#define I2C_MAIN_SPAN 8
#define I2C_MAIN_TYPE "i2c_master"


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x8002020
#define JTAG_UART_IRQ 10
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 64
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 64
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * main_control configuration
 *
 */

#define ALT_MODULE_CLASS_main_control altera_avalon_pio
#define MAIN_CONTROL_BASE 0x8100000
#define MAIN_CONTROL_BIT_CLEARING_EDGE_REGISTER 0
#define MAIN_CONTROL_BIT_MODIFYING_OUTPUT_REGISTER 0
#define MAIN_CONTROL_CAPTURE 0
#define MAIN_CONTROL_DATA_WIDTH 6
#define MAIN_CONTROL_DO_TEST_BENCH_WIRING 0
#define MAIN_CONTROL_DRIVEN_SIM_VALUE 0x0
#define MAIN_CONTROL_EDGE_TYPE "NONE"
#define MAIN_CONTROL_FREQ 50000000u
#define MAIN_CONTROL_HAS_IN 0
#define MAIN_CONTROL_HAS_OUT 1
#define MAIN_CONTROL_HAS_TRI 0
#define MAIN_CONTROL_IRQ -1
#define MAIN_CONTROL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define MAIN_CONTROL_IRQ_TYPE "NONE"
#define MAIN_CONTROL_NAME "/dev/main_control"
#define MAIN_CONTROL_RESET_VALUE 0x0
#define MAIN_CONTROL_SPAN 16
#define MAIN_CONTROL_TYPE "altera_avalon_pio"


/*
 * main_status configuration
 *
 */

#define ALT_MODULE_CLASS_main_status altera_avalon_pio
#define MAIN_STATUS_BASE 0x8100010
#define MAIN_STATUS_BIT_CLEARING_EDGE_REGISTER 0
#define MAIN_STATUS_BIT_MODIFYING_OUTPUT_REGISTER 0
#define MAIN_STATUS_CAPTURE 0
#define MAIN_STATUS_DATA_WIDTH 4
#define MAIN_STATUS_DO_TEST_BENCH_WIRING 0
#define MAIN_STATUS_DRIVEN_SIM_VALUE 0x0
#define MAIN_STATUS_EDGE_TYPE "NONE"
#define MAIN_STATUS_FREQ 50000000u
#define MAIN_STATUS_HAS_IN 1
#define MAIN_STATUS_HAS_OUT 0
#define MAIN_STATUS_HAS_TRI 0
#define MAIN_STATUS_IRQ -1
#define MAIN_STATUS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define MAIN_STATUS_IRQ_TYPE "NONE"
#define MAIN_STATUS_NAME "/dev/main_status"
#define MAIN_STATUS_RESET_VALUE 0x0
#define MAIN_STATUS_SPAN 16
#define MAIN_STATUS_TYPE "altera_avalon_pio"


/*
 * patterngen_ctrl configuration
 *
 */

#define ALT_MODULE_CLASS_patterngen_ctrl patterngenerator
#define PATTERNGEN_CTRL_BASE 0x8108040
#define PATTERNGEN_CTRL_IRQ -1
#define PATTERNGEN_CTRL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PATTERNGEN_CTRL_NAME "/dev/patterngen_ctrl"
#define PATTERNGEN_CTRL_SPAN 8
#define PATTERNGEN_CTRL_TYPE "patterngenerator"


/*
 * patterngen_data configuration
 *
 */

#define ALT_MODULE_CLASS_patterngen_data patterngenerator
#define PATTERNGEN_DATA_BASE 0x8108200
#define PATTERNGEN_DATA_IRQ -1
#define PATTERNGEN_DATA_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PATTERNGEN_DATA_NAME "/dev/patterngen_data"
#define PATTERNGEN_DATA_SPAN 512
#define PATTERNGEN_DATA_TYPE "patterngenerator"


/*
 * performance_counter configuration
 *
 */

#define ALT_MODULE_CLASS_performance_counter altera_avalon_performance_counter
#define PERFORMANCE_COUNTER_BASE 0x8001800
#define PERFORMANCE_COUNTER_HOW_MANY_SECTIONS 3
#define PERFORMANCE_COUNTER_IRQ -1
#define PERFORMANCE_COUNTER_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PERFORMANCE_COUNTER_NAME "/dev/performance_counter"
#define PERFORMANCE_COUNTER_SPAN 64
#define PERFORMANCE_COUNTER_TYPE "altera_avalon_performance_counter"


/*
 * probe_d1 configuration
 *
 */

#define ALT_MODULE_CLASS_probe_d1 probe
#define PROBE_D1_BASE 0x8108050
#define PROBE_D1_IRQ -1
#define PROBE_D1_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PROBE_D1_NAME "/dev/probe_d1"
#define PROBE_D1_SPAN 1
#define PROBE_D1_TYPE "probe"


/*
 * probe_d2 configuration
 *
 */

#define ALT_MODULE_CLASS_probe_d2 probe
#define PROBE_D2_BASE 0x8108060
#define PROBE_D2_IRQ -1
#define PROBE_D2_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PROBE_D2_NAME "/dev/probe_d2"
#define PROBE_D2_SPAN 1
#define PROBE_D2_TYPE "probe"


/*
 * ram_ext configuration
 *
 */

#define ALT_MODULE_CLASS_ram_ext altmemddr2
#define RAM_EXT_BASE 0x0
#define RAM_EXT_IRQ -1
#define RAM_EXT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define RAM_EXT_NAME "/dev/ram_ext"
#define RAM_EXT_SPAN 134217728
#define RAM_EXT_TYPE "altmemddr2"


/*
 * ram_ext configuration as viewed by sgdma_rx_m_write
 *
 */

#define SGDMA_RX_M_WRITE_RAM_EXT_BASE 0x0
#define SGDMA_RX_M_WRITE_RAM_EXT_IRQ -1
#define SGDMA_RX_M_WRITE_RAM_EXT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SGDMA_RX_M_WRITE_RAM_EXT_NAME "/dev/ram_ext"
#define SGDMA_RX_M_WRITE_RAM_EXT_SPAN 134217728
#define SGDMA_RX_M_WRITE_RAM_EXT_TYPE "altmemddr2"


/*
 * ram_ext configuration as viewed by sgdma_tx_m_read
 *
 */

#define SGDMA_TX_M_READ_RAM_EXT_BASE 0x0
#define SGDMA_TX_M_READ_RAM_EXT_IRQ -1
#define SGDMA_TX_M_READ_RAM_EXT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SGDMA_TX_M_READ_RAM_EXT_NAME "/dev/ram_ext"
#define SGDMA_TX_M_READ_RAM_EXT_SPAN 134217728
#define SGDMA_TX_M_READ_RAM_EXT_TYPE "altmemddr2"


/*
 * sgdma_rx configuration
 *
 */

#define ALT_MODULE_CLASS_sgdma_rx altera_avalon_sgdma
#define SGDMA_RX_ADDRESS_WIDTH 32
#define SGDMA_RX_ALWAYS_DO_MAX_BURST 1
#define SGDMA_RX_ATLANTIC_CHANNEL_DATA_WIDTH 4
#define SGDMA_RX_AVALON_MM_BYTE_REORDER_MODE 0
#define SGDMA_RX_BASE 0x8400400
#define SGDMA_RX_BURST_DATA_WIDTH 8
#define SGDMA_RX_BURST_TRANSFER 0
#define SGDMA_RX_BYTES_TO_TRANSFER_DATA_WIDTH 16
#define SGDMA_RX_CHAIN_WRITEBACK_DATA_WIDTH 32
#define SGDMA_RX_COMMAND_FIFO_DATA_WIDTH 104
#define SGDMA_RX_CONTROL_DATA_WIDTH 8
#define SGDMA_RX_CONTROL_SLAVE_ADDRESS_WIDTH 0x4
#define SGDMA_RX_CONTROL_SLAVE_DATA_WIDTH 32
#define SGDMA_RX_DESCRIPTOR_READ_BURST 0
#define SGDMA_RX_DESC_DATA_WIDTH 32
#define SGDMA_RX_HAS_READ_BLOCK 0
#define SGDMA_RX_HAS_WRITE_BLOCK 1
#define SGDMA_RX_IN_ERROR_WIDTH 6
#define SGDMA_RX_IRQ 2
#define SGDMA_RX_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SGDMA_RX_NAME "/dev/sgdma_rx"
#define SGDMA_RX_OUT_ERROR_WIDTH 0
#define SGDMA_RX_READ_BLOCK_DATA_WIDTH 32
#define SGDMA_RX_READ_BURSTCOUNT_WIDTH 4
#define SGDMA_RX_SPAN 64
#define SGDMA_RX_STATUS_TOKEN_DATA_WIDTH 24
#define SGDMA_RX_STREAM_DATA_WIDTH 32
#define SGDMA_RX_SYMBOLS_PER_BEAT 4
#define SGDMA_RX_TYPE "altera_avalon_sgdma"
#define SGDMA_RX_UNALIGNED_TRANSFER 0
#define SGDMA_RX_WRITE_BLOCK_DATA_WIDTH 32
#define SGDMA_RX_WRITE_BURSTCOUNT_WIDTH 3


/*
 * sgdma_tx configuration
 *
 */

#define ALT_MODULE_CLASS_sgdma_tx altera_avalon_sgdma
#define SGDMA_TX_ADDRESS_WIDTH 32
#define SGDMA_TX_ALWAYS_DO_MAX_BURST 1
#define SGDMA_TX_ATLANTIC_CHANNEL_DATA_WIDTH 4
#define SGDMA_TX_AVALON_MM_BYTE_REORDER_MODE 0
#define SGDMA_TX_BASE 0x8400440
#define SGDMA_TX_BURST_DATA_WIDTH 8
#define SGDMA_TX_BURST_TRANSFER 0
#define SGDMA_TX_BYTES_TO_TRANSFER_DATA_WIDTH 16
#define SGDMA_TX_CHAIN_WRITEBACK_DATA_WIDTH 32
#define SGDMA_TX_COMMAND_FIFO_DATA_WIDTH 104
#define SGDMA_TX_CONTROL_DATA_WIDTH 8
#define SGDMA_TX_CONTROL_SLAVE_ADDRESS_WIDTH 0x4
#define SGDMA_TX_CONTROL_SLAVE_DATA_WIDTH 32
#define SGDMA_TX_DESCRIPTOR_READ_BURST 0
#define SGDMA_TX_DESC_DATA_WIDTH 32
#define SGDMA_TX_HAS_READ_BLOCK 1
#define SGDMA_TX_HAS_WRITE_BLOCK 0
#define SGDMA_TX_IN_ERROR_WIDTH 0
#define SGDMA_TX_IRQ 3
#define SGDMA_TX_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SGDMA_TX_NAME "/dev/sgdma_tx"
#define SGDMA_TX_OUT_ERROR_WIDTH 1
#define SGDMA_TX_READ_BLOCK_DATA_WIDTH 32
#define SGDMA_TX_READ_BURSTCOUNT_WIDTH 3
#define SGDMA_TX_SPAN 64
#define SGDMA_TX_STATUS_TOKEN_DATA_WIDTH 24
#define SGDMA_TX_STREAM_DATA_WIDTH 32
#define SGDMA_TX_SYMBOLS_PER_BEAT 4
#define SGDMA_TX_TYPE "altera_avalon_sgdma"
#define SGDMA_TX_UNALIGNED_TRANSFER 0
#define SGDMA_TX_WRITE_BLOCK_DATA_WIDTH 32
#define SGDMA_TX_WRITE_BURSTCOUNT_WIDTH 4


/*
 * sys_timer configuration
 *
 */

#define ALT_MODULE_CLASS_sys_timer altera_avalon_timer
#define SYS_TIMER_ALWAYS_RUN 0
#define SYS_TIMER_BASE 0x8002000
#define SYS_TIMER_COUNTER_SIZE 32
#define SYS_TIMER_FIXED_PERIOD 0
#define SYS_TIMER_FREQ 50000000u
#define SYS_TIMER_IRQ 4
#define SYS_TIMER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SYS_TIMER_LOAD_VALUE 499999ull
#define SYS_TIMER_MULT 0.0010
#define SYS_TIMER_NAME "/dev/sys_timer"
#define SYS_TIMER_PERIOD 10
#define SYS_TIMER_PERIOD_UNITS "ms"
#define SYS_TIMER_RESET_OUTPUT 0
#define SYS_TIMER_SNAPSHOT 1
#define SYS_TIMER_SPAN 32
#define SYS_TIMER_TICKS_PER_SEC 100u
#define SYS_TIMER_TIMEOUT_PULSE_OUTPUT 0
#define SYS_TIMER_TYPE "altera_avalon_timer"


/*
 * sysid configuration
 *
 */

#define ALT_MODULE_CLASS_sysid altera_avalon_sysid_qsys
#define SYSID_BASE 0x8001000
#define SYSID_ID 1
#define SYSID_IRQ -1
#define SYSID_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SYSID_NAME "/dev/sysid"
#define SYSID_SPAN 8
#define SYSID_TIMESTAMP 1373490686
#define SYSID_TYPE "altera_avalon_sysid_qsys"


/*
 * tse_mac configuration
 *
 */

#define ALT_MODULE_CLASS_tse_mac triple_speed_ethernet
#define TSE_MAC_BASE 0x8400000
#define TSE_MAC_ENABLE_MACLITE 0
#define TSE_MAC_FIFO_WIDTH 32
#define TSE_MAC_IRQ -1
#define TSE_MAC_IRQ_INTERRUPT_CONTROLLER_ID -1
#define TSE_MAC_IS_MULTICHANNEL_MAC 0
#define TSE_MAC_MACLITE_GIGE 0
#define TSE_MAC_MDIO_SHARED 0
#define TSE_MAC_NAME "/dev/tse_mac"
#define TSE_MAC_NUMBER_OF_CHANNEL 1
#define TSE_MAC_NUMBER_OF_MAC_MDIO_SHARED 1
#define TSE_MAC_PCS 0
#define TSE_MAC_PCS_ID 0u
#define TSE_MAC_PCS_SGMII 0
#define TSE_MAC_RECEIVE_FIFO_DEPTH 2048
#define TSE_MAC_REGISTER_SHARED 0
#define TSE_MAC_RGMII 1
#define TSE_MAC_SPAN 1024
#define TSE_MAC_TRANSMIT_FIFO_DEPTH 2048
#define TSE_MAC_TYPE "triple_speed_ethernet"
#define TSE_MAC_UNASSIGNED "unassigned"
#define TSE_MAC_USE_MDIO 1

#endif /* __SYSTEM_H_ */
