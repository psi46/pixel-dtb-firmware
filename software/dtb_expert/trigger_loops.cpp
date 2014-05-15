// trigger_loops.cpp

#include "dtb_hal.h"
#include "pixel_dtb.h"
#include "dtb_config.h"
#include "rpc.h"

// -------- Helper Functions -------------------------------

// Use a maximum of 85% of allocated DAQ buffer before reading out:
#define LOOP_MAX_FILLLEVEL  85
#define LOOP_MAX_INTERRUPTS 20

// Wait this long when setting DACs to lowest value
// they need time to settle after large jumps. Time given in usec.
#define LOOP_SETDAC_DELAY_LONG uDelay(70)
#define LOOP_SETDAC_DELAY_SHORT uDelay(0)

// Reset the Loop Interrupt, so next Loop call starts from scratch:
void CTestboard::LoopInterruptReset() {
  // Reset the interrupted Loop flag:
  LoopInterrupt = false;
  LoopInterruptColumn = LoopInterruptRow = 0;
  LoopInterruptDac1 = LoopInterruptDac2 = 0;
  LoopInterruptId = 0;
  LoopInterruptCounter = 0;

  // LoopInterrupt is reset: turn off interrupt LED:
  ToggleLed(4,false);
}

// Function to check (as fast as possible) if max fill level is reached:
bool CTestboard::LoopInterruptStatus() {

  for(uint8_t channel = 0; channel < DAQ_CHANNELS; channel++) {
    if(daq_mem_base[channel] == 0) continue;
    if(Daq_GetSize(channel)*100 > LOOP_MAX_FILLLEVEL*daq_mem_size[channel]) return false;
  }
  return true;
}

// Load the Loop Interrupt values to resume at interrupt position:
void CTestboard::LoopInterruptResume(uint16_t id, uint8_t &column, uint8_t &row, size_t &dac1, size_t &dac2) {

  // Loop is resumed: turn test loop LED on:
  ToggleLed(4,true);

  // No Loop has been interrupted, just start from beginning:
  if(!LoopInterrupt) return;

  if(id != LoopInterruptId) {
    LoopInterruptReset();
    return;
  }

  // Recall the previous Loop's parameters and increemnt them by one:
  column = LoopInterruptColumn;
  row = LoopInterruptRow;
  dac1 = LoopInterruptDac1;
  dac2 = LoopInterruptDac2;
}

// Store the loop interrupt parameter to be recalled when rerunning the command:
void CTestboard::LoopInterruptStore(uint16_t id, uint8_t column, uint8_t row, size_t dac1, size_t dac2) {

  // Set the Loop Interrupt flag:
  LoopInterrupt = true;
  LoopInterruptId = id;

  LoopInterruptColumn = column;
  LoopInterruptRow = row;
  LoopInterruptDac1 = dac1;
  LoopInterruptDac2 = dac2;

  // Increment the number of interrupts:
  LoopInterruptCounter++;

  // Loop is interrupted: turn test loop LED off:
  ToggleLed(4,false);
}

// Return the Row to be pulsed with a calibrate signal
// If "xtalk" is set, move the row by one count up or down
uint8_t CTestboard::GetXtalkRow(uint8_t row, bool xtalk) {
  
  if (xtalk) {
    if (row == ROC_NUMROWS - 1) { return (row - 1); }
    else { return (row + 1); }
  }
  else { return row; }
}

// Return the calibrated DAC value - the 8bit DAC range is implemented as
// set of transistors. This results in some jumps in the spectrum of a DAC
// which needs to be flattened by flipping some DAC values. This is done
// by this function, 4bit DACs are also passed, but there the range is flat.
size_t CTestboard::CalibratedDAC(size_t value) {
  static const int dac[256] = {0, 1, 2, 3, 4, 5, 6, 8, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 24, 23, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 40, 39, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 56, 55, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 72, 71, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 88, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 104, 103, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 120, 119, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 136, 135, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 152, 151, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 184, 183, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 200, 199, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 216, 215, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 232, 231, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 248, 247, 249, 250, 251, 252, 253, 254, 255};
  return dac[value];
}

// Set the delay for the Test Loop Trigger.
// Loop trigger delay in clk cycles (40MHz) (uses cDelay() for sleeping)
void CTestboard::SetLoopTriggerDelay(uint16_t delay) {
  // FIXME maybe add some safety margin of 36clk (one roc+pixel readout)?
  LoopTriggerDelay = delay;
}

uint16_t CTestboard::GetLoopTriggerDelay() {
  // FIXME maybe add some safety margin of 36clk (one roc+pixel readout)?
  // ROC Header 12clk, Pxiel 24clk
  uint16_t readout_time = 36;
  return (readout_time > pg_delaysum ? readout_time : pg_delaysum) + LoopTriggerDelay;
}

