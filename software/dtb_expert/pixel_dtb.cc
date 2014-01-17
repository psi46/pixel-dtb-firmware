// pixel_dtb.cpp

#include "dtb_hal.h"
#include "pixel_dtb.h"
#include "dtb_config.h"
#include "rpc.h"
#include "SRecordReader.h"


const int delayAdjust = 4;
const int deserAdjust = 4;

// === DTB identification ===================================================

uint16_t CTestboard::GetRpcVersion()
{
	return rpc_GetRpcVersion();
}


int32_t  CTestboard::GetRpcCallId(string &cmdName)
{
	return rpc_GetRpcCallId(cmdName);
}


void CTestboard::GetRpcTimestamp(stringR &t)
{
	t = rpc_timestamp;
}


int32_t CTestboard::GetRpcCallCount()
{
	return rpc_cmdListSize;
}


bool CTestboard::GetRpcCallName(int32_t id, stringR &callName)
{
	if (id < 0 || id >= rpc_cmdListSize)
	{
		callName.clear();
		return false;
	}
	callName = rpc_cmdlist[id].name;
	return true;
}


#define CLINE(text) text "\n"

void CTestboard::GetInfo(stringR &info)
{
	int fw = fw_version;
	int sw = sw_version;
	char s[256];
	snprintf(s,   255, "Board id:    %i\n", dtbConfig.board);	info = s;
	snprintf(s,   255, "HW version:  %s\n", dtbConfig.hw_version.c_str()); info += s;
	snprintf(s,   255, "FW version:  %i.%i\n", fw/256, fw & 0xff); info += s;
	snprintf(s,   255, "SW version:  %i.%i\n", sw/256, sw & 0xff); info += s;
	snprintf(s,   255, "USB id:      %s\n", dtbConfig.usb_id.c_str()); info += s;
	snprintf(s,   255, "MAC address: %012llX\n", dtbConfig.mac_address); info += s;
	snprintf(s,   255, "Hostname:    %s\n", dtbConfig.hostname.c_str()); info += s;
	snprintf(s,   255, "Comment:     %s\n", dtbConfig.comment.c_str()); info += s;
}

uint16_t CTestboard::GetBoardId()
{
	return dtbConfig.board;
}


void CTestboard::GetHWVersion(stringR &version)
{
	version = dtbConfig.hw_version;
}


uint16_t CTestboard::GetFWVersion()
{
	return fw_version;
}


uint16_t CTestboard::GetSWVersion()
{
	return sw_version;
}




// === service ==============================================================

void CTestboard::Welcome()
{
	_SetLED(0x01);	mDelay(60);
	_SetLED(0x02);	mDelay(60);
	_SetLED(0x08);	mDelay(60);
	_SetLED(0x04);	mDelay(60);

	_SetLED(0x01);	mDelay(60);
	_SetLED(0x02);	mDelay(60);
	_SetLED(0x08);	mDelay(60);
	_SetLED(0x04);	mDelay(60);

	_SetLED(0x01);	mDelay(60);
	_SetLED(0x03);	mDelay(60);
	_SetLED(0x0b);	mDelay(60);
	_SetLED(0x0f);	mDelay(200);
	_SetLED(0x00);
}

void CTestboard::SetLed(uint8_t x)
{
	_SetLED(x);
}


const uint16_t CTestboard::flashUpgradeVersion = 0x0100;


uint16_t CTestboard::UpgradeGetVersion()
{
	return flashUpgradeVersion;
}


uint8_t CTestboard::UpgradeStart(uint16_t version)
{
	if (version != flashUpgradeVersion) THROW_UGR(ERR_VERSION, flash_error.GetErrorNr());
	flash_error.Reset();
	flashMem = new CFlashMemory();
	flashMem->Assign(2097152); // 2 MB (EPCS16)
	ugRecordCounter = 0;
	return flash_error.GetErrorNr();
}


uint8_t CTestboard::UpgradeData(string &record)
{
	if (!flashMem) THROW_UGR(ERR_MEMASSIGN, flash_error.GetErrorNr());
	CSRecordReader rec;
	rec.Translate(record.data(), *flashMem);
	if (IS_ERROR_UG) { delete flashMem; flashMem = 0; }
	ugRecordCounter++;
	return flash_error.GetErrorNr();
}


uint8_t CTestboard::UpgradeError()
{
	return flash_error.GetErrorNr();
}


void CTestboard::UpgradeErrorMsg(stringR &msg)
{
	msg = flash_error.GetErrorMsg();
}


void CTestboard::UpgradeExec(uint16_t recordCount)
{
	if (!flashMem) THROW_UG(ERR_MEMASSIGN);
	if (ugRecordCounter != recordCount) THROW_UG(ERR_RECCOUNT);
	SetLed(15);
	flashMem->WriteFlash();
	SetLed(0);
}


// === DTB initialization ===================================================

CTestboard::CTestboard()
{
	rpc_io = &usb; // USB default interface
	flashMem = 0;  // no memory assigned for upgrade

	for (unsigned int i=0; i<8; i++)
	{
		daq_mem_base[i] = 0;
		daq_mem_size[i] = 0;
	}

	// stop all DMA channels
	DAQ_WRITE(DAQ_DMA_0_BASE, DAQ_CONTROL, 0);
	DAQ_WRITE(DAQ_DMA_1_BASE, DAQ_CONTROL, 0);
	DAQ_WRITE(DAQ_DMA_2_BASE, DAQ_CONTROL, 0);
	DAQ_WRITE(DAQ_DMA_3_BASE, DAQ_CONTROL, 0);
	DAQ_WRITE(DAQ_DMA_4_BASE, DAQ_CONTROL, 0);
	DAQ_WRITE(DAQ_DMA_5_BASE, DAQ_CONTROL, 0);
	DAQ_WRITE(DAQ_DMA_6_BASE, DAQ_CONTROL, 0);
	DAQ_WRITE(DAQ_DMA_7_BASE, DAQ_CONTROL, 0);

	Init();
}

void CTestboard::Init()
{
	// delete assigned memory for flash upgrade
	if (flashMem) { delete flashMem; flashMem = 0; }

	// stop pattern generator
	Pg_Stop();
	Pg_SetCmd(0, 0);

	// --- shutdown DAQ ---------------------------------
	// close all open DAQ channels
	Daq_Close(0);
	Daq_Close(1);
	Daq_Close(2);
	Daq_Close(3);
	Daq_Close(4);
	Daq_Close(5);
	Daq_Close(6);
	Daq_Close(7);
	Daq_DeselectAll();


	ChipId  = 0;
	TBM_present = false;
	MOD_present = false;
	HUB_address = 0;

	currentClock = MHZ_40;
	SetClock_(MHZ_1_25);
	SetClockStretch(0,0,0);

	// --- clear main control register
	mainCtrl = 0;
	_MainControl(0);


	isPowerOn = false;

	// --- signal settings
	sig_level_clk = 5;
	sig_level_ctr = 5;
	sig_level_sda = 5;
	sig_level_tin = 5;
	sig_offset    = 8;
	Sig_Off();
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x40); // tout ena
	while(IORD_8DIRECT(LCDS_IO_BASE, 0));

	Sig_SetDelay(SIG_CLK, 0, 0);
	Sig_SetDelay(SIG_CTR, 0, 0);
	Sig_SetDelay(SIG_SDA, 0, 0);
	Sig_SetDelay(SIG_TIN, 0, 0);

	Sig_SetMode(SIG_CLK, SIG_MODE_NORMAL);
	Sig_SetMode(SIG_CTR, SIG_MODE_NORMAL);
	Sig_SetMode(SIG_SDA, SIG_MODE_NORMAL);
	Sig_SetMode(SIG_TIN, SIG_MODE_NORMAL);

	// --- signal probe
	SignalProbeD1(PROBE_OFF);
	SignalProbeD2(PROBE_OFF);

	Adv3224Init();

	// --- switch all LEDs off
	_SetLED(0x00);

	// --- setup I2C master controller
	I2C_Main_Init();

	// --- default VD, VA settings
	vd = mV_to_DAC(2500);    // mV
	id = uA100_to_DAC(3000); // *100 uA
	va = mV_to_DAC(1500);    // mV
	ia = uA100_to_DAC(3000); // *100 uA
	InitDac();
	Poff();

	roc_pixeladdress_inverted = false;
}


