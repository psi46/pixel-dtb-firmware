// pixel_atb.h

#pragma once

#include "dtb_hal.h"
#include "rpc.h"
#include "FlashMemory.h"


// size of module
#define MOD_NUMROCS  16

// size of ROC pixel array
#define ROC_NUMROWS  80  // # rows
#define ROC_NUMCOLS  52  // # columns
#define ROC_NUMDCOLS 26  // # double columns (= columns/2)

#define PIXMASK  0x80

// PUC register addresses for roc_SetDAC
#define	Vdig        0x01
#define Vana        0x02
#define	Vsh         0x03
#define	Vcomp       0x04
#define	Vleak_comp  0x05
#define	VrgPr       0x06
#define	VwllPr      0x07
#define	VrgSh       0x08
#define	VwllSh      0x09
#define	VhldDel     0x0A
#define	Vtrim       0x0B
#define	VthrComp    0x0C
#define	VIBias_Bus  0x0D
#define	Vbias_sf    0x0E
#define	VoffsetOp   0x0F
#define	VIbiasOp    0x10
#define	VoffsetRO   0x11
#define	VIon        0x12
#define	VIbias_PH   0x13
#define	Ibias_DAC   0x14
#define	VIbias_roc  0x15
#define	VIColOr     0x16
#define	Vnpix       0x17
#define	VsumCol     0x18
#define	Vcal        0x19
#define	CalDel      0x1A
#define	RangeTemp   0x1B
#define	WBC         0xFE
#define	CtrlReg     0xFD



class CTestboard
{
	CRpcIo *rpc_io;
	CUSB usb;

	static const uint16_t flashUpgradeVersion;
	uint16_t ugRecordCounter;
	CFlashMemory *flashMem;

	uint32_t mainCtrl;
	bool isPowerOn;
	int currentClock;

	uint16_t vd, va;
	uint16_t id, ia;

	// --- DAQ variables
	uint16_t *daq_mem_base[8]; // DAQ buffer base address (0 = no space reserved)
	uint32_t daq_mem_size[8];  // DAQ buffer size in 16 bit words
	uint16_t daq_fifo_state[8];

	bool daq_select_adc;
	bool daq_select_deser160;
	bool daq_select_deser400;

	uint8_t sig_level_clk;
	uint8_t sig_level_ctr;
	uint8_t sig_level_sda;
	uint8_t sig_level_tin;
	uint8_t sig_offset;

	bool roc_pixeladdress_inverted;

	unsigned char ChipId;
	bool TBM_present;
	bool MOD_present;
	unsigned char HUB_address;
	static const unsigned char MODCONF[16];


	void InitDac();
	void SetDac(int addr, int value);
	unsigned int ReadADC(unsigned char addr);
	unsigned int mV_to_DAC(int mV);
	unsigned int uA100_to_DAC(int ua100);
	int ADC_to_mV(unsigned int dac);
	int ADC_to_uA100(unsigned int dac);

	void Sig_Off();
	void Sig_Restore();

	static unsigned char COLCODE(unsigned char x) { return ((x>>1) & 0x7e)^x; }
	static unsigned char ROWCODE(unsigned char x) { return (x>>1)^x; }

public:
	CTestboard();
	CRpcIo* GetIo() { return rpc_io; }


	// === RPC ==============================================================

	RPC_EXPORT uint16_t GetRpcVersion();
	RPC_EXPORT int32_t  GetRpcCallId(string &cmdName);

	RPC_EXPORT void GetRpcTimestamp(stringR &ts);

	RPC_EXPORT int32_t GetRpcCallCount();
	RPC_EXPORT bool    GetRpcCallName(int32_t id, stringR &callName);

	RPC_EXPORT uint32_t GetRpcCallHash();
	uint32_t GetHashForString(const char *s);

//	RPC_EXPORT uint16_t GetRpcServerCallCount();
//	RPC_EXPORT void     GetRpcServerCallName(uint16_t index, stringR &callName);


	// === DTB identification ===============================================

	RPC_EXPORT void GetInfo(stringR &info);
	RPC_EXPORT uint16_t GetBoardId();	// reads the board number

	RPC_EXPORT void GetHWVersion(stringR &version);
	RPC_EXPORT uint16_t GetFWVersion();
	RPC_EXPORT uint16_t GetSWVersion();


	// === DTB service ======================================================

	// --- upgrade
	RPC_EXPORT uint16_t UpgradeGetVersion();
	RPC_EXPORT uint8_t  UpgradeStart(uint16_t version);
	RPC_EXPORT uint8_t  UpgradeData(string &record);
	RPC_EXPORT uint8_t  UpgradeError();
	RPC_EXPORT void     UpgradeErrorMsg(stringR &msg);
	RPC_EXPORT void     UpgradeExec(uint16_t recordCount);

//	RPC_EXPORT(service) void Bootstrap();