// Setup of data storage structures in the NIOS stack. Stores all
// ROC I2C addresses to be accessed later by functions which retrieve
// trim values for a specific ROC:
bool CTestboard::SetI2CAddresses(vector<uint8_t> &roc_i2c) {

  if(roc_i2c.size() > MOD_NUMROCS) { return false; }
  printf("What I got (I2C):\n");
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    ROC_I2C_ADDRESSES[roc] = roc_i2c.at(roc);
    printf("%i: %i",roc,ROC_I2C_ADDRESSES[roc]);
  }

  return true;
}

// Upload all trimvalues of one ROC to the NIOS core to store them for looping
// over multiple pixels. Trim values > 15 are interpreted as "masked"
bool CTestboard::SetTrimValues(uint8_t roc_i2c, vector<uint8_t> &trimvalues) {

  // Get the array index of the requested ROC via its I2C address:
  size_t index = 0;
  for(index = 0; index < MOD_NUMROCS; index++) {
    if(ROC_I2C_ADDRESSES[index] == roc_i2c) { break; }
  }

  // Write the trim values into the corresponding array section:
  for(size_t val = 0; val < trimvalues.size(); val++) {
    ROC_TRIM_BITS[index*ROC_NUMROWS*ROC_NUMCOLS + val] = trimvalues.at(val);
  }
  return true;
}

// Read the trim value of one specific pixel on a given ROC and trim the pixelk if necessary:
void CTestboard::LoopPixTrim(uint8_t roc_i2c, uint8_t column, uint8_t row) {

  // Lookup the index of this particular ROC:
  size_t index = 0;
  for(index = 0; index < MOD_NUMROCS; index++) {
    if(ROC_I2C_ADDRESSES[index] == roc_i2c) { break; }
  }

  // Lookup the trim bits value of this particular pixel:
  uint8_t value = ROC_TRIM_BITS[index*ROC_NUMROWS*ROC_NUMCOLS + column*ROC_NUMROWS + row];

  // If the trim value is within the valid trim bit range (0-15) enable the pixel and trim it accordingly:
  if(value < 16) roc_Pix_Trim(column, row, value);
  // If not, do nothing - it's masked and should stay.
}


// -------- Simple Calibrate Functions for Maps -------------------------------

bool CTestboard::LoopMultiRocAllPixelsCalibrate(vector<uint8_t> &roc_i2c, uint16_t nTriggers, uint16_t flags) {

  const uint16_t LoopId = 0x356a;
  const uint16_t TriggerDelay = GetLoopTriggerDelay();

  // Check if we resume a previous loop:
  uint8_t colstart = 0, rowstart = 0;
  size_t dummy;
  LoopInterruptResume(LoopId,colstart,rowstart,dummy,dummy);

  // If FLAG_FORCE_UNMASKED is not set, mask the chip:
  if(!(flags&FLAG_FORCE_UNMASKED)) {
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Chip_Mask();
    }
  }

  // Loop over all columns:
  for (uint8_t col = colstart; col < ROC_NUMCOLS; col++) {

    // Enable this column on every configured ROC:
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Col_Enable(col, true);
    }

    // Loop over all rows:
    for (uint8_t row = rowstart; row < ROC_NUMROWS; row++) {

      // Return true if we had too many retrys:
      if(LoopInterruptCounter >= LOOP_MAX_INTERRUPTS) {
	LoopInterruptReset();
	return true;
      }
      // Interrupt the loop in case of high buffer fill level:
      else if(!LoopInterruptStatus()) {
	LoopInterruptStore(LoopId,col,row,0,0);
	return false;
      }

      // Set the calibrate bits on every configured ROC
      // Take into account both Xtalks and Cals flags
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
        roc_I2cAddr(roc_i2c.at(roc));
	// If masked, enable the pixel:
	if(!(flags&FLAG_FORCE_UNMASKED)) LoopPixTrim(roc_i2c.at(roc),col, row);
	roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
      }

      // Send the triggers:
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	// Delay the next trigger, depending in the data traffic we expect:
	cDelay(TriggerDelay);
	Pg_Single();
      }

      // Clear the calibrate signal on every ROC configured
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	roc_I2cAddr(roc_i2c.at(roc));
	if(!(flags&FLAG_FORCE_UNMASKED)) roc_Pix_Mask(col, row);
	roc_ClrCal();
      }
    } // Loop over all rows

    // Reset the rowstart:
    rowstart = 0;

    // Disable this column on every ROC configured:
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Col_Enable(col, false);
    }

  } // Loop over all columns

  // Reached the end of the loop:
  LoopInterruptReset();
  return true;
}

