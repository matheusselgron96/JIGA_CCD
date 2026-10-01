#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_fifo_regs.h"
#include "altera_avalon_fifo_util.h"
#include "alt_types.h"
#include "sys/alt_stdio.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_spi.h"
#include "unistd.h"
#define ALMOST_EMPTY 1
#define ALMOST_FULL 3

typedef struct SENS_DIFF
{
    alt_u16 sensBase;
    alt_u16 classBase;

    alt_u16 proportion;
    alt_u16 angle;
    alt_u16 redMin;
    alt_u16 redMax;
    alt_u16 greenMin;
    alt_u16 greenMax;
    alt_u16 blueMin;
    alt_u16 blueMax;
    alt_u16 erosion;
    alt_u16 enable;
	alt_u16 classificationType;
} SENS_DIFF;

typedef struct FW_VERSION
{
	alt_u16 Major;
	alt_u16 Minor;
	alt_u16 Patch;
	alt_u16 Pre_Release;
} FW_VERSION;

FW_VERSION ccd_version;
SENS_DIFF diffSens[4];

int main() {

	// FW VERSION
	ccd_version.Major = 2;
	ccd_version.Minor = 1;
	ccd_version.Patch = 1;
	ccd_version.Pre_Release = 0;

	IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0xFFFF);
	IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, 0x838D);
	usleep(10);
	IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0xFFFF);
	IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, 0x0002);
	usleep(10);

	//set rgb gain
	//red
	IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x0003);
	IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, 0x0503);
	usleep(10);

	//green
	IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x000C);
	IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, 0x0283);
	usleep(10);

	//blue
	IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x0030);
	IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, 0x0823);
	usleep(10);


	for (int i = 0; i < 4; ++i)
	{
	    diffSens[i].proportion = 0;
	    diffSens[i].angle      = 0;
	    diffSens[i].redMin     = 0;
	    diffSens[i].redMax     = 0;
	    diffSens[i].greenMin   = 0;
	    diffSens[i].greenMax   = 0;
	    diffSens[i].blueMin    = 0;
	    diffSens[i].blueMax    = 0;
	    diffSens[i].erosion    = 0;
		diffSens[i].classificationType = 0;
	}

	//alt_32 data_from_rtl = 0;
	//alt_32 count = 0;
	alt_32 fifoLevel = 0;
	alt_32 fifo_read = 0;
	alt_u16 data_bytes[16] = { 0 };
	alt_u8 board_id = 0;
	alt_u8 i = 0;
	alt_u16 lastBoard = 0;
	alt_u16 startData = 0;
	alt_u16 endPacketData = 0;
	alt_u16 endPosition = 0;
	alt_u16 typeReturn = 0;
	alt_u16 enableReturnIHM = 0;
	alt_u16 maxDataSent = 0;
	alt_u16 syncsMin = 0;
	alt_u16 enableOscPacket = 0;
	alt_u16 captureOsc = 0;
	alt_u16 startPosEjec = 0;
	alt_u16 endPosEjec = 0;
	alt_u16 endPacketEjec = 0;
	alt_u16 enableEjec = 0;
	alt_u16 highCycles = 0;
	alt_u16 lowCycles = 0;
	alt_u16 repCycles = 0;
	alt_u16 syncsLow = 0;
	alt_u16 chTest = 0;
	alt_u16 fixedChannel = 0;
	alt_u16 enableSim = 0;
	alt_u16 syncEnable = 0;
	alt_u16 bgOffset = 0;
	alt_u16 startIndex = 0;
	alt_u16 endIndex = 0;
	alt_u16 sizeErosion = 0;
	alt_u16 inclination = 0;
	alt_u16 targetBlue = 0;
	alt_u16 grainSize = 0;
	alt_u16 minPixels = 0;
	alt_u16 clDiff1 = 0;
	alt_u16 clDiff2 = 0;
	alt_u16 syncOffset = 0;
	alt_u16 syncDwell = 0;
	alt_u16 pxPerChannel = 0;
	alt_u16 verticalErosion = 0;
	alt_u16 startWindow = 0;
	alt_u16 startAnalysis = 0;
	alt_u16 endWindow = 0;
	alt_u16 endAnalysis = 0;
	alt_u16 enableAd = 0;
	alt_u16 enableWB = 0;
	alt_u16 enableWBOutput = 0;
	alt_u32 startAddr;
	alt_u32 endAddr;
	alt_u8 return_dump = 0;
	alt_u16 addrWBGain = 0;
	alt_u16 redGain = 0;
	alt_u16 greenGain = 0;
	alt_u16 blueGain = 0;
	alt_u8 addrWBGainSDRAM = 0;
	alt_u16 wbSet = 0;
	alt_u16 wbProgress = 0;
	alt_u16 dumpRequests = 0;
	alt_u8 enableJTAGDump = 0;

	alt_u16 dataSDRAM[3];
	alt_u16 pixelC = 0;
	alt_u16 nLines = 0;
	alt_u16 maxLines = 100;
	alt_u8 startCapture = 0;
	alt_u16 Dump = 0;

	alt_u8 data_jtag = 0;
	alt_u8 spi_debug = 0;

	alt_u16 teste = 0;		
	
	board_id = IORD_ALTERA_AVALON_PIO_DATA(BOARD_ID_BASE);
	while (1) {

		
		if (fifoLevel >= 8) {
			
			
			if ((data_bytes[0] == board_id) || (data_bytes[0]>>8 & (1<<(board_id-1))>0)){
				switch (data_bytes[1]) {

				case 0: // CONFIG LED
					IOWR_ALTERA_AVALON_PIO_DATA(NIOS_WRITE_LED_BASE,
							0x0f & data_bytes[2]);
					break;

				case 2: // CONFIG PACKET IHM
					// LAST BOARD, should only be 1 or 0
					lastBoard = data_bytes[2];
					startData = 161;
					endPacketData = data_bytes[3];
					endPosition = data_bytes[4];
					typeReturn = 0;
					enableReturnIHM = data_bytes[5];
					//IOWR_16DIRECT(PACKET_COMM_IHM_0_BASE, 2, data_bytes[2]); //last board
					// Board ID
					//IOWR_16DIRECT(PACKET_COMM_IHM_0_BASE, 4, board_id); //alive bit position
					// Should always be set to 161, or changed if more data is added to the header
					//IOWR_16DIRECT(PACKET_COMM_IHM_0_BASE, 6, 161); //burst bit position
					// End Packet position, should contain the packet size without the start of packet
					//IOWR_16DIRECT(PACKET_COMM_IHM_0_BASE, 8, data_bytes[3]); //end packet bit position(packet size in bits without SOF)
					//IOWR_16DIRECT(PACKET_COMM_IHM_0_BASE, 10, data_bytes[4]); // end position
					// Type of Return, initially must be set to zero, changed only when data is requested
					//IOWR_16DIRECT(PACKET_COMM_IHM_0_BASE, 12, 0);
					// Enable submodule
					//IOWR_16DIRECT(PACKET_COMM_IHM_0_BASE, 14, data_bytes[5]);
					break;

				case 3: // CONFIG EJECTION
					lastBoard = data_bytes[2];
					startPosEjec = data_bytes[3];
					endPosEjec = data_bytes[4];
					endPacketEjec = data_bytes[5];
					enableEjec = data_bytes[6];
					//IOWR_16DIRECT(PACKET_COMM_EJECTION_0_BASE, 2, data_bytes[2]); //last board
					//IOWR_16DIRECT(PACKET_COMM_EJECTION_0_BASE, 4, data_bytes[3]); //burst start
					//IOWR_16DIRECT(PACKET_COMM_EJECTION_0_BASE, 6, data_bytes[4]); //burst ended
					//IOWR_16DIRECT(PACKET_COMM_EJECTION_0_BASE, 8, data_bytes[5]); //end packet
					//IOWR_16DIRECT(PACKET_COMM_EJECTION_0_BASE, 10, data_bytes[6]); //enable
					break;

				case 4: // CONFIG FIFO TO PACKET
					maxDataSent = data_bytes[2];
					syncsMin = data_bytes[3];
					enableOscPacket = data_bytes[4];
					// max data that can be sent each sync
					//IOWR_16DIRECT(FIFO_TO_PACKET_0_BASE, 2, data_bytes[2]);
					// sync to send again, not used
					//IOWR_16DIRECT(FIFO_TO_PACKET_0_BASE, 4, data_bytes[3]);
					// Enable submodule
					//IOWR_16DIRECT(FIFO_TO_PACKET_0_BASE, 8, data_bytes[4]);
					break;

				case 5: // CONFIG SDRAM
					typeReturn = data_bytes[7];
					// npixels
					//IOWR_16DIRECT(FIFO_TO_RAM_0_BASE, 2, data_bytes[2]);
					// nlines
					//IOWR_16DIRECT(FIFO_TO_RAM_0_BASE, 4, data_bytes[3]);
					// captureflag
					//IOWR_16DIRECT(FIFO_TO_RAM_0_BASE, 6, data_bytes[4]);
					// targetBlue
					//IOWR_16DIRECT(FIFO_TO_RAM_0_BASE, 8, data_bytes[5]);
					// enable sdram capture
					//IOWR_16DIRECT(FIFO_TO_RAM_0_BASE, 10, data_bytes[6]);
					// type of return
					//IOWR_16DIRECT(PACKET_COMM_IHM_0_BASE, 12, data_bytes[7]);
					break;

				case 6: // CONFIG SDRAM TO PACKET
					// max data sent
					//IOWR_16DIRECT(RAM_TO_PACKET_0_BASE, 2, data_bytes[2]);
					// enable / capture from sdram to interface
					//IOWR_16DIRECT(RAM_TO_PACKET_0_BASE, 4, data_bytes[3]);
					// type of return
					//IOWR_16DIRECT(PACKET_COMM_IHM_0_BASE, 12, data_bytes[4]);
					break;

				case 7: // CONFIG AD MODULE
					startWindow = data_bytes[2];
					startAnalysis = data_bytes[3];
					endWindow = data_bytes[4];
					endAnalysis = data_bytes[5];
					enableAd = data_bytes[6];

					// start window pos
					IOWR_16DIRECT(AD_MODULE_0_BASE, 2, data_bytes[2]);
					// start analysis pos
					IOWR_16DIRECT(AD_MODULE_0_BASE, 4, data_bytes[3]);
					// end window pos
					IOWR_16DIRECT(AD_MODULE_0_BASE, 6, data_bytes[4]);

					// end analysis pos
					IOWR_16DIRECT(AD_MODULE_0_BASE, 8, data_bytes[5]);
					// enable ad
					IOWR_16DIRECT(AD_MODULE_0_BASE, 10, data_bytes[6]);
					break;

				case 10: // GAIN AD RED

					redGain = data_bytes[2];
					// Red
					IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x0003);
					IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, (redGain << 4)|0x3);
					usleep(10);
					break;
				case 11: // GAIN AD GREEN
					greenGain = data_bytes[2];
					//green
					IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x000C);
					IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, (greenGain << 4)|0x3);
					usleep(10);
					break;
				case 12: // GAIN AD BLUE
					blueGain = data_bytes[2];
					//blue
					IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x0030);
					IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, (blueGain << 4)|0x3);
					usleep(10);
					break;
				case 13: // RESERVED



				break;
				case 34: // CLASS RESERVED
				break;
				case 35: // CLASS RESERVED
				break;
				case 36: // CLASS RESERVED
				break;
				case 37: // CLASS RESERVED
				break;
				case 38: // CLASS RESERVED
				break;
				case 39: // CLASS RESERVED
				break;
				case 40: // CAPTURE OSC
					captureOsc = data_bytes[2];
					typeReturn = data_bytes[3];
					//IOWR_16DIRECT(FIFO_TO_PACKET_0_BASE, 6, data_bytes[2]);
					//IOWR_16DIRECT(PACKET_COMM_IHM_0_BASE, 12, data_bytes[3]);
					break;

				case 41: // CAPTURE SDRAM

					startAddr = data_bytes[2]*12288;
					endAddr = startAddr + 12287;

					//IOWR_16DIRECT(RAM_TO_PACKET_0_BASE, 2, (alt_16)startAddr);
					//IOWR_16DIRECT(RAM_TO_PACKET_0_BASE, 4, (alt_16)(startAddr>>16));
					//IOWR_16DIRECT(RAM_TO_PACKET_0_BASE, 6, (alt_16)endAddr);
					//IOWR_16DIRECT(RAM_TO_PACKET_0_BASE, 8, (alt_16)(endAddr>>16));
					//IOWR_16DIRECT(RAM_TO_PACKET_0_BASE, 10, data_bytes[3]);
					//IOWR_16DIRECT(PACKET_COMM_IHM_0_BASE, 12, data_bytes[4]);

					break;
				case 42: // CAPTURE DUMP
					// Escreve o dump de parametros na fifo do packet_comm_ihm
					// Type of return
					// Cada case acima deve armazenar o que escreve no hw em variaveis
					//IOWR_16DIRECT(PACKET_COMM_IHM_0_BASE, 12, data_bytes[2]);
					// Colocar um type of return especifico, para que comece o envio antes da FIFO encher com 12k
					if (return_dump == 0  && data_bytes[3] == 1)
					{
						return_dump = 1;

						dumpRequests++;

					}

					if (return_dump == 1 && data_bytes[3] == 0)
					{
						return_dump = 0;
					}

					break;

				case 43: // CAPTURE RESERVED
					break;
				case 44: // CAPTURE RESERVED
					break;
				case 45: // CAPTURE RESERVED
					break;
				case 46: // CAPTURE RESERVED
					break;
				case 47: // CAPTURE RESERVED
					break;
				case 48: // CAPTURE RESERVED
					break;
				case 49: // CAPTURE RAM TO JTAG

					enableJTAGDump = data_bytes[2];
					maxLines = data_bytes[3];

					break;
				case 50: // EJECTION SIMULATION
					highCycles = data_bytes[3];
					lowCycles = data_bytes[4];
					repCycles = data_bytes[5];
					syncsLow = data_bytes[6];
					chTest = data_bytes[7];
					fixedChannel = data_bytes[8];
					enableSim = data_bytes[9];

					//IOWR_16DIRECT(EJECTION_SIM_0_BASE, 0, data_bytes[3]);// high
					//IOWR_16DIRECT(EJECTION_SIM_0_BASE, 2, data_bytes[4]);// low
					//IOWR_16DIRECT(EJECTION_SIM_0_BASE, 4, data_bytes[5]);// rep
					//IOWR_16DIRECT(EJECTION_SIM_0_BASE, 6, data_bytes[6]);// syncs low
					//IOWR_16DIRECT(EJECTION_SIM_0_BASE, 8, data_bytes[7]);// ch test
					//IOWR_16DIRECT(EJECTION_SIM_0_BASE, 10, data_bytes[8]);// group ejection
					//IOWR_16DIRECT(EJECTION_SIM_0_BASE, 12, data_bytes[9]);// fixed channel
					//IOWR_16DIRECT(EJECTION_SIM_0_BASE, 14, data_bytes[10]);// enable
					break;
				}

			}
		}

		/*
		if(enableJTAGDump == 1){
			if(startCapture == 0){
				Dump = IORD_16DIRECT(READ_RAM_NIOS_0_BASE, 0);
				startCapture = 1;
			}

			dataSDRAM[0] = IORD_16DIRECT(READ_RAM_NIOS_0_BASE, 0);
			alt_printf("%x, ", (alt_u8)(dataSDRAM[0]>>8));
			alt_printf("%x, ", (alt_u8)(dataSDRAM[0]));

			dataSDRAM[1] = IORD_16DIRECT(READ_RAM_NIOS_0_BASE, 0);
			alt_printf("%x\n", (alt_u8)(dataSDRAM[1]>>8));
			alt_printf("%x, ", (alt_u8)(dataSDRAM[1]));

			dataSDRAM[2] = IORD_16DIRECT(READ_RAM_NIOS_0_BASE, 0);
			alt_printf("%x, ", (alt_u8)(dataSDRAM[2]>>8));
			alt_printf("%x\n", (alt_u8)(dataSDRAM[2]));
			pixelC = pixelC + 2;

			if(pixelC == 4096){
				pixelC = 0;
				nLines++;
				if(nLines == maxLines){
					nLines = 0;
					enableJTAGDump = 2;
				}
			}
		}
		if(enableJTAGDump == 2){
			IORD_16DIRECT(READ_RAM_NIOS_0_BASE, 2);
			enableJTAGDump = 0;
		}

		*/

			alt_u8 read_status = 0;

			spi_debug = IORD_ALTERA_AVALON_PIO_DATA(SPI_VALUE_BASE);
			data_jtag = IORD_ALTERA_AVALON_PIO_DATA(JTAG_TO_NIOS_BASE);

			switch(data_jtag){
				case 1:
					// Control SPI
					IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x00001);
					IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, (spi_debug << 4)|0x3);
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 0x00);
					data_jtag = 0;

					break;
				case 2:
					IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x0002);
					IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, (spi_debug << 4)|0x3);
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 0x00);
					data_jtag = 0;
					break;
				case 3:
					IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x0004);
					IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, (spi_debug << 4)|0x3);
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 0x00);
					data_jtag = 0;
					break;
				case 4:
					// Control SPI
					IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x00008);
					IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, (spi_debug << 4)|0x3);
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 0x00);
					data_jtag = 0;
					break;
				case 5:
					IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x0010);
					IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, (spi_debug << 4)|0x3);
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 0x00);
					data_jtag = 0;
					break;
				case 6:
					IOWR_ALTERA_AVALON_SPI_SLAVE_SEL(SPI_0_BASE, 0x0020);
					IOWR_ALTERA_AVALON_SPI_TXDATA(SPI_0_BASE, (spi_debug << 4)|0x3);
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 0x00);
					data_jtag = 0;
					break;
				case 7:
					// Write
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 0x00);

					for (int i = 0 ;  i < 200000 ; ){
						IOWR_16DIRECT(SDRAM_TRI_CONTROLLER_0_BASE, i, 0x5A5A);
						i = i+2;
					}

					// Write on pio to signalize finish
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 0x01);
					IOWR_ALTERA_AVALON_PIO_DATA(JTAG_TO_NIOS_BASE, 0x00);
					data_jtag = 0;
					break;
				case 8:
					// Read
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 0x00);
					
					read_status = 1;

					for (int i = 0 ;  i < 200000 ;){
						IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 3);
						if (IORD_16DIRECT(SDRAM_TRI_CONTROLLER_0_BASE, i) != 0x5A5A){
							read_status++;
						}
						i = i + 2;

					}
					// Write on pio to signalize finish, if no error, green led
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, read_status);
					IOWR_ALTERA_AVALON_PIO_DATA(JTAG_TO_NIOS_BASE, 0x00);
					data_jtag = 0;

					
					break;	
				case 9:
					// Write
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 0x00);

					for (int i = 0 ;  i < 200000 ; ){
						IOWR_16DIRECT(SDRAM_TRI_CONTROLLER_0_BASE, i, 0x0000);
						i = i+2;
					}

					// Write on pio to signalize finish
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 0x01);
					IOWR_ALTERA_AVALON_PIO_DATA(JTAG_TO_NIOS_BASE, 0x00);
					data_jtag = 0;
					break;
				case 10:
					// Read
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 0x00);
					
					read_status = 1;

					for (int i = 0 ;  i < 200000 ;){
						IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, 3);
						if (IORD_16DIRECT(SDRAM_TRI_CONTROLLER_0_BASE, i) != 0x0000){
							read_status++;
						}
						i = i + 2;

					}
					// Write on pio to signalize finish, if no error, green led
					IOWR_ALTERA_AVALON_PIO_DATA(RETURN_NIOS_BASE, read_status);
					IOWR_ALTERA_AVALON_PIO_DATA(JTAG_TO_NIOS_BASE, 0x00);
					data_jtag = 0;

					
					break;	
					break;

			}
	
	}
	return 0;
}