// === timing ===============================================================

void CTestboard::cDelay(uint16_t clocks)
{
	uint16_t us = clocks / 40;
	if (us == 0) us = 1;
	uDelay(us);
}

void CTestboard::uDelay(uint16_t us)
{
	usleep(us);
}

void CTestboard::mDelay(uint16_t ms)
{
	uint16_t i;
	for (i=0; i<ms; i++) usleep(1000);
}


void CTestboard::SetClockSource(uint8_t source)
{
	if (source > 1) return;

	if (source == 1) mainCtrl |= MAINCTRL_CLK_EXT;
	else mainCtrl &= ~MAINCTRL_CLK_EXT;

	_MainControl(mainCtrl | MAINCTRL_PLL_RESET);
	uDelay(10);
	_MainControl(mainCtrl);
	uDelay(100);
}

bool CTestboard::IsClockPresent()
{
	return _MainStatus() | MAINSTATUS_CLK_PRESENT;
}


void CTestboard::SetClock_(unsigned char MHz)
{
	SetClkDiv(((MHz & 7)<<3) + (MHz & 7));
}


void CTestboard::SetClock(unsigned char MHz)
{
	currentClock = MHz;
	if (isPowerOn) SetClock_(currentClock);
}


RPC_EXPORT void CTestboard::SetClockStretch(uint8_t src,
	uint16_t delay, uint16_t width)
{
	  if (width > 0)
	  {
	    SetClockStretchReg(0, src|0x04);

	    if (delay > 1022) delay = 1022;
	    delay++;
	    SetClockStretchReg(1, delay);

	    SetClockStretchReg(2, width);
	  }
	  else
	  {
	    SetClockStretchReg(0,0);
	    SetClockStretchReg(1,1);
	    SetClockStretchReg(2,1);
	  }
}


// === Signal Delay =========================================================

const unsigned short delayConv[] =
{
	0x0000,	0x0001,	0x0002,	0x0003,	0x0006,	0x0007,	0x000e,	0x000f,
	0x001e,	0x001f,	0x003e,	0x003f,	0x007e,	0x007f,	0x00fe,	0x00ff,
	0x01fe,	0x01ff,	0x03fe,	0x03ff,	0x07fe,	0x07ff,	0x0ffe,	0x0fff,
	0x1ffe,	0x1fff
};


void CTestboard::Sig_SetDelay(uint8_t signal, uint16_t delay, int8_t duty)
{
	short *sig;
	switch (signal)
	{
		case SIG_CLK: sig = (short*)DELAY_CLK_BASE; break;
		case SIG_CTR: sig = (short*)DELAY_CTR_BASE; break;
		case SIG_SDA: sig = (short*)DELAY_SDA_BASE; break;
		case SIG_TIN: sig = (short*)DELAY_TIN_BASE; break;
		default: return;
	}

	if (delay > 300) delay = 300;
	if (duty < -8) duty = -8; else if (duty > 8) duty = 8;

	int16_t delayC = delay / 10;
	int16_t delayR = (delay % 10) + 8;
	int16_t delayF = delayR + duty;
	IOWR_16DIRECT(sig, 0, delayConv[delayF]);
	IOWR_16DIRECT(sig, 2, delayConv[delayR]);
	IOWR_16DIRECT(sig, 4, delayC);
	IOWR_16DIRECT(sig, 6,  0);
}

void CTestboard::Sig_SetMode(uint8_t signal, uint8_t mode)
{
	short *sig;
	switch (signal)
	{
		case SIG_CLK: sig = (short*)DELAY_CLK_BASE; break;
		case SIG_CTR: sig = (short*)DELAY_CTR_BASE; break;
		case SIG_SDA: sig = (short*)DELAY_SDA_BASE; break;
		case SIG_TIN: sig = (short*)DELAY_TIN_BASE; break;
		default: return;
	}

	switch (mode)
	{
		case 0: IOWR_16DIRECT(sig, 6, 0); break;
		case 1: IOWR_16DIRECT(sig, 6, 1); break;
		case 2: IOWR_16DIRECT(sig, 6, 3); break;
	}
}

void CTestboard::Sig_SetPRBS(uint8_t signal, uint8_t speed)
{
	short *sig;
	switch (signal)
	{
		case SIG_CLK: sig = (short*)DELAY_CLK_BASE; break;
		case SIG_CTR: sig = (short*)DELAY_CTR_BASE; break;
		case SIG_SDA: sig = (short*)DELAY_SDA_BASE; break;
		case SIG_TIN: sig = (short*)DELAY_TIN_BASE; break;
		default: return;
	}
	IOWR_16DIRECT(sig, 6, (speed & 0x1f)<<2 | 0x80);
}

/*
	LVDS2LCDS Chip DACs:
	0  Bit 3..0: CLK amplitude
	1  Bit 3..0: CTR amplitude
	2  Bit 3..0: SDA amplitude
	3  Bit 3..0: TIN amplitude
	4  Bit    0: TIN LVDS select
	5  Bit 3..0: signal offset for CLK, CTR, SDA, TIN
*/
void CTestboard::Sig_SetLevel(uint8_t signal, uint8_t level)
{
	if (level > 15) level = 15;

	unsigned char dac;
	switch (signal)
	{
		case SIG_CLK: sig_level_clk = level; dac = 0x00; break;
		case SIG_CTR: sig_level_ctr = level; dac = 0x10; break;
		case SIG_SDA: sig_level_sda = level; dac = 0x20; break;
		case SIG_TIN: sig_level_tin = level; dac = 0x30; break;
		default: return;
	}
	if (isPowerOn)
	{
		IOWR_8DIRECT(LCDS_IO_BASE, 0, dac + level);
		while(IORD_8DIRECT(LCDS_IO_BASE, 0));
	}
}

void CTestboard::Sig_SetOffset(uint8_t offset)
{
	if (offset > 15) offset = 15;
	sig_offset = offset;
	if (isPowerOn)
	{
		IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x50 + offset);
		while(IORD_8DIRECT(LCDS_IO_BASE, 0));
	}
}