bool CTestboard::LoopMultiRocOnePixelCalibrate(vector<uint8_t> &roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags) {

  //const uint16_t LoopId = 0xda4b;
  const uint16_t TriggerDelay = GetLoopTriggerDelay();

  // Enable this column on every configured ROC:
  // Set the calibrate bits on every configured ROC
  // Take into account both Xtalks and Cals flags
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    if(!(flags&FLAG_FORCE_UNMASKED)) roc_Chip_Mask();
    roc_Col_Enable(column, true);
    // If masked, enable the pixel:
    if(!(flags&FLAG_FORCE_UNMASKED)) LoopPixTrim(roc_i2c.at(roc),column, row);
    roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
  }

  // Send the triggers:
  for (uint16_t trig = 0; trig < nTriggers; trig++) {
    // Delay the next trigger, depending in the data traffic we expect:
    cDelay(TriggerDelay);
    Pg_Single();
  }

  // Clear the calibrate signal on every ROC configured
  // Disable this column on every ROC configured:
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    if(!(flags&FLAG_FORCE_UNMASKED)) roc_Pix_Mask(column, row);
    roc_ClrCal();
    roc_Col_Enable(column, false);
  }

  // Reached the end of the loop:
  LoopInterruptReset();
  return true;
}

bool CTestboard::LoopSingleRocAllPixelsCalibrate(uint8_t roc_i2c, uint16_t nTriggers, uint16_t flags) {

  const uint16_t LoopId = 0x77de;
  const uint16_t TriggerDelay = GetLoopTriggerDelay();

  // Check if we resume a previous loop:
  uint8_t colstart = 0, rowstart = 0;
  size_t dummy;
  LoopInterruptResume(LoopId,colstart,rowstart,dummy,dummy);
  
  // Set the I2C output to the correct ROC:
  roc_I2cAddr(roc_i2c);
  // If FLAG_FORCE_UNMASKED is not set, mask the chip:
  if(!(flags&FLAG_FORCE_UNMASKED)) roc_Chip_Mask();

  // Loop over all columns:
  for (uint8_t col = colstart; col < ROC_NUMCOLS; col++) {

    // Enable this column on the configured ROC:
    roc_Col_Enable(col, true);

    // Loop over all rows:
    for (uint8_t row = rowstart; row < ROC_NUMROWS; row++) {

      // Return true if we had too many retrys:
      if(LoopInterruptCounter >= LOOP_MAX_INTERRUPTS) {
	LoopInterruptReset();
	return true;
      }
      // Interrupt the loop in case of high buffer fill level:
      else if(!LoopInterruptStatus()) {
	LoopInterruptStore(LoopId,col,row,0,0);
	return false;
      }

      // If masked, enable the pixel:
      if(!(flags&FLAG_FORCE_UNMASKED)) LoopPixTrim(roc_i2c,col, row);

      // Set the calibrate bits
      // Take into account both Xtalks and Cals flags
      roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

      // Send the triggers:
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	cDelay(TriggerDelay);
	Pg_Single();
      }

      // Clear the calibrate signal
      if(!(flags&FLAG_FORCE_UNMASKED)) roc_Pix_Mask(col, row);
      roc_ClrCal();
    } // Loop over all rows

    // Reset the rowstart:
    rowstart = 0;

    // Disable this column on every ROC configured:
    roc_Col_Enable(col, false);

  } // Loop over all columns

  // Reached the end of the loop:
  LoopInterruptReset();
  return true;
}

bool CTestboard::LoopSingleRocOnePixelCalibrate(uint8_t roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags) {

  //const uint16_t LoopId = 0x1b64;
  const uint16_t TriggerDelay = GetLoopTriggerDelay();

  // Enable this column on the configured ROC:
  // Set the calibrate bits on every configured ROC
  // Take into account both Xtalks and Cals flags
  roc_I2cAddr(roc_i2c);
  // If FLAG_FORCE_UNMASKED is not set, mask the chip:
  if(!(flags&FLAG_FORCE_UNMASKED)) roc_Chip_Mask();

  roc_Col_Enable(column, true);
  // If masked, enable the pixel:
  if(!(flags&FLAG_FORCE_UNMASKED)) LoopPixTrim(roc_i2c,column, row);
  roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

  // Send the triggers:
  for (uint16_t trig = 0; trig < nTriggers; trig++) {
    cDelay(TriggerDelay);
    Pg_Single();
  }

  // Clear the calibrate signal on thr ROC configured
  // Disable this column on the ROC configured:
  if(!(flags&FLAG_FORCE_UNMASKED)) roc_Pix_Mask(column, row);
  roc_ClrCal();
  roc_Col_Enable(column, false);

  // Reached the end of the loop:
  LoopInterruptReset();
  return true;
}


// -------- Trigger Loop Functions for 1D Dac Scans -------------------------------

