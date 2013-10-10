// pixel_dtb.cpp

#include "dtb_hal.h"
#include "pixel_dtb.h"
#include "dtb_config.h"
#include "rpc.h"
#include "SRecordReader.h"
#include "io.h"

// === id ===================================================================

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

#define DELAY 120
void CTestboard::Welcome()
{
	_SetLED(0x01);	mDelay(DELAY);
	_SetLED(0x02);	mDelay(DELAY);
	_SetLED(0x08);	mDelay(DELAY);
	_SetLED(0x04);	mDelay(DELAY);

	_SetLED(0x01);	mDelay(DELAY);
	_SetLED(0x02);	mDelay(DELAY);
	_SetLED(0x08);	mDelay(DELAY);
	_SetLED(0x04);	mDelay(DELAY);

	_SetLED(0x01);	mDelay(DELAY);
	_SetLED(0x03);	mDelay(DELAY);
	_SetLED(0x0b);	mDelay(DELAY);
	_SetLED(0x0f);	mDelay(DELAY*3);
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



// === dtb1 =================================================================

void CTestboard::Init()
{
	if (flashMem) { delete flashMem; flashMem = 0; }

	Pg_Stop();

	// disable DAQ
	Daq_Close();

	daq_select_adc = false;
	ADC_WRITE(ADC_CTRL, 0);

	daq_select_deser160 = false;
	IOWR_ALTERA_AVALON_PIO_DATA(DESER160_BASE, 0);


	ChipId  = 0;
	TBM_present = false;
	MOD_present = false;
	HUB_address = 0;

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
}


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
//	SetClock_(currentClock);
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

	Daq_Close();
//	SetClock_(MHZ_1_25);
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
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 4, sig);   // A1+
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 5, sig+1); // A1-
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 0, 0xFF);
}


void CTestboard::SignalProbeA2(uint8_t signal)
{
	uint8_t sig = signal << 1;
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 6, sig);   // A2+
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 7, sig+1); // A2-
	IOWR_8DIRECT(CROSSPOINT_SWITCH_BASE, 0, 0xFF);
}


void CTestboard::SignalProbeADC(uint8_t signal, uint8_t gain)
{
	if (signal >= 8) return;
	if (gain > 3) gain = 3;
	uint8_t sig = signal << 1;

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


// == TBM functions =====================================================

const unsigned char CTestboard::MODCONF[16]
= { 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3 };

// selects if you want to use the TBM
// Note: MOD_present is used for automatic address assignment. Works with standard BPix modules only
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
	long x;
	reg |= 1;
	if (!tbm_GetRaw(reg, x)) return false;
	long y = (((HUB_address & (0x1f<<3)) + 4) << 8) + reg;
	if (((x>>8) & 0xffff) != y) return false;
	value = (unsigned char)(x & 0xff);
	return true;
}

// === ROC/Module Communication =========================================

// --- ROC functions ----------------------------------------------------


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
	SetI2cHs(4, value & 0x0f | 0x80);
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


// --- Data aquisition ------------------------------------------------------

/*
uint32_t daq_data0;
uint32_t daq_size;
bool     daq_running;
uint16_t daq_fifo_state;
uint8_t  daq_deser160_state;
*/

uint32_t CTestboard::Daq_Open(uint32_t buffersize)
{
	// close last DAQ session if still active
	Daq_Close();

	// set size limits for memory allocation
	if (buffersize > 50000000) buffersize = 50000000;  // max 50 Mio samples
	if (buffersize < 16384) buffersize = 16384;  // min 16384 samples

	// allocate memory
	daq_mem_base = new uint16_t[buffersize];
	if (daq_mem_base == 0) return 0;
	daq_mem_size = buffersize;

	// set DMA to allocated memory
	DAQ_WRITE(DAQ_MEM_BASE, (unsigned long)daq_mem_base);
	DAQ_WRITE(DAQ_MEM_SIZE, (unsigned long)daq_mem_size);

	return daq_mem_size;
}

void CTestboard::Daq_Close()
{
	if (daq_mem_base)
	{
		Daq_Stop();
		IOWR_ALTERA_AVALON_PIO_DATA(DESER160_BASE, 0); // FIFO reset
		uDelay(1);
		delete[] daq_mem_base;
		daq_mem_base = 0;
	}
}