void CTestboard::Sig_Off()
{
	// configure lvds2lcds
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x00); // clk
	while(IORD_8DIRECT(LCDS_IO_BASE, 0));
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x10); // ctr
	while(IORD_8DIRECT(LCDS_IO_BASE, 0));
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x20); // sda
	while(IORD_8DIRECT(LCDS_IO_BASE, 0));
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x30); // tin
	while(IORD_8DIRECT(LCDS_IO_BASE, 0));
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x50); // offset
	while(IORD_8DIRECT(LCDS_IO_BASE, 0));
}

void CTestboard::Sig_Restore()
{
	// configure lvds2lcds
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x00 + sig_level_clk); // clk
	while(IORD_8DIRECT(LCDS_IO_BASE, 0));
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x10 + sig_level_ctr); // ctr
	while(IORD_8DIRECT(LCDS_IO_BASE, 0));
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x20 + sig_level_sda); // sda
	while(IORD_8DIRECT(LCDS_IO_BASE, 0));
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x30 + sig_level_tin); // tin
	while(IORD_8DIRECT(LCDS_IO_BASE, 0));
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x50 + sig_offset); // offset
	while(IORD_8DIRECT(LCDS_IO_BASE, 0));
}


void CTestboard::Sig_SetLVDS()
{
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x41);
}

void CTestboard::Sig_SetLCDS()
{
	IOWR_8DIRECT(LCDS_IO_BASE, 0, 0x40);
}


// === VD/VA power supply control ===========================================

// DAC calibration
#define DAC_V0   625	// DAC value for V = 0
#define DAC_VS  5103  // DAC voltage scale factor

#define DAC_I0     0  // DAC value for I = 0
#define DAC_IS  1030  // DAC current scale factor

// ADC calibration
#define ADC_uV  1007  // ADC voltage step [uV]
#define ADC_uA   804  // ADC current step [uA]


void CTestboard::Pon()
{
	SetClock_(currentClock);
	if (isPowerOn) return;

	SetDac(0, 184);	// va = 1V;
	SetDac(2, 184);	// vd = 1V;

	mainCtrl |= MAINCTRL_PWR_ON;
	if (daq_select_adc) mainCtrl |= MAINCTRL_ADCENA;
	_MainControl(mainCtrl);
	isPowerOn = true;

	SetDac(1, ia);
	SetDac(0, va);
	SetDac(3, id);
	SetDac(2, vd);

	Sig_Restore();
}


void CTestboard::Poff()
{
	Sig_Off();

	SetDac(0, 184);	// va = 1V;
	SetDac(2, 184);	// vd = 1V;
	mainCtrl &= ~(MAINCTRL_PWR_ON | MAINCTRL_ADCENA);
	_MainControl(mainCtrl);
	isPowerOn = false;

	Daq_Close(0);
	Daq_Close(1);
	Daq_Close(2);
	Daq_Close(3);
	Daq_Close(4);
	Daq_Close(5);
	Daq_Close(6);
	Daq_Close(7);

	SetClock_(MHZ_1_25);
}


void CTestboard::_SetVD(uint16_t mV)
{
    vd = mV_to_DAC(mV);
    if (isPowerOn) SetDac(2,vd);
}


void CTestboard::_SetVA(uint16_t mV)
{
  	va = mV_to_DAC(mV);
	if (isPowerOn) SetDac(0,va);
}


uint16_t CTestboard::_GetVD()
{
	return ADC_to_mV(ReadADC(2));
}


uint16_t CTestboard::_GetVA()
{
	return ADC_to_mV(ReadADC(0));
}


void CTestboard::_SetID(uint16_t uA100)
{
    id = uA100_to_DAC(uA100);
    if (isPowerOn) SetDac(3,id);
}


void CTestboard::_SetIA(uint16_t uA100)
{
    ia = uA100_to_DAC(uA100);
    if (isPowerOn) SetDac(1,ia);
}


uint16_t CTestboard::_GetID()	// get VD current in 100 uA
{
  return ADC_to_uA100(ReadADC(3));
}


uint16_t CTestboard::_GetIA()	// get VA current in 100 uA
{
  return ADC_to_uA100(ReadADC(1));
}

unsigned int CTestboard::mV_to_DAC(int mV)
{
	if (mV > 4000) mV = 4000; else if (mV < 0) mV = 0;
	long dac = (752817-229*(long)mV)/3333;
	if (dac>1023) dac = 1023; else if (dac<0) dac = 0;
	return (unsigned int)dac;
}


unsigned int CTestboard::uA100_to_DAC(int ua100)
{
	if (ua100 > 12000) ua100 = 12000; else if (ua100 < 0) ua100 = 0;
	unsigned long dac = (105*(unsigned long)ua100)/3300;
	if (dac>1023) dac = 1023; else if (dac<0) dac = 0;
	return (unsigned int)dac;
}


int CTestboard::ADC_to_mV(unsigned int dac)
{
	return (dac*ADC_uV)/1000;
}


int CTestboard::ADC_to_uA100(unsigned int dac)
{
	return (dac*ADC_uA)/100;
}


void CTestboard::InitDac()
{
	int res;
	// --- 0111100(0) 1 11110000 1 00111100

	// send slave address 0x3c
	IOWR_8DIRECT(I2C_MAIN_BASE, TXR, 0x78);
	IOWR_8DIRECT(I2C_MAIN_BASE, CR,  STA|WR);
	while ((res = IORD_8DIRECT(I2C_MAIN_BASE, SR)) & TIP);

    // switch to extended command
	IOWR_8DIRECT(I2C_MAIN_BASE, TXR, 0xf0);
	IOWR_8DIRECT(I2C_MAIN_BASE, CR,  WR);
	while ((res = IORD_8DIRECT(I2C_MAIN_BASE, SR)) & TIP);

    // all channels power up
	IOWR_8DIRECT(I2C_MAIN_BASE, TXR, 0x3c);
	IOWR_8DIRECT(I2C_MAIN_BASE, CR,  WR|STO);
	while ((res = IORD_8DIRECT(I2C_MAIN_BASE, SR)) & TIP);
}


void CTestboard::SetDac(int addr, int value)
{
	int res;
	value &= 0x3ff;

	// send slave address 0x3d
	IOWR_8DIRECT(I2C_MAIN_BASE, TXR, 0x78);
	IOWR_8DIRECT(I2C_MAIN_BASE, CR,  STA|WR);
	while ((res = IORD_8DIRECT(I2C_MAIN_BASE, SR)) & TIP);

	// load dac addr and data D9...D6
	IOWR_8DIRECT(I2C_MAIN_BASE, TXR, ((addr&3)<<4) | (value>>6));
	IOWR_8DIRECT(I2C_MAIN_BASE, CR,  WR);
	while ((res = IORD_8DIRECT(I2C_MAIN_BASE, SR)) & TIP);

	// send data D5...D0
	IOWR_8DIRECT(I2C_MAIN_BASE, TXR, value <<2);
	IOWR_8DIRECT(I2C_MAIN_BASE, CR,  WR|STO);
	while ((res = IORD_8DIRECT(I2C_MAIN_BASE, SR)) & TIP);
}