bool CTestboard::LoopMultiRocAllPixelsDacScan(vector<uint8_t> &roc_i2c, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high) {

  const uint16_t LoopId = 0xac34;
  const uint16_t TriggerDelay = GetLoopTriggerDelay();

  // Check if we resume a previous loop:
  uint8_t colstart = 0, rowstart = 0;
  size_t dac1start = dac1low;
  size_t dummy;
  LoopInterruptResume(LoopId,colstart,rowstart,dac1start,dummy);

  // If FLAG_FORCE_UNMASKED is not set, mask the chip:
  if(!(flags&FLAG_FORCE_UNMASKED)) {
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Chip_Mask();
    }
  }

  // Loop over all columns:
  for (uint8_t col = colstart; col < ROC_NUMCOLS; col++) {

    // Enable this column on every configured ROC:
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Col_Enable(col, true);
    }

    // Loop over all rows:
    for (uint8_t row = rowstart; row < ROC_NUMROWS; row++) {

      // Set the calibrate bits on every configured ROC
      // Take into account both Xtalks and Cals flags
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	roc_I2cAddr(roc_i2c.at(roc));
	// If masked, enable the pixel:
	if(!(flags&FLAG_FORCE_UNMASKED)) LoopPixTrim(roc_i2c.at(roc),col, row);
	roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
      }

      // Loop over the DAC range specified:
      for (size_t dac1 = dac1start; dac1 <= dac1high; dac1++) {

	// Return true if we had too many retrys:
	if(LoopInterruptCounter >= LOOP_MAX_INTERRUPTS) {
	  LoopInterruptReset();
	  return true;
	}
	// Interrupt the loop in case of high buffer fill level:
	else if(!LoopInterruptStatus()) {
	  LoopInterruptStore(LoopId,col,row,dac1,0);
	  return false;
	}

	// Update the DAC setting on all configured ROCS:
	for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	  roc_I2cAddr(roc_i2c.at(roc));
	  // Check if we need to correct the DAC value to be set:
	  if(flags&FLAG_DISABLE_DACCAL) roc_SetDAC(dac1register, dac1);
	  else roc_SetDAC(dac1register, CalibratedDAC(dac1));
	}

	// Give the DAC time so settle:
	if(dac1 == dac1low) LOOP_SETDAC_DELAY_LONG;
	else { LOOP_SETDAC_DELAY_SHORT; }


	// Send the triggers:
	for (uint16_t trig = 0; trig < nTriggers; trig++) {
	  // Delay the next trigger, depending in the data traffic we expect:
	  cDelay(TriggerDelay);
	  Pg_Single();
	}
      } // Loop over the DAC range

      // Reset the dac1start:
      dac1start = dac1low;

      // Clear the calibrate signal on every ROC configured
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	roc_I2cAddr(roc_i2c.at(roc));
	if(!(flags&FLAG_FORCE_UNMASKED)) roc_Pix_Mask(col, row);
	roc_ClrCal();
      }
    } // Loop over all rows

    // Reset the rowstart:
    rowstart = 0;

    // Disable this column on every ROC configured:
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Col_Enable(col, false);
    }

  } // Loop over all columns

  // Reached the end of the loop:
  LoopInterruptReset();
  return true;
}

bool CTestboard::LoopMultiRocOnePixelDacScan(vector<uint8_t> &roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high) {

  const uint16_t LoopId = 0xc1df;
  const uint16_t TriggerDelay = GetLoopTriggerDelay();

  // Check if we resume a previous loop:
  uint8_t dummy; size_t dummy2;
  size_t dac1start = dac1low;
  LoopInterruptResume(LoopId,dummy,dummy,dac1start,dummy2);

  // Enable this column on every configured ROC:
  // Set the calibrate bits on every configured ROC
  // Take into account both Xtalks and Cals flags
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    if(!(flags&FLAG_FORCE_UNMASKED)) roc_Chip_Mask();
    roc_Col_Enable(column, true);

    // If masked, enable the pixel:
    if(!(flags&FLAG_FORCE_UNMASKED)) LoopPixTrim(roc_i2c.at(roc),column, row);

    roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
  }

  // Loop over the DAC range specified:
  for (size_t dac1 = dac1start; dac1 <= dac1high; dac1++) {

    // Return true if we had too many retrys:
    if(LoopInterruptCounter >= LOOP_MAX_INTERRUPTS) {
      LoopInterruptReset();
      return true;
    }
    // Interrupt the loop in case of high buffer fill level:
    else if(!LoopInterruptStatus()) {
      LoopInterruptStore(LoopId,0,0,dac1,0);
      return false;
    }

    // Update the DAC setting on all configured ROCS:
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      // Check if we need to correct the DAC value to be set:
      if(flags&FLAG_DISABLE_DACCAL) roc_SetDAC(dac1register, dac1);
      else roc_SetDAC(dac1register, CalibratedDAC(dac1));
    }

    // Give the DAC time so settle:
    if(dac1 == dac1low) LOOP_SETDAC_DELAY_LONG;
    else { LOOP_SETDAC_DELAY_SHORT; }


    // Send the triggers:
    for (uint16_t trig = 0; trig < nTriggers; trig++) {
      // Delay the next trigger, depending in the data traffic we expect:
      cDelay(TriggerDelay);
      Pg_Single();
    }
  } // Loop over the DAC range

  // Clear the calibrate signal on every ROC configured
  // Disable this column on every ROC configured:
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    if(!(flags&FLAG_FORCE_UNMASKED)) roc_Pix_Mask(column, row);
    roc_ClrCal();
    roc_Col_Enable(column, false);
  }

  // Reached the end of the loop:
  LoopInterruptReset();
  return true;
}