void CTestboard::Daq_Start()
{
	if (daq_mem_base)
	{
		// clear buffer and enable daq
		DAQ_WRITE(DAQ_CONTROL, 1);

		// switch on data sources
//		IOWR_ALTERA_AVALON_PIO_DATA(ADC_BASE, daq_adc_state);
//		IOWR_ALTERA_AVALON_PIO_DATA(DESER160_BASE, daq_deser160_state);
	}
}


void CTestboard::Daq_Stop()
{
	if (daq_mem_base)
	{
		// switch of data sources
//		IOWR_ALTERA_AVALON_PIO_DATA(ADC_BASE, 0);
//		IOWR_ALTERA_AVALON_PIO_DATA(DESER160_BASE, 0);

		// stop daq
		DAQ_WRITE(DAQ_CONTROL, 0);
	}
}


uint32_t CTestboard::Daq_GetSize()
{
	if (daq_mem_base == 0) return 0;

	// read dma status
	int32_t status = DAQ_READ(DAQ_CONTROL);
	int32_t rp = DAQ_READ(DAQ_MEM_READ);
	int32_t wp = DAQ_READ(DAQ_MEM_WRITE);

	// correct write pointer overrun at memory overflow
	if (status & DAQ_MEM_OVFL) if (--wp < 0) wp += daq_mem_size;

	// calculate available words in memory (-> fifosize)
	int32_t diff = wp - rp;
	int32_t fifosize = diff;
	if (fifosize < 0) fifosize += daq_mem_size;

	return fifosize;
}

template <class T>
inline T* Uncache(T *x) { return (T*)(((unsigned long)x) | 0x80000000); }

uint8_t CTestboard::Daq_Read(vectorR<uint16_t> &data,
		 uint16_t blocksize)
{
	uint32_t availsize;
	return Daq_Read(data, blocksize, availsize);
}


uint8_t CTestboard::Daq_Read(vectorR<uint16_t> &data,
		uint16_t blocksize, uint32_t &availsize)
{
	data.clear();

	if (daq_mem_base == 0) { availsize = 0; return 0; }

	// limit maximal block size
	if (blocksize > 32768) blocksize = 32768;
	if (blocksize > daq_mem_size) blocksize = daq_mem_size;

	// read dma status
	int32_t status = DAQ_READ(DAQ_CONTROL);
	int32_t rp = DAQ_READ(DAQ_MEM_READ);
	int32_t wp = DAQ_READ(DAQ_MEM_WRITE);

	// correct write pointer overrun at memory overflow
	if (status & DAQ_MEM_OVFL) if (--wp < 0) wp += daq_mem_size;

	// calculate available words in memory (-> fifosize)
	int32_t fifosize = wp - rp;
	if (fifosize < 0) fifosize += daq_mem_size;

	// calculate transfer block size (-> blocksize)
	if (blocksize > fifosize) blocksize = fifosize;

	// return remaining data size
	availsize = fifosize - blocksize;

	// allocate space in vector or return empty data
	if (blocksize > 0) data.reserve(blocksize);
	else return uint8_t(status);

	// --- send 1st part of the data block
	int32_t size1 = daq_mem_size - rp;
	if (size1 > blocksize) size1 = blocksize;

	// copy data to vector
	uint16_t *p = Uncache(daq_mem_base) + rp;
	data.insert(data.end(), p, p + size1);
	blocksize -= size1;

	// --- send 2ns part of the data block
	if (blocksize > 0)
	{
		p = Uncache(daq_mem_base);
		data.insert(data.end(), p, p + blocksize);
		rp = blocksize;
	}
	else rp += size1;

	// update read pointer
	DAQ_WRITE(DAQ_MEM_READ, rp);

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

	// enable adc
	daq_select_adc = true;
	if (isPowerOn) mainCtrl |= MAINCTRL_ADCENA;
	_MainControl(mainCtrl);

	ADC_WRITE(ADC_LEN, blocksize);
	ADC_WRITE(ADC_START, s);
	ADC_WRITE(ADC_STOP, p);
	ADC_WRITE(ADC_CTRL, 1);
}


void CTestboard::Daq_Select_Deser160(uint8_t shift)
{
	// disable adc
	daq_select_adc = false;
	mainCtrl &= ~MAINCTRL_ADCENA;
	_MainControl(mainCtrl);
	ADC_WRITE(ADC_CTRL, 1);

	// enable deser160
	daq_select_deser160 = true;
	IOWR_ALTERA_AVALON_PIO_DATA(DESER160_BASE, (shift & 0x7) | 0x8);
}