unsigned int CTestboard::ReadADC(unsigned char addr)
{
	int res;
	// send slave address 0x35
	IOWR_8DIRECT(I2C_MAIN_BASE, TXR, 0x6a);
	IOWR_8DIRECT(I2C_MAIN_BASE, CR,  STA|WR);
	while ((res = IORD_8DIRECT(I2C_MAIN_BASE, SR)) & TIP);

	// setup 11010010: internal reference, internal clock, unipolar
	IOWR_8DIRECT(I2C_MAIN_BASE, TXR, 0xd2);
	IOWR_8DIRECT(I2C_MAIN_BASE, CR,  WR);
	while ((res = IORD_8DIRECT(I2C_MAIN_BASE, SR)) & TIP);

	// configuration 011aaaa1: single channel addr, single ended
	IOWR_8DIRECT(I2C_MAIN_BASE, TXR, 0x61|((addr&0x0f)<<1));
	IOWR_8DIRECT(I2C_MAIN_BASE, CR,  WR);
	while ((res = IORD_8DIRECT(I2C_MAIN_BASE, SR)) & TIP);

	// send slave address 0x35 (read)
	IOWR_8DIRECT(I2C_MAIN_BASE, TXR, 0x6b);
	IOWR_8DIRECT(I2C_MAIN_BASE, CR,  STA|WR);
	while ((res = IORD_8DIRECT(I2C_MAIN_BASE, SR)) & TIP);

	// read D11...D8
	IOWR_8DIRECT(I2C_MAIN_BASE, CR,  RD);
	while ((res = IORD_8DIRECT(I2C_MAIN_BASE, SR)) & TIP);
	unsigned int value = IORD_8DIRECT(I2C_MAIN_BASE, RXR) & 0x0f;

	// read D7...D0
	IOWR_8DIRECT(I2C_MAIN_BASE, CR,  RD|ACK|STO);
	while ((res = IORD_8DIRECT(I2C_MAIN_BASE, SR)) & TIP);
	value = (value << 8) | IORD_8DIRECT(I2C_MAIN_BASE, RXR);

	return value;
}


void CTestboard::HVon()
{
	mainCtrl |= MAINCTRL_HV_ON;
	_MainControl(mainCtrl);
}


void CTestboard::HVoff()
{
	mainCtrl &= ~MAINCTRL_HV_ON;
	_MainControl(mainCtrl);
}


void CTestboard::ResetOn()
{
	mainCtrl |= MAINCTRL_DUT_nRES;
	_MainControl(mainCtrl);
}


void CTestboard::ResetOff()
{
	mainCtrl &= ~MAINCTRL_DUT_nRES;
	_MainControl(mainCtrl);
}

uint8_t CTestboard::GetStatus()
{
	return _MainStatus();
}

void CTestboard::SetRocAddress(uint8_t addr)
{
	IOWR_ALTERA_AVALON_PIO_DATA(ROC_ADDR_BASE, addr);
}

// === digital signal probe =================================================

void CTestboard::SignalProbeD1(uint8_t signal)
{
	_Probe1(signal);
}


void CTestboard::SignalProbeD2(uint8_t signal)
{
	_Probe2(signal);
}


// === analog signal probe =============================================

void CTestboard::SignalProbeA1(uint8_t signal)
{
	uint8_t sig = signal << 1;

	uint16_t delay = 200;
	while (IORD(CROSSPOINT_SWITCH_BASE, 0) & 1)
	{
		uDelay(1);
		if (--delay == 0) return;
	}

	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 4, sig);   // A1+
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 5, sig+1); // A1-
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 0, 0xFF);
}


void CTestboard::SignalProbeA2(uint8_t signal)
{
	uint8_t sig = signal << 1;

	uint16_t delay = 200;
	while (IORD(CROSSPOINT_SWITCH_BASE, 0) & 1)
	{
		uDelay(1);
		if (--delay == 0) return;
	}

	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 6, sig);   // A2+
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 7, sig+1); // A2-
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 0, 0xFF);
}


void CTestboard::SignalProbeADC(uint8_t signal, uint8_t gain)
{
	if (signal >= 8) return;
	if (gain > 3) gain = 3;
	uint8_t sig = signal << 1;

	uint16_t delay = 200;
	while (IORD(CROSSPOINT_SWITCH_BASE, 0) & 1)
	{
		uDelay(1);
		if (--delay == 0) return;
	}

	switch (gain)
	{
	case 0: // x1
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 0, 16);    // ADC+ (x3)
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 1, 16);    // ADC- (x3)
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 2, sig+1); // ADC+ (x1)
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 3, sig);   // ADC- (x1)
		break;
	case 1: // x2
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 0, sig+1); // ADC+ (x3)
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 1, sig);   // ADC- (x3)
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 2, sig);   // ADC+ (x1)
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 3, sig+1); // ADC- (x1)
		break;
	case 2: // x3
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 0, sig+1); // ADC+ (x3)
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 1, sig);   // ADC- (x3)
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 2, 16);    // ADC+ (x1)
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 3, 16);    // ADC- (x1)
		break;
	case 3: // x4
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 0, sig+1); // ADC+ (x3)
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 1, sig);   // ADC- (x3)
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 2, sig+1); // ADC+ (x1)
		IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 3, sig);   // ADC- (x1)
		break;
	}
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 0, 0xFF);
}


// == pulse pattern generator ===========================================

void CTestboard::Pg_SetCmd(unsigned short addr, unsigned short cmd)
{
	if (addr < 256)	IOWR_16DIRECT(PATTERNGEN_DATA_BASE, 2*addr, cmd);
}

/*
void CTestboard::pg_SetCmdAll(vector<uint16_t> &cmd)
{
	if (count > 255) return;
	unsigned short i;
	for (i=0; i<count; i++) IOWR_16DIRECT(PATTERNGEN_DATA_BASE, 2*i, cmd[i]);
}
*/

void CTestboard::Pg_Stop()
{
	IOWR_32DIRECT(PATTERNGEN_CTRL_BASE, 0, 0x00);
}


void CTestboard::Pg_Single()
{
	IOWR_32DIRECT(PATTERNGEN_CTRL_BASE, 0, 0x00);
	IOWR_32DIRECT(PATTERNGEN_CTRL_BASE, 0, 0x81);
}


void CTestboard::Pg_Trigger()
{
	IOWR_32DIRECT(PATTERNGEN_CTRL_BASE, 0, 0x00);
	IOWR_32DIRECT(PATTERNGEN_CTRL_BASE, 0, 0x82);
}


void CTestboard::Pg_Loop(unsigned short period)
{
	IOWR_32DIRECT(PATTERNGEN_CTRL_BASE, 0, 0x00);
	IOWR_32DIRECT(PATTERNGEN_CTRL_BASE, 4, period);
	IOWR_32DIRECT(PATTERNGEN_CTRL_BASE, 0, 0x84);
}



// === ROC/Module Communication =========================================

// --- ROC functions ----------------------------------------------------

const unsigned char CTestboard::MODCONF[16]
= { 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3 };


// -- set the i2c address for the following commands
void CTestboard::roc_I2cAddr(uint8_t id)
{
	ChipId = id & 0x0f;
	ChipId = id << 4;
	if (MOD_present) HUB_address = (HUB_address & 0xf8) + MODCONF[id];
}


// -- sends "ClrCal" command to ROC
void CTestboard::roc_ClrCal()
{
	while (GetI2cHs(0) & 1);
	if (TBM_present) SetI2cHs(3, HUB_address);
	SetI2cHs(5, 0x01 + ChipId);
	SetI2cHs(1, 0);
	SetI2cHs(0, TBM_present?3:1);
}