bool CTestboard::LoopSingleRocAllPixelsDacScan(uint8_t roc_i2c, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high) {

  const uint16_t LoopId = 0x902b;
  const uint16_t TriggerDelay = GetLoopTriggerDelay();

  // Check if we resume a previous loop:
  uint8_t colstart = 0, rowstart = 0;
  size_t dac1start = dac1low;
  size_t dummy;
  LoopInterruptResume(LoopId,colstart,rowstart,dac1start,dummy);

  // Set the I2C output to the correct ROC:
  roc_I2cAddr(roc_i2c);
  // If FLAG_FORCE_UNMASKED is not set, mask the chip:
  if(!(flags&FLAG_FORCE_UNMASKED)) roc_Chip_Mask();

  // Loop over all columns:
  for (uint8_t col = colstart; col < ROC_NUMCOLS; col++) {

    // Enable this column on the configured ROC:
    roc_Col_Enable(col, true);

    // Loop over all rows:
    for (uint8_t row = rowstart; row < ROC_NUMROWS; row++) {

      // If masked, enable the pixel:
      if(!(flags&FLAG_FORCE_UNMASKED)) LoopPixTrim(roc_i2c,col, row);

      // Set the calibrate bits
      // Take into account both Xtalks and Cals flags
      roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

      // Loop over the DAC range specified:
      for (size_t dac1 = dac1start; dac1 <= dac1high; dac1++) {

	// Return true if we had too many retrys:
	if(LoopInterruptCounter >= LOOP_MAX_INTERRUPTS) {
	  LoopInterruptReset();
	  return true;
	}
	// Interrupt the loop in case of high buffer fill level:
	else if(!LoopInterruptStatus()) {
	  LoopInterruptStore(LoopId,col,row,dac1,0);
	  return false;
	}

	// Update the DAC setting on the ROC:
	// Check if we need to correct the DAC value to be set:
	if(flags&FLAG_DISABLE_DACCAL) roc_SetDAC(dac1register, dac1);
	else roc_SetDAC(dac1register, CalibratedDAC(dac1));

	// Give the DAC time so settle from dac1high to dac1low
	if(dac1 == dac1low) LOOP_SETDAC_DELAY_LONG;
	else { LOOP_SETDAC_DELAY_SHORT; }


	// Send the triggers:
	for (uint16_t trig = 0; trig < nTriggers; trig++) {
	  cDelay(TriggerDelay);
	  Pg_Single();
	}
      } // Loop over the DAC range

      // Reset the dac1start:
      dac1start = dac1low;

      // Clear the calibrate signal
      if(!(flags&FLAG_FORCE_UNMASKED)) roc_Pix_Mask(col, row);
      roc_ClrCal();
    } // Loop over all rows

    // Reset the rowstart:
    rowstart = 0;

    // Disable this column on every ROC configured:
    roc_Col_Enable(col, false);

  } // Loop over all columns

  // Reached the end of the loop:
  LoopInterruptReset();
  return true;
}

bool CTestboard::LoopSingleRocOnePixelDacScan(uint8_t roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high) {

  const uint16_t LoopId = 0xfe5d;
  const uint16_t TriggerDelay = GetLoopTriggerDelay();

  // Check if we resume a previous loop:
  uint8_t dummy; size_t dummy2;
  size_t dac1start = dac1low;
  LoopInterruptResume(LoopId,dummy,dummy,dac1start,dummy2);

  // Enable this column on the configured ROC:
  // Set the calibrate bits on every configured ROC
  // Take into account both Xtalks and Cals flags
  roc_I2cAddr(roc_i2c);
  // If FLAG_FORCE_UNMASKED is not set, mask the chip:
  if(!(flags&FLAG_FORCE_UNMASKED)) roc_Chip_Mask();

  roc_Col_Enable(column, true);
  // If masked, enable the pixel:
  if(!(flags&FLAG_FORCE_UNMASKED)) LoopPixTrim(roc_i2c,column, row);
  roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

  // Loop over the DAC range specified:
  for (size_t dac1 = dac1start; dac1 <= dac1high; dac1++) {

    // Return true if we had too many retrys:
    if(LoopInterruptCounter >= LOOP_MAX_INTERRUPTS) {
      LoopInterruptReset();
      return true;
    }
    // Interrupt the loop in case of high buffer fill level:
    else if(!LoopInterruptStatus()) {
      LoopInterruptStore(LoopId,0,0,dac1,0);
      return false;
    }

    // Update the DAC setting on the ROC:
    // Check if we need to correct the DAC value to be set:
    if(flags&FLAG_DISABLE_DACCAL) roc_SetDAC(dac1register, dac1);
    else roc_SetDAC(dac1register, CalibratedDAC(dac1));

    // Give the DAC time so settle:
    if(dac1 == dac1low) LOOP_SETDAC_DELAY_LONG;
    else { LOOP_SETDAC_DELAY_SHORT; }

    // Send the triggers:
    for (uint16_t trig = 0; trig < nTriggers; trig++) {
      cDelay(TriggerDelay);
      Pg_Single();
    }
  } // Loop over the DAC range

  // Clear the calibrate signal on thr ROC configured
  // Disable this column on the ROC configured:
  if(!(flags&FLAG_FORCE_UNMASKED)) roc_Pix_Mask(column, row);
  roc_ClrCal();
  roc_Col_Enable(column, false);

  // Reached the end of the loop:
  LoopInterruptReset();
  return true;
}