	// === DTB functions ====================================================

	RPC_EXPORT void Init();

	RPC_EXPORT void Welcome();
	RPC_EXPORT void SetLed(uint8_t x);


	// === Clock, Timing ====================================================

	RPC_EXPORT void cDelay(uint16_t clocks);
	RPC_EXPORT void uDelay(uint16_t us);
	void mDelay(uint16_t ms);


	// --- select ROC/Module clock source
	#define CLK_SRC_INT  0
	#define CLK_SRC_EXT  1
	RPC_EXPORT void SetClockSource(uint8_t source);

	// --- check if external clock is present
	RPC_EXPORT bool IsClockPresent();

	// --- set clock clock frequency (clock divider)
	#define MHZ_1_25   5
	#define MHZ_2_5    4
	#define MHZ_5      3
	#define MHZ_10     2
	#define MHZ_20     1
	#define MHZ_40     0  // default
	RPC_EXPORT void SetClock(uint8_t MHz);

	// --- set clock stretch
	// width = 0 -> disable stretch
	#define STRETCH_AFTER_TRG  0
	#define STRETCH_AFTER_CAL  1
	#define STRETCH_AFTER_RES  2
	#define STRETCH_AFTER_SYNC 3
	RPC_EXPORT void SetClockStretch(uint8_t src,
		uint16_t delay, uint16_t width);

//	RPC_EXPORT void PllReset();
	void SetClock_(unsigned char MHz);

	// --- Signal Delay -----------------------------------------------------
	#define SIG_CLK 0
	#define SIG_CTR 1
	#define SIG_SDA 2
	#define SIG_TIN 3

	#define SIG_MODE_NORMAL  0
	#define SIG_MODE_LO      1
	#define SIG_MODE_HI      2

	RPC_EXPORT void Sig_SetMode(uint8_t signal, uint8_t mode);
	RPC_EXPORT void Sig_SetPRBS(uint8_t signal, uint8_t speed);
	RPC_EXPORT void Sig_SetDelay(uint8_t signal, uint16_t delay, int8_t duty = 0);
	RPC_EXPORT void Sig_SetLevel(uint8_t signal, uint8_t level);
	RPC_EXPORT void Sig_SetOffset(uint8_t offset);
	RPC_EXPORT void Sig_SetLVDS();
	RPC_EXPORT void Sig_SetLCDS();


	// --- digital signal probe ---------------------------------------------
	#define PROBE_OFF          0
	#define PROBE_CLK          1
	#define PROBE_SDA          2
	#define PROBE_SDA_SEND     3
	#define PROBE_PG_TOK       4
	#define PROBE_PG_TRG       5
	#define PROBE_PG_CAL       6
	#define PROBE_PG_RES_ROC   7
	#define PROBE_PG_RES_TBM   8
	#define PROBE_PG_SYNC      9
	#define PROBE_CTR         10
	#define PROBE_TIN         11
	#define PROBE_TOUT        12
	#define PROBE_CLK_PRESEN  13
	#define PROBE_CLK_GOOD    14
	#define PROBE_DAQ0_WR     15
	#define PROBE_CRC         16
	#define PROBE_ADC_RUNNING 19
	#define PROBE_ADC_RUN     20
	#define PROBE_ADC_PGATE   21
	#define PROBE_ADC_START   22
	#define PROBE_ADC_SGATE   23
	#define PROBE_ADC_S       24


	RPC_EXPORT void SignalProbeD1(uint8_t signal);
	RPC_EXPORT void SignalProbeD2(uint8_t signal);


	// --- analog signal probe ----------------------------------------------
	#define PROBEA_TIN     0
	#define PROBEA_SDATA1  1
	#define PROBEA_SDATA2  2
	#define PROBEA_CTR     3
	#define PROBEA_CLK     4
	#define PROBEA_SDA     5
	#define PROBEA_TOUT    6
	#define PROBEA_OFF     7

	#define GAIN_1   0
	#define GAIN_2   1
	#define GAIN_3   2
	#define GAIN_4   3


	RPC_EXPORT void SignalProbeA1(uint8_t signal);
	RPC_EXPORT void SignalProbeA2(uint8_t signal);
	RPC_EXPORT void SignalProbeADC(uint8_t signal, uint8_t gain = 0);


	// --- ROC/Module power VD/VA -------------------------------------------
	RPC_EXPORT void Pon();
	RPC_EXPORT void Poff();

	RPC_EXPORT void _SetVD(uint16_t mV);
	RPC_EXPORT void _SetVA(uint16_t mV);
	RPC_EXPORT void _SetID(uint16_t uA100);
	RPC_EXPORT void _SetIA(uint16_t uA100);