// -- sets a single (DAC) register
void CTestboard::roc_SetDAC(uint8_t reg, uint8_t value)
{
	while (GetI2cHs(0) & 1);
	if (TBM_present) SetI2cHs(3, HUB_address);
	SetI2cHs(3, 0x08 + ChipId);
	SetI2cHs(2, reg);
	SetI2cHs(4, value);
	SetI2cHs(1, 0);
	SetI2cHs(0, TBM_present?3:1);
}


// -- set pixel bits (count <= 60)
//    M - - - 8 4 2 1
void CTestboard::roc_Pix(uint8_t col, uint8_t row, uint8_t value)
{
	while (GetI2cHs(0) & 1);
	if (TBM_present) SetI2cHs(3, HUB_address);
	SetI2cHs(3, 0x04 + ChipId);
	SetI2cHs(2, COLCODE(col));
	SetI2cHs(2, ROWCODE(row));
	SetI2cHs(4, value & 0x8f);
	SetI2cHs(1, 0);
	SetI2cHs(0, TBM_present?3:1);
}


// -- trimm a single pixel (count < =60)
void CTestboard::roc_Pix_Trim(uint8_t col, uint8_t row, uint8_t value)
{
	while (GetI2cHs(0) & 1);
	if (TBM_present) SetI2cHs(3, HUB_address);
	SetI2cHs(3, 0x04 + ChipId);
	SetI2cHs(2, COLCODE(col));
	SetI2cHs(2, ROWCODE(row));
	SetI2cHs(4, (value & 0x0f) | 0x80);
	SetI2cHs(1, 0);
	SetI2cHs(0, TBM_present?3:1);
}


// -- mask a single pixel (count <= 60)
void CTestboard::roc_Pix_Mask(uint8_t col, uint8_t row)
{
	while (GetI2cHs(0) & 1);
	if (TBM_present) SetI2cHs(3, HUB_address);
	SetI2cHs(3, 0x04 + ChipId);
	SetI2cHs(2, COLCODE(col));
	SetI2cHs(2, ROWCODE(row));
	SetI2cHs(4, 0x0f);
	SetI2cHs(1, 0);
	SetI2cHs(0, TBM_present?3:1);
}


// -- set calibrate at specific column and row
void CTestboard::roc_Pix_Cal(uint8_t col, uint8_t row, bool sensor_cal)
{
	while (GetI2cHs(0) & 1);
	if (TBM_present) SetI2cHs(3, HUB_address);
	SetI2cHs(3, 0x02 + ChipId);
	SetI2cHs(2, COLCODE(col));
	SetI2cHs(2, ROWCODE(row));
	SetI2cHs(4, 0x01);
	SetI2cHs(1, 0);
	SetI2cHs(0, TBM_present?3:1);

	if (sensor_cal)
	{
		while (GetI2cHs(0) & 1);
		if (TBM_present) SetI2cHs(3, HUB_address);
		SetI2cHs(3, 0x02 + ChipId);
		SetI2cHs(2, COLCODE(col));
		SetI2cHs(2, ROWCODE(row));
		SetI2cHs(4, 0x02);
		SetI2cHs(1, 0);
		SetI2cHs(0, TBM_present?3:1);
	}
}


// -- enable/disable a double column
void CTestboard::roc_Col_Enable(uint8_t col, bool on)
{
	while (GetI2cHs(0) & 1);
	if (TBM_present) SetI2cHs(3, HUB_address);
	SetI2cHs(3, 0x04 + ChipId);
	SetI2cHs(2, COLCODE(col) & 0xfe);
	SetI2cHs(2, 0x40);
	SetI2cHs(4, on ? 0x80 : 0x00);
	SetI2cHs(1, 0);
	SetI2cHs(0, TBM_present?3:1);
}


// -- mask all pixels of a column and the coresponding double column
void CTestboard::roc_Col_Mask(uint8_t col)
{
	int row;
	roc_Col_Enable(col,false);
	for (row=0; row<ROC_NUMROWS; row++) { roc_Pix_Mask(col, row); }
}


// -- mask all pixels and columns of the chip
void CTestboard::roc_Chip_Mask()
{
	int row, col;

	for (col=0; col<ROC_NUMCOLS; col+=2)
	{ roc_Col_Enable(col,false); cDelay(5); }

	for (col=0; col<ROC_NUMCOLS; col++)
		for (row=0; row<ROC_NUMROWS; row++)
		{ roc_Pix_Mask(col, row);  cDelay(5); }
}

// -- TBM functions --
// selects if you want to use the TBM
// Note: MOD_present is used for automatic address assignment. Works with standard BPix modules only
bool CTestboard::TBM_Present()
{
	return TBM_present;
}

void CTestboard::tbm_Enable(bool on)
{
        TBM_present = on;
        if (!TBM_present) MOD_present = 0;
}


void CTestboard::tbm_Addr(uint8_t hub, uint8_t port)
{
        MOD_present = false;
        HUB_address = ((hub & 0x1f)<<3) + (port & 0x07);
}


void CTestboard::mod_Addr(uint8_t hub)
{
        MOD_present = true;
        HUB_address = ((hub & 0x1f)<<3);
}


void CTestboard::tbm_Set(uint8_t reg, uint8_t value)
{
        if (!TBM_present) return;

        while (GetI2cHs(0) & 1);
        SetI2cHs(3, (HUB_address & (0x1f<<3)) + 4); // 4 is the TBM address
        SetI2cHs(3, reg);
        SetI2cHs(4, value);
        SetI2cHs(0, 3);
}

bool CTestboard::tbm_GetRaw(uint8_t reg, uint32_t &value)
{
        if (!TBM_present) { value = -1; return false; }

        while (GetI2cHs(0) & 1);
        SetI2cHs(3, (HUB_address & (0x1f<<3)) + 4);
        SetI2cHs(3, reg | 1);
        SetI2cHs(4, 0x7ff);
        SetI2cHs(0, 3);

        short count = 0;
        cDelay(5);
        while ((GetI2cHs(0) & 1) && count<500) count++;
        value = GetI2cHs(1);

        return value >= 0;
}

bool CTestboard::tbm_Get(uint8_t reg, uint8_t &value)
{
        uint32_t x;
        reg |= 1;
        if (!tbm_GetRaw(reg, x)) return false;
        unsigned int y = (((HUB_address & (0x1f<<3)) + 4) << 8) + reg;
        if (((x>>8) & 0xffff) != y) return false;
        value = (unsigned char)(x & 0xff);
        return true;
}

// --- Data aquisition ------------------------------------------------------


uint32_t CTestboard::Daq_Open(uint32_t buffersize, uint8_t channel)
{
	if (channel >= 8) return 0;

	// close last DAQ session if still active
	Daq_Close(channel);

	// set size limits for memory allocation
	if (buffersize > 50000000) buffersize = 50000000;  // max 50 Mio samples
	if (buffersize < 8192) buffersize = 8192;  // min 8192 samples

	// allocate memory
	daq_mem_base[channel] = new uint16_t[buffersize];
	if (daq_mem_base[channel] == 0) return 0;
	daq_mem_size[channel] = buffersize;

	// set DMA to allocated memory
	unsigned int daq_base = DAQ_DMA_BASE[channel];
	DAQ_WRITE(daq_base, DAQ_MEM_BASE, (unsigned long)(daq_mem_base[channel]));
	DAQ_WRITE(daq_base, DAQ_MEM_SIZE, daq_mem_size[channel]);

	return daq_mem_size[channel];
}