// -------- Trigger Loop Functions for 2D DacDac Scans ----------------------------

bool CTestboard::LoopMultiRocAllPixelsDacDacScan(vector<uint8_t> &roc_i2c, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high, uint8_t dac2register, uint8_t dac2low, uint8_t dac2high) {

  const uint16_t LoopId = 0x0ade;
  const uint16_t TriggerDelay = GetLoopTriggerDelay();

  // Check if we resume a previous loop:
  uint8_t colstart = 0, rowstart = 0;
  size_t dac1start = dac1low, dac2start = dac2low;
  LoopInterruptResume(LoopId,colstart,rowstart,dac1start,dac2start);

  // If FLAG_FORCE_UNMASKED is not set, mask the chip:
  if(!(flags&FLAG_FORCE_UNMASKED)) {
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Chip_Mask();
    }
  }

  // Loop over all columns:
  for (uint8_t col = colstart; col < ROC_NUMCOLS; col++) {

    // Enable this column on every configured ROC:
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Col_Enable(col, true);
    }

    // Loop over all rows:
    for (uint8_t row = rowstart; row < ROC_NUMROWS; row++) {

      // Set the calibrate bits on every configured ROC
      // Take into account both Xtalks and Cals flags
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	roc_I2cAddr(roc_i2c.at(roc));
	// If masked, enable the pixel:
	if(!(flags&FLAG_FORCE_UNMASKED)) LoopPixTrim(roc_i2c.at(roc),col, row);
	roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
      }

      // Loop over the DAC1 range specified:
      for (size_t dac1 = dac1start; dac1 <= dac1high; dac1++) {

	// Update the DAC1 setting on all configured ROCS:
	for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	  roc_I2cAddr(roc_i2c.at(roc));
	  // Check if we need to correct the DAC value to be set:
	  if(flags&FLAG_DISABLE_DACCAL) roc_SetDAC(dac1register, dac1);
	  else roc_SetDAC(dac1register, CalibratedDAC(dac1));
	}

	// Loop over the DAC2 range specified:
	for (size_t dac2 = dac2start; dac2 <= dac2high; dac2++) {

	  // Return true if we had too many retrys:
	  if(LoopInterruptCounter >= LOOP_MAX_INTERRUPTS) {
	    LoopInterruptReset();
	    return true;
	  }
	  // Interrupt the loop in case of high buffer fill level:
	  else if(!LoopInterruptStatus()) {
	    LoopInterruptStore(LoopId,col,row,dac1,dac2);
	    return false;
	  }

	  // Update the DAC2 setting on all configured ROCS:
	  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	    roc_I2cAddr(roc_i2c.at(roc));
	    // Check if we need to correct the DAC value to be set:
	    if(flags&FLAG_DISABLE_DACCAL) roc_SetDAC(dac2register, dac2);
	    else roc_SetDAC(dac2register, CalibratedDAC(dac2));
	  }

	  // Give the DAC time so settle:
	  if(dac2 == dac2low) LOOP_SETDAC_DELAY_LONG;
	  else { LOOP_SETDAC_DELAY_SHORT; }

	  // Send the triggers:
	  for (uint16_t trig = 0; trig < nTriggers; trig++) {
	    // Delay the next trigger, depending in the data traffic we expect:
	    cDelay(TriggerDelay);
	    Pg_Single();
	  }
	} // Loop over the DAC2 range

	// Reset the dac2start:
	dac2start = dac2low;

      } // Loop over the DAC1 range

      // Reset the dac1start:
      dac1start = dac1low;

      // Clear the calibrate signal on every ROC configured
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	roc_I2cAddr(roc_i2c.at(roc));
	if(!(flags&FLAG_FORCE_UNMASKED)) roc_Pix_Mask(col, row);
	roc_ClrCal();
      }
    } // Loop over all rows

    // Reset the rowstart:
    rowstart = 0;

    // Disable this column on every ROC configured:
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Col_Enable(col, false);
    }

  } // Loop over all columns

  // Reached the end of the loop:
  LoopInterruptReset();
  return true;
}