	RPC_EXPORT uint16_t _GetVD();
	RPC_EXPORT uint16_t _GetVA();
	RPC_EXPORT uint16_t _GetID();
	RPC_EXPORT uint16_t _GetIA();

	RPC_EXPORT void HVon();
	RPC_EXPORT void HVoff();
	RPC_EXPORT void ResetOn();
	RPC_EXPORT void ResetOff();

	RPC_EXPORT uint8_t GetStatus();
	RPC_EXPORT void SetRocAddress(uint8_t addr);


	// --- pulse pattern generator ------------------------------------------
	#define PG_TOK   0x0100
	#define PG_TRG   0x0200
	#define PG_CAL   0x0400
	#define PG_RESR  0x0800
	#define PG_REST  0x1000
	#define PG_SYNC  0x2000

	RPC_EXPORT void Pg_SetCmd(uint16_t addr, uint16_t cmd);
//	RPC_EXPORT void pg_SetCmdAll(vector<uint16_t> &cmd);
	RPC_EXPORT void Pg_Stop();
	RPC_EXPORT void Pg_Single();
	RPC_EXPORT void Pg_Trigger();
	RPC_EXPORT void Pg_Loop(uint16_t period);


	// --- data aquisition --------------------------------------------------
	RPC_EXPORT uint32_t Daq_Open(uint32_t buffersize = 10000000, uint8_t channel = 0);
	RPC_EXPORT void Daq_Close(uint8_t channel = 0);
	RPC_EXPORT void Daq_Start(uint8_t channel = 0);
	RPC_EXPORT void Daq_Stop(uint8_t channel = 0);
	RPC_EXPORT uint32_t Daq_GetSize(uint8_t channel = 0);

	RPC_EXPORT uint8_t Daq_Read(vectorR<uint16_t> &data,
			 uint16_t blocksize = 16384, uint8_t channel = 0);

	RPC_EXPORT uint8_t Daq_Read(vectorR<uint16_t> &data,
			uint16_t blocksize, uint32_t &availsize, uint8_t channel = 0);


	RPC_EXPORT void Daq_Select_ADC(uint16_t blocksize, uint8_t source,
			uint8_t start, uint8_t stop = 0);

	RPC_EXPORT void Daq_Select_Deser160(uint8_t shift);

	RPC_EXPORT void Daq_Select_Deser400();
	RPC_EXPORT void Daq_Deser400_Reset(uint8_t reset = 3);

	RPC_EXPORT void Daq_DeselectAll();


	// --- ROC/module Communication -----------------------------------------
	// -- set the i2c address for the following commands
	RPC_EXPORT void roc_I2cAddr(uint8_t id);

	// -- sends "ClrCal" command to ROC
	RPC_EXPORT void roc_ClrCal();

	// -- sets a single (DAC) register
	RPC_EXPORT void roc_SetDAC(uint8_t reg, uint8_t value);

	// -- set pixel bits (count <= 60)
	//    M - - - 8 4 2 1
	RPC_EXPORT void roc_Pix(uint8_t col, uint8_t row, uint8_t value);

	// -- trimm a single pixel (count < =60)
	RPC_EXPORT void roc_Pix_Trim(uint8_t col, uint8_t row, uint8_t value);

	// -- mask a single pixel (count <= 60)
	RPC_EXPORT void roc_Pix_Mask(uint8_t col, uint8_t row);

	// -- set calibrate at specific column and row
	RPC_EXPORT void roc_Pix_Cal(uint8_t col, uint8_t row, bool sensor_cal = false);

	// -- enable/disable a double column
	RPC_EXPORT void roc_Col_Enable(uint8_t col, bool on);

	// -- mask all pixels of a column and the corresponding double column
	RPC_EXPORT void roc_Col_Mask(uint8_t col);

	// -- mask all pixels and columns of the chip
	RPC_EXPORT void roc_Chip_Mask();

	// --- TBM
	RPC_EXPORT bool TBM_Present();

	RPC_EXPORT void tbm_Enable(bool on);

	RPC_EXPORT void tbm_Addr(uint8_t hub, uint8_t port);

	RPC_EXPORT void mod_Addr(uint8_t hub);

	RPC_EXPORT void tbm_Set(uint8_t reg, uint8_t value);

	RPC_EXPORT bool tbm_Get(uint8_t reg, uint8_t &value);

	RPC_EXPORT bool tbm_GetRaw(uint8_t reg, uint32_t &value);

	int16_t DecodePixel(vector<uint16_t> &data, int16_t &pos, int16_t &n, int16_t &ph, int16_t &col, int16_t &row);