void CTestboard::Daq_Close(uint8_t channel)
{
	if (channel >= 8) return;

	if (daq_mem_base[channel])
	{
		Daq_Stop(channel);
		IOWR_ALTERA_AVALON_PIO_DATA(DESER160_BASE, 0); // FIFO reset
		uDelay(1);
		delete[] daq_mem_base[channel];
		daq_mem_base[channel] = 0;
	}
}

void CTestboard::Daq_Start(uint8_t channel)
{
	if (channel >= 8) return;

	if (daq_mem_base[channel])
	{
		// clear buffer and enable daq
		unsigned int daq_base = DAQ_DMA_BASE[channel];
		DAQ_WRITE(daq_base, DAQ_CONTROL, 1);

		// switch on data sources
//		IOWR_ALTERA_AVALON_PIO_DATA(ADC_BASE, daq_adc_state);
//		IOWR_ALTERA_AVALON_PIO_DATA(DESER160_BASE, daq_deser160_state);
	}
}


void CTestboard::Daq_Stop(uint8_t channel)
{
	if (channel >= 8) return;

	if (daq_mem_base[channel])
	{
		// switch of data sources
//		IOWR_ALTERA_AVALON_PIO_DATA(ADC_BASE, 0);
//		IOWR_ALTERA_AVALON_PIO_DATA(DESER160_BASE, 0);

		// stop daq
		unsigned int daq_base = DAQ_DMA_BASE[channel];
		DAQ_WRITE(daq_base, DAQ_CONTROL, 0);
	}
}


uint32_t CTestboard::Daq_GetSize(uint8_t channel)
{
	if (channel >= 8) return 0;

	if (daq_mem_base[channel] == 0) return 0;

	// read dma status
	unsigned int daq_base = DAQ_DMA_BASE[channel];
	int32_t status = DAQ_READ(daq_base, DAQ_CONTROL);
	int32_t rp = DAQ_READ(daq_base, DAQ_MEM_READ);
	int32_t wp = DAQ_READ(daq_base, DAQ_MEM_WRITE);

	// correct write pointer overrun at memory overflow
	if (status & DAQ_MEM_OVFL) if (--wp < 0) wp += daq_mem_size[channel];

	// calculate available words in memory (-> fifosize)
	int32_t diff = wp - rp;
	int32_t fifosize = diff;
	if (fifosize < 0) fifosize += daq_mem_size[channel];

	return fifosize;
}

template <class T>
inline T* Uncache(T *x) { return (T*)(((unsigned long)x) | 0x80000000); }

uint8_t CTestboard::Daq_Read(vectorR<uint16_t> &data,
		 uint16_t blocksize, uint8_t channel)
{
	uint32_t availsize;
	return Daq_Read(data, blocksize, availsize, channel);
}


uint8_t CTestboard::Daq_Read(vectorR<uint16_t> &data,
		uint16_t blocksize, uint32_t &availsize, uint8_t channel)
{
	data.clear();

	if (channel >= 8) return 0;

	if (daq_mem_base[channel] == 0) { availsize = 0; return 0; }

	// limit maximal block size
	if (blocksize > 32768) blocksize = 32768;
	if (blocksize > daq_mem_size[channel]) blocksize = daq_mem_size[channel];

	// read dma status
	unsigned int daq_base = DAQ_DMA_BASE[channel];
	int32_t status = DAQ_READ(daq_base, DAQ_CONTROL);
	int32_t rp = DAQ_READ(daq_base, DAQ_MEM_READ);
	int32_t wp = DAQ_READ(daq_base, DAQ_MEM_WRITE);

	// correct write pointer overrun at memory overflow
	if (status & DAQ_MEM_OVFL) if (--wp < 0) wp += daq_mem_size[channel];

	// calculate available words in memory (-> fifosize)
	int32_t fifosize = wp - rp;
	if (fifosize < 0) fifosize += daq_mem_size[channel];

	// calculate transfer block size (-> blocksize)
	if (blocksize > fifosize) blocksize = fifosize;

	// return remaining data size
	availsize = fifosize - blocksize;

	// allocate space in vector or return empty data
	if (blocksize > 0) data.reserve(blocksize);
	else return uint8_t(status);

	// --- send 1st part of the data block
	int32_t size1 = daq_mem_size[channel] - rp;
	if (size1 > blocksize) size1 = blocksize;

	// copy data to vector
	uint16_t *p = Uncache(daq_mem_base[channel]) + rp;
	data.insert(data.end(), p, p + size1);
	blocksize -= size1;

	// --- send 2ns part of the data block
	if (blocksize > 0)
	{
		p = Uncache(daq_mem_base[channel]);
		data.insert(data.end(), p, p + blocksize);
		rp = blocksize;
	}
	else rp += size1;

	// update read pointer
	DAQ_WRITE(daq_base, DAQ_MEM_READ, rp);

	return uint8_t(status);
}



void CTestboard::Daq_Select_ADC(uint16_t blocksize, uint8_t source, uint8_t start, uint8_t stop)
{
	if (blocksize < 2) blocksize = 2;
	else if (blocksize > 65534) blocksize = 65533;
	blocksize--;

	if (start > 63) start = 63;
	if (stop  > 63) stop  = 63;

	unsigned short s = start;
	unsigned short p = stop;
	switch (source)
	{
	case 0: // tin -> tout
		s |= 0xc000;
		p |= 0x4000;
		break;
	case 1: // trig1
		s |= 0x4000;
		break;
	case 2: // trig2
		s |= 0x8000;
		break;
	}

	// disable deser160
	daq_select_deser160 = false;
	IOWR_ALTERA_AVALON_PIO_DATA(DESER160_BASE, 0);

	// disable deser400
	daq_select_deser400 = false;
	_Deser400_Control(DESER400_RESET|DESER400_REG_RESET);

	// enable adc
	daq_select_adc = true;
	if (isPowerOn) mainCtrl |= MAINCTRL_ADCENA;
	_MainControl(mainCtrl);

	// config ADC
	ADC_WRITE(ADC_LEN, blocksize);
	ADC_WRITE(ADC_START, s);
	ADC_WRITE(ADC_STOP, p);
	ADC_WRITE(ADC_CTRL, 1);
}


void CTestboard::Daq_DeselectAll()
{
	// disable deser400
	daq_select_deser400 = false;
	_Deser400_Control(DESER400_RESET|DESER400_REG_RESET);

	// disable deser160
	daq_select_deser160 = false;
	IOWR_ALTERA_AVALON_PIO_DATA(DESER160_BASE, 0);

	// disable adc
	daq_select_adc = false;
	mainCtrl &= ~MAINCTRL_ADCENA;
	_MainControl(mainCtrl);
	ADC_WRITE(ADC_CTRL, 1);
}

void CTestboard::Daq_Select_Deser160(uint8_t shift)
{
	// disable deser400
	daq_select_deser400 = false;
	_Deser400_Control(DESER400_RESET|DESER400_REG_RESET);

	// disable adc
	daq_select_adc = false;
	mainCtrl &= ~MAINCTRL_ADCENA;
	_MainControl(mainCtrl);
	ADC_WRITE(ADC_CTRL, 1);

	// enable deser160
	daq_select_deser160 = true;
	IOWR_ALTERA_AVALON_PIO_DATA(DESER160_BASE, (shift & 0x7) | 0x8);
}