bool CTestboard::LoopMultiRocOnePixelDacDacScan(vector<uint8_t> &roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high, uint8_t dac2register, uint8_t dac2low, uint8_t dac2high) {

  const uint16_t LoopId = 0xb1d5;
  const uint16_t TriggerDelay = GetLoopTriggerDelay();

  // Check if we resume a previous loop:
  uint8_t dummy;
  size_t dac1start = dac1low, dac2start = dac2low;
  LoopInterruptResume(LoopId,dummy,dummy,dac1start,dac2start);

  // Enable this column on every configured ROC:
  // Set the calibrate bits on every configured ROC
  // Take into account both Xtalks and Cals flags
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    if(!(flags&FLAG_FORCE_UNMASKED)) roc_Chip_Mask();
    roc_Col_Enable(column, true);
    // If masked, enable the pixel:
    if(!(flags&FLAG_FORCE_UNMASKED)) LoopPixTrim(roc_i2c.at(roc),column, row);
    roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
  }

  // Loop over the DAC1 range specified:
  for (size_t dac1 = dac1start; dac1 <= dac1high; dac1++) {
    
    // Update the DAC1 setting on all configured ROCS:
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      // Check if we need to correct the DAC value to be set:
      if(flags&FLAG_DISABLE_DACCAL) roc_SetDAC(dac1register, dac1);
      else roc_SetDAC(dac1register, CalibratedDAC(dac1));
    }

    // Loop over the DAC2 range specified:
    for (size_t dac2 = dac2start; dac2 <= dac2high; dac2++) {

      // Return true if we had too many retrys:
      if(LoopInterruptCounter >= LOOP_MAX_INTERRUPTS) {
	LoopInterruptReset();
	return true;
      }
      // Interrupt the loop in case of high buffer fill level:
      else if(!LoopInterruptStatus()) {
	LoopInterruptStore(LoopId,0,0,dac1,dac2);
	return false;
      }

      // Update the DAC2 setting on all configured ROCS:
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	roc_I2cAddr(roc_i2c.at(roc));
	// Check if we need to correct the DAC value to be set:
	if(flags&FLAG_DISABLE_DACCAL) roc_SetDAC(dac2register, dac2);
	else roc_SetDAC(dac2register, CalibratedDAC(dac2));
      }

      // Give the DAC time so settle:
      if(dac2 == dac2low) LOOP_SETDAC_DELAY_LONG;
      else { LOOP_SETDAC_DELAY_SHORT; }

      // Send the triggers:
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	// Delay the next trigger, depending in the data traffic we expect:
        cDelay(TriggerDelay);
	Pg_Single();
      }
    } // Loop over the DAC2 range

    // Reset the dac2start:
    dac2start = dac2low;

  } // Loop over the DAC1 range

  // Clear the calibrate signal on every ROC configured
  // Disable this column on every ROC configured:
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    if(!(flags&FLAG_FORCE_UNMASKED)) roc_Pix_Mask(column, row);
    roc_ClrCal();
    roc_Col_Enable(column, false);
  }

  // Reached the end of the loop:
  LoopInterruptReset();
  return true;
}