	RPC_EXPORT bool GetPixelAddressInverted();
    void SetPixelAddressInverted(bool status);



// --- ROC test functions

	int16_t DecodeReadout(vector<uint16_t> &data, int16_t &pos, vector<uint16_t> &ph, vector<uint16_t> &col, vector<uint16_t> &row);
	RPC_EXPORT int32_t CountReadouts(int32_t nTriggers);
	RPC_EXPORT int32_t CountReadouts(int32_t nTriggers, int32_t chipId);
	RPC_EXPORT int32_t CountReadouts(int32_t nTriggers, int32_t dacReg, int32_t dacValue);
	RPC_EXPORT int32_t PH(int32_t col, int32_t row, int32_t trim, int16_t nTriggers);
	//int32_t ThresholdBinary(int32_t thrLevel, int32_t nTrig, int32_t dacReg, int32_t dacMin, int32_t dacMax, bool reverseMode);
	int32_t Threshold(int32_t start, int32_t step, int32_t thrLevel, int32_t nTrig, int32_t dacReg);
	//bool FindReadout(int32_t thrLevel, int32_t nTrig, int32_t dacReg, int32_t &dacMin, int32_t &dacMax, bool reverseMode);
	RPC_EXPORT int32_t PixelThreshold(int32_t col, int32_t row, int32_t start, int32_t step, int32_t thrLevel, int32_t nTrig, int32_t dacReg, bool xtalk, bool cals);
	RPC_EXPORT bool test_pixel_address(int32_t col, int32_t row);


	//new functions
	RPC_EXPORT int8_t CalibratePixel(int16_t nTriggers, int16_t col, int16_t row, int16_t &nReadouts, int32_t &PHsum);
	RPC_EXPORT int8_t CalibrateDacScan(int16_t nTriggers, int16_t col, int16_t row, int16_t dacReg1, int16_t dacLower1, int16_t dacUpper1, vectorR<int16_t> &nReadouts, vectorR<int32_t> &PHsum);
    RPC_EXPORT int8_t CalibrateDacDacScan(int16_t nTriggers, int16_t col, int16_t row, int16_t dacReg1, int16_t dacLower1, int16_t dacUpper1, int16_t dacReg2, int16_t dacLower2, int16_t dacUpper2, vectorR<int16_t> &nReadouts, vectorR<int32_t> &PHsum);
    //RPC_EXPORT int8_t CalibrateMap(int16_t nTriggers, vectorR<int16_t> &nReadouts, vectorR<int32_t> &PHsum);
    void ChipThresholdIntern(int32_t start[], int32_t step, int32_t thrLevel, int32_t nTrig, int32_t dacReg, bool xtalk, bool cals, int32_t res[]);
    int8_t ThresholdMap(int32_t nTriggers, int32_t dacReg, bool rising, bool xtalk, bool cals, vectorR<int16_t> &thrValue);
    //RPC_EXPORT int8_t ThresholdMap(int16_t nTriggers, int16_t dacReg, int16_t dacRange, vectorR<int16_t> &thrValue);

    int8_t CalibrateReadouts(int16_t nTriggers, int16_t &nReadouts, int32_t &PHsum);

    RPC_EXPORT int16_t TrimChip(vector<int16_t> &trim);

    //int8_t Daq_Enable2(int32_t block);
    //int8_t Daq_Disable2();


    // Module compatible functions
	void Daq_Enable2(int32_t block);
	int8_t Daq_Read2(vector<uint16_t> &data, uint16_t daq_read_size, uint32_t &n);
	void Daq_Disable2();
	void DecodeTbmTrailer(unsigned int raw, int16_t &dataId, int16_t &data);
	void DecodeTbmHeader(unsigned int raw, int16_t &evNr, int16_t &stkCnt);
	void DecodePixel(unsigned int raw, int16_t &n, int16_t &ph, int16_t &col, int16_t &row);
	int8_t Decode(const vector<uint16_t> &data, vector<uint16_t> &n, vector<uint16_t> &ph, vector<uint32_t> &adr);
	//int8_t Decode2(const vector<uint16_t> &data, vector<int16_t> &n, vector<int32_t> &ph, vector<uint32_t> &adr);
	RPC_EXPORT int16_t CalibrateMap(int16_t nTriggers, vectorR<int16_t> &nReadouts, vectorR<int32_t> &PHsum, vectorR<uint32_t> &addres);


	// Wafer test functions
	RPC_EXPORT bool TestColPixel(uint8_t col, uint8_t trimbit, vectorR<uint8_t> &res);

	// Ethernet test functions
	bool Ethernet_Init();
	RPC_EXPORT void Ethernet_Send(string &message);
	RPC_EXPORT uint32_t Ethernet_RecvPackets();
};

extern CTestboard tb;