void CTestboard::Daq_Select_Deser400()
{
	// disable adc
	daq_select_adc = false;
	mainCtrl &= ~MAINCTRL_ADCENA;
	_MainControl(mainCtrl);
	ADC_WRITE(ADC_CTRL, 1);

	// disable deser160
	daq_select_deser160 = false;
	IOWR_ALTERA_AVALON_PIO_DATA(DESER160_BASE, 0);

	// enable deser400
	daq_select_deser400 = true;

	// reset deser400
	Daq_Deser400_Reset();
}

void CTestboard::Daq_Deser400_Reset(uint8_t reset)
{
	if (daq_select_deser400)
	{
		_Deser400_Control(DESER400_SEL_MOD0 | (reset & 3));
		uDelay(5);
		_Deser400_Control(DESER400_SEL_MOD0);
	}
}



// === high level test functions ============================================

int16_t CTestboard::DecodePixel(vector<uint16_t> &data, int16_t &pos, int16_t &n, int16_t &ph, int16_t &col, int16_t &row)
{ 
	unsigned int raw = 0;
	n = 0;

	// check header
	if (pos >= int(data.size())) return  -1; // missing data
	if ((data[pos] & 0x8ffc) != 0x87f8) return -2; // wrong header
//	int hdr = data[pos++] & 0xfff;

	if (pos >= int(data.size()) || (data[pos] & 0x8000)) return 0; // empty data readout

	// read first pixel
	raw = (data[pos++] & 0xfff) << 12;

	if (pos >= int(data.size()) || (data[pos] & 0x8000)) return -3; // incomplete data
	raw += data[pos++] & 0xfff;
	n++;


	// read additional noisy pixel
	int cnt = 0;
	while (!(pos >= int(data.size()) || (data[pos] & 0x8000))) { pos++; cnt++; }
	n += cnt / 2;


	ph = (raw & 0x0f) + ((raw >> 1) & 0xf0);
	raw >>= 9;
	int c =    (raw >> 12) & 7;
	c = c*6 + ((raw >>  9) & 7);

	int r2 =   (raw >> 6) & 7;
	if(roc_pixeladdress_inverted) r2 ^= 0x7;

	int r1 =   (raw >> 3) & 7;
	if(roc_pixeladdress_inverted) r1 ^= 0x7;

	int r0 =   (raw) & 7;
	if(roc_pixeladdress_inverted) r0 ^= 0x7;

	int r = r2*36 + r1*6 + r0;
	row = 80 - r/2;
	col = 2*c + (r&1);

	return 1;
}

bool CTestboard::GetPixelAddressInverted() {
	return roc_pixeladdress_inverted;
}

void CTestboard::SetPixelAddressInverted(bool status) {
	roc_pixeladdress_inverted = status;
}

int32_t CTestboard::CountReadouts(int32_t nTriggers)
{ 
    int32_t nHits = 0;
    Daq_Open(5000);
    Daq_Select_Deser160(deserAdjust);
    uDelay(30);
    Daq_Start();
    for (int16_t i=0; i < nTriggers; i++)
    {
	    Pg_Single();
	    uDelay(5);
    }
    Daq_Stop();

    vector<uint16_t> data;
    Daq_Read(data,5000);
    Daq_Close();

    int16_t ok = -1, pos = 0, n = 0, ph = 0, col = 0, row = 0;
    for (int16_t i=0; i < nTriggers; i++)
    {
        ok = DecodePixel(data, pos, n, ph, col, row);

        if (n > 0 and ok) nHits++;
    }
    return nHits;
}

int32_t CTestboard::CountReadouts(int32_t nTrig, int32_t chipId)
{
	roc_I2cAddr(chipId);
	return CountReadouts(nTrig);
}

int32_t CTestboard::CountReadouts(int32_t nTrig, int32_t dacReg, int32_t dacValue)
{
	roc_SetDAC(dacReg, dacValue);
	return CountReadouts(nTrig);
}

/*uint8_t CTestboard::DacDac_dtb(vectorR<uint16_t> &res, int32_t dac1, int32_t dacRange1, int32_t dac2, int32_t dacRange2, int32_t nTrig)
{
	res.clear();
	res.reserve(dacRange1*dacRange2);
	for (int i = 0; i < dacRange1; i++)
	{
		roc_SetDAC(dac1, i);
		for (int k = 0; k < dacRange2; k++)
		{
			roc_SetDAC(dac2, k);
			//res.insert(res.end(),CountReadouts(nTrig));
			res.push_back(CountReadouts(nTrig));
		}
	}
	return 1;
}*/

int32_t CTestboard::PH(int32_t col, int32_t row, int32_t trim, int16_t nTriggers)
{
    Daq_Open(50000);
    Daq_Select_Deser160(deserAdjust);
    uDelay(100);
    Daq_Start();
    uDelay(100);

    roc_Col_Enable(col, true);
    roc_Pix_Trim(col, row, trim);
    roc_Pix_Cal (col, row, false);

    vector<uint16_t> data;

    //roc_SetDAC(Vcal, vcal);
    uDelay(100);
    for (int16_t k=0; k<nTriggers; k++)
    {
        Pg_Single();
        uDelay(20);
    }

    roc_Pix_Mask(col, row);
    roc_Col_Enable(col, false);
    roc_ClrCal();

    Daq_Stop();
    Daq_Read(data, 4000);
    Daq_Close();
    // --- analyze data

	int cnt = 0;
	double yi = 0.0;

	int16_t ok = -1, pos = 0, n = 0, ph = 0, colR = 0, rowR = 0;

	for (int16_t i=0; i < nTriggers; i++)
	{
		ok = DecodePixel(data, pos, n, ph, colR, rowR);
		if (n > 0 and ok) {yi += ph; cnt++;}
	}

	if (cnt > 0)
		return (int32_t) yi/cnt;
	else
		return -9999;

}

/*int32_t CTestboard::ChipEfficiency(int16_t nTriggers, vectorR<uint8_t> &res)
{
    // --- scan all pixel ------------------------------------------------------
    uint8_t col, row;
    uint8_t nHits = 0;
    Daq_Open(100000);
    Daq_Select_Deser160(deserAdjust);
    Daq_Start();

    int16_t ok = -1, n = 0, ph = 0, colR = 0, rowR = 0, pos = 0;
    for (col=0; col<ROC_NUMCOLS; col++)
    {
    	pos = 0;
        roc_Col_Enable(col, true);
        for (row=0; row<ROC_NUMROWS; row++)
        {
            roc_Pix_Trim(col, row, 15);
            roc_Pix_Cal(col, row, false);
			uDelay(5);
            for (int16_t i=0; i < nTriggers; i++)
            {
			    Pg_Single();
			    uDelay(1);
            }
            roc_Pix_Mask(col, row);
			roc_ClrCal();
        }
        roc_Col_Enable(col, false);
        vector<uint16_t> data;
        Daq_Read(data,50000);
        for (row=0; row<ROC_NUMROWS; row++)
        {
        		nHits = 0;
                for (int16_t i=0; i < nTriggers; i++)
                {
                	ok = DecodePixel(data, pos, n, ph, colR, rowR);
                	if (n > 0 && ok && col == colR && row == rowR) {nHits++;}
                }
            // for each col, for each row, count number of hits and divide by triggers
            res.push_back(nHits);
            //printf("Pix %i,%i: %i\n",col,row,nHits);
        }
    }
    Daq_Close();
    Daq_Stop();
    return 1;
}*/