bool CTestboard::LoopSingleRocAllPixelsDacDacScan(uint8_t roc_i2c, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high, uint8_t dac2register, uint8_t dac2low, uint8_t dac2high) {

  const uint16_t LoopId = 0x17ba;
  const uint16_t TriggerDelay = GetLoopTriggerDelay();

  // Check if we resume a previous loop:
  uint8_t colstart = 0, rowstart = 0;
  size_t dac1start = dac1low, dac2start = dac2low;
  LoopInterruptResume(LoopId,colstart,rowstart,dac1start,dac2start);

  // Set the I2C output to the correct ROC:
  roc_I2cAddr(roc_i2c);
  // If FLAG_FORCE_UNMASKED is not set, mask the chip:
  if(!(flags&FLAG_FORCE_UNMASKED)) roc_Chip_Mask();

  // Loop over all columns:
  for (uint8_t col = colstart; col < ROC_NUMCOLS; col++) {

    // Enable this column on the configured ROC:
    roc_Col_Enable(col, true);

    // Loop over all rows:
    for (uint8_t row = rowstart; row < ROC_NUMROWS; row++) {

      // If masked, enable the pixel:
      if(!(flags&FLAG_FORCE_UNMASKED)) LoopPixTrim(roc_i2c,col, row);

      // Set the calibrate bits
      // Take into account both Xtalks and Cals flags
      roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

      // Loop over the DAC1 range specified:
      for (size_t dac1 = dac1start; dac1 <= dac1high; dac1++) {
    
	// Update the DAC1 setting on the configured ROC:
	// Check if we need to correct the DAC value to be set:
	if(flags&FLAG_DISABLE_DACCAL) roc_SetDAC(dac1register, dac1);
	else roc_SetDAC(dac1register, CalibratedDAC(dac1));

	// Loop over the DAC2 range specified:
	for (size_t dac2 = dac2start; dac2 <= dac2high; dac2++) {

	  // Return true if we had too many retrys:
	  if(LoopInterruptCounter >= LOOP_MAX_INTERRUPTS) {
	    LoopInterruptReset();
	    return true;
	  }
	  // Interrupt the loop in case of high buffer fill level:
	  else if(!LoopInterruptStatus()) {
	    LoopInterruptStore(LoopId,col,row,dac1,dac2);
	    return false;
	  }

	  // Update the DAC2 setting on the configured ROC:
	  // Check if we need to correct the DAC value to be set:
	  if(flags&FLAG_DISABLE_DACCAL) roc_SetDAC(dac2register, dac2);
	  else roc_SetDAC(dac2register, CalibratedDAC(dac2));

	  // Give the DAC time so settle:
	  if(dac2 == dac2low) LOOP_SETDAC_DELAY_LONG;
	  else { LOOP_SETDAC_DELAY_SHORT; }

	  // Send the triggers:
	  for (uint16_t trig = 0; trig < nTriggers; trig++) {
	    cDelay(TriggerDelay);
	    Pg_Single();
	  }
	} // Loop over the DAC2 range

	// Reset the dac2start:
	dac2start = dac2low;

      } // Loop over the DAC1 range

      // Reset the dac1start:
      dac1start = dac1low;

      // Clear the calibrate signal
      if(!(flags&FLAG_FORCE_UNMASKED)) roc_Pix_Mask(col, row);
      roc_ClrCal();
    } // Loop over all rows

      // Reset the rowstart:
      rowstart = 0;

    // Disable this column on every ROC configured:
    roc_Col_Enable(col, false);

  } // Loop over all columns

  // Reached the end of the loop:
  LoopInterruptReset();
  return true;
}

bool CTestboard::LoopSingleRocOnePixelDacDacScan(uint8_t roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high, uint8_t dac2register, uint8_t dac2low, uint8_t dac2high) {

  const uint16_t LoopId = 0x7b52;
  const uint16_t TriggerDelay = GetLoopTriggerDelay();

  // Check if we resume a previous loop:
  uint8_t dummy;
  size_t dac1start = dac1low, dac2start = dac2low;
  LoopInterruptResume(LoopId,dummy,dummy,dac1start,dac2start);

  // Enable this column on the configured ROC:
  // Set the calibrate bits on every configured ROC
  // Take into account both Xtalks and Cals flags
  roc_I2cAddr(roc_i2c);
  // If FLAG_FORCE_UNMASKED is not set, mask the chip:
  if(!(flags&FLAG_FORCE_UNMASKED)) roc_Chip_Mask();

  roc_Col_Enable(column, true);
  // If masked, enable the pixel:
  if(!(flags&FLAG_FORCE_UNMASKED)) LoopPixTrim(roc_i2c,column, row);
  roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

  // Loop over the DAC range specified:
  for (size_t dac1 = dac1start; dac1 <= dac1high; dac1++) {

    // Update the DAC1 setting on the configured ROC:
    // Check if we need to correct the DAC value to be set:
    if(flags&FLAG_DISABLE_DACCAL) roc_SetDAC(dac1register, dac1);
    else roc_SetDAC(dac1register, CalibratedDAC(dac1));

    // Loop over the DAC2 range specified:
    for (size_t dac2 = dac2start; dac2 <= dac2high; dac2++) {

      // Return true if we had too many retrys:
      if(LoopInterruptCounter >= LOOP_MAX_INTERRUPTS) {
	LoopInterruptReset();
	return true;
      }
      // Interrupt the loop in case of high buffer fill level:
      else if(!LoopInterruptStatus()) {
	LoopInterruptStore(LoopId,0,0,dac1,dac2);
	return false;
      }

      // Update the DAC2 setting on the configured ROC:
      // Check if we need to correct the DAC value to be set:
      if(flags&FLAG_DISABLE_DACCAL) roc_SetDAC(dac2register, dac2);
      else roc_SetDAC(dac2register, CalibratedDAC(dac2));

      // Give the DAC time so settle after setting:
      if(dac2 == dac2low) LOOP_SETDAC_DELAY_LONG;
      else { LOOP_SETDAC_DELAY_SHORT; }

      // Send the triggers:
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	cDelay(TriggerDelay);
	Pg_Single();
      }
    } // Loop over the DAC2 range

    // Reset the dac2start:
    dac2start = dac2low;

  } // Loop over the DAC1 range

  // Clear the calibrate signal on the ROC configured
  // Disable this column on the ROC configured:
  if(!(flags&FLAG_FORCE_UNMASKED)) roc_Pix_Mask(column, row);
  roc_ClrCal();
  roc_Col_Enable(column, false);

  // Reached the end of the loop:
  LoopInterruptReset();
  return true;
}