// == Thresholds ===================================================
/*
int32_t CTestboard::ThresholdBinary(int32_t thrLevel, int32_t nTrig, int32_t dacReg, int32_t dacMin, int32_t dacMax, bool reverseMode)
{
    int step_size = 1;
    if (reverseMode) step_size = 3;
    // test if threshold is already reached
    if (dacMax < dacMin && !reverseMode)
        // return value is dacMin
        return dacMin;
    if (dacMin > dacMax && reverseMode)
        // return value
        return dacMax;
     else
    {
      // calculate midpoint to cut set in half, non symmetric
      int32_t dacMid = dacMin + step_size*((dacMax - dacMin) / 4);
      int32_t thrMid = CountReadouts(nTrig, dacReg, dacMid);
      //cout << "Threshold finding midPoint : " << dacMid << "  Threshold : " << thrMid  << " thrLevel: " << thrLevel << " dacMin: " << dacMin << " dacMax: " << dacMax << endl;
      // three-way comparison
      if ((thrMid > thrLevel && !reverseMode) || (thrMid < thrLevel && reverseMode))
        // threshold is in lower subset
        return ThresholdBinary(thrLevel, nTrig, dacReg, dacMin, dacMid-1, reverseMode);
      else if ((thrMid < thrLevel && !reverseMode) || (thrMid > thrLevel && reverseMode))
        // threshold is in upper subset
        return ThresholdBinary(thrLevel, nTrig, dacReg, dacMid+1, dacMax, reverseMode);
      else
        // threshold has been found
        return dacMid;
    }
}
*/
int32_t CTestboard::Threshold(int32_t start, int32_t step, int32_t thrLevel, int32_t nTrig, int32_t dacReg)
{
        int32_t threshold = start, newValue, oldValue, result;
        int stepAbs;
        if (step < 0) stepAbs = -step; else stepAbs = step;

        newValue = CountReadouts(nTrig, dacReg, threshold);
        if (newValue > thrLevel)
        {
                do
                {
                        threshold-=step;
                        oldValue = newValue;
                        newValue = CountReadouts(nTrig, dacReg, threshold);
                }
                while ((newValue > thrLevel) && (threshold > (stepAbs - 1)) && (threshold < (256 - stepAbs)));

                if (oldValue - thrLevel > thrLevel - newValue) result = threshold;
                else result = threshold+step;
        }
        else
        {
                do
                {
                        threshold+=step;
                        oldValue = newValue;
                        newValue = CountReadouts(nTrig, dacReg, threshold);
                }
                while ((newValue <= thrLevel) && (threshold > (stepAbs - 1)) && (threshold < (256 - stepAbs)));

                if (thrLevel - oldValue > newValue - thrLevel) result = threshold;
                else result = threshold-step;
        }

        if (result > 255) result = 255;
        if (result < 0) result = 0;

        return result;
}

/*
bool CTestboard::FindReadout(int32_t thrLevel, int32_t nTrig, int32_t dacReg, int32_t &dacMin, int32_t &dacMax, bool reverseMode)
{
    if (abs(dacMax -dacMin) <= 1) return false;
    else{
      // calculate midpoint to cut set in half
      int32_t dacMid = dacMin + ((dacMax - dacMin) / 2);
      int32_t thrMid = CountReadouts(nTrig, dacReg, dacMid);
      //cout << "Find readout midPoint : " << dacMid << "  Threshold : " << thrMid  << " thrLevel: " << thrLevel << " dacMin: " << dacMin << " dacMax: " << dacMax << endl;
      if (thrMid > thrLevel) return true;
      else{
                  if (FindReadout(thrLevel, nTrig, dacReg, dacMin, dacMid, reverseMode)) {
                dacMax = dacMid;
                return true;
            }
            else if (FindReadout(thrLevel, nTrig, dacReg, dacMid, dacMax, reverseMode)){
                dacMin = dacMid;
                return true;
            }
      }
    }
}

int32_t CTestboard::PixelThreshold(int32_t col, int32_t row, int32_t start, int32_t step, int32_t thrLevel, int32_t nTrig, int32_t dacReg, int32_t xtalk, int32_t cals, int32_t trim)
{
	int calRow = row;
	roc_Pix_Trim(col, row, trim);

	if (xtalk)
	{
		if (row == ROC_NUMROWS - 1) calRow = row - 1;
		else calRow = row + 1;
	}
	if (cals) roc_Pix_Cal(col, calRow, true);
	else roc_Pix_Cal(col, calRow, false);

	bool reverseMode = false;
	if (step < 0) reverseMode = true;
	int32_t res = -1;
	if (!reverseMode) res = 256;

	int32_t dacMin = 0, dacMax = 256;
	if (FindReadout(0, 1, dacReg, dacMin, dacMax, reverseMode)) {
	    res = ThresholdBinary(thrLevel, nTrig, dacReg, dacMin, dacMax, reverseMode);
	    //If binary search fails, find simple threshold
	    if ((res > dacMax && !reverseMode) || (res < dacMin && reverseMode)){
	        int roughThr = ThresholdSimple(dacMin, 4*step/abs(step), 0, 1, dacReg);
	        res = ThresholdSimple(roughThr, 1*step/abs(step), thrLevel, nTrig, dacReg);
	    }
	}

    roc_ClrCal();
    roc_Pix_Mask(col, row);
	return res;
}
*/

int32_t CTestboard::PixelThreshold(int32_t col, int32_t row, int32_t start, int32_t step, int32_t thrLevel, int32_t nTrig, int32_t dacReg, int32_t xtalk, int32_t cals, int32_t trim)
{
        int calRow = row;
        roc_Pix_Trim(col, row, trim);

        if (xtalk)
        {
                if (row == ROC_NUMROWS - 1) calRow = row - 1;
                else calRow = row + 1;
        }
        if (cals) roc_Pix_Cal(col, calRow, true);
        else roc_Pix_Cal(col, calRow, false);

        int32_t res = Threshold(start, step, thrLevel, nTrig, dacReg);
    roc_ClrCal();
    roc_Pix_Mask(col, row);
        return res;
}


bool CTestboard::test_pixel_address(int32_t col, int32_t row)
{
    Daq_Open(5000);
    Daq_Select_Deser160(deserAdjust);
    uDelay(100);
    Daq_Start();
    uDelay(100);
    roc_Col_Enable(col, true);
    uDelay(20);

    roc_Pix_Trim(col,row,15);
    roc_Pix_Cal(col,row,false);
    uDelay(20);
    Pg_Single();
    uDelay(5);
    roc_ClrCal();
    roc_Pix_Mask(col,row);
    uDelay(20);
    roc_Col_Enable(col, false);
    uDelay(100);
    Daq_Stop();

    vector<uint16_t> data;
    Daq_Read(data, 5000);
    Daq_Close();
    // --- analyze data

	int16_t ok = -1, pos = 0, n = 0, ph = 0, colR = -1, rowR = -1;

	ok = DecodePixel(data, pos, n, ph, colR, rowR);

	if (n > 0 and ok) {
		return (col == colR && row == rowR);
	}
	return false;

}
