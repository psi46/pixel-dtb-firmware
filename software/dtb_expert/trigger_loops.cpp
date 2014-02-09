// trigger_loops.cpp

#include "dtb_hal.h"
#include "pixel_dtb.h"
#include "dtb_config.h"
#include "rpc.h"

// Return the Row to be pulsed with a calibrate signal
// If "xtalk" is set, move the row by one count up or down
uint8_t GetXtalkRow(uint8_t row, bool xtalk) {
  
  if (xtalk) {
    if (row == ROC_NUMROWS - 1) { return (row - 1); }
    else { return (row + 1); }
  }
  else { return row; }
}


// -------- Simple Calibrate Functions for Maps -------------------------------

void CTestboard::LoopMultiRocAllPixelsCalibrate(vector<uint8_t> &roc_i2c, uint16_t nTriggers, uint16_t flags) {

  // Loop over all columns:
  for (uint8_t col = 0; col < ROC_NUMCOLS; col++) {

    // Enable this column on every configured ROC:
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Col_Enable(col, true);
    }

    // Loop over all rows:
    for (uint8_t row = 0; row < ROC_NUMROWS; row++) {

      // Set the calibrate bits on every configured ROC
      // Take into account both Xtalks and Cals flags
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	roc_I2cAddr(roc_i2c.at(roc));
	roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
      }

      uDelay(5);

      // Send the triggers:
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	Pg_Single();
	uDelay(4);
      }

      // Clear the calibrate signal on every ROC configured
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	roc_I2cAddr(roc_i2c.at(roc));
	roc_ClrCal();
      }
    } // Loop over all rows

    // Disable this column on every ROC configured:
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Col_Enable(col, false);
    }

  } // Loop over all columns
}

void CTestboard::LoopMultiRocOnePixelCalibrate(vector<uint8_t> &roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags) {

  // Enable this column on every configured ROC:
  // Set the calibrate bits on every configured ROC
  // Take into account both Xtalks and Cals flags
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    roc_Col_Enable(column, true);
    roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
  }

  uDelay(5);

  // Send the triggers:
  for (uint16_t trig = 0; trig < nTriggers; trig++) {
    Pg_Single();
    uDelay(4);
  }

  // Clear the calibrate signal on every ROC configured
  // Disable this column on every ROC configured:
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    roc_ClrCal();
    roc_Col_Enable(column, false);
  }
}

void CTestboard::LoopSingleRocAllPixelsCalibrate(uint8_t roc_i2c, uint16_t nTriggers, uint16_t flags) {

  // Set the I2C output to the correct ROC:
  roc_I2cAddr(roc_i2c);

  // Loop over all columns:
  for (uint8_t col = 0; col < ROC_NUMCOLS; col++) {

    // Enable this column on the configured ROC:
    roc_Col_Enable(col, true);

    // Loop over all rows:
    for (uint8_t row = 0; row < ROC_NUMROWS; row++) {

      // Set the calibrate bits
      // Take into account both Xtalks and Cals flags
      roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
      uDelay(5);

      // Send the triggers:
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	Pg_Single();
	uDelay(4);
      }

      // Clear the calibrate signal
      roc_ClrCal();
    } // Loop over all rows

    // Disable this column on every ROC configured:
    roc_Col_Enable(col, false);

  } // Loop over all columns
}

void CTestboard::LoopSingleRocOnePixelCalibrate(uint8_t roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags) {

  // Enable this column on the configured ROC:
  // Set the calibrate bits on every configured ROC
  // Take into account both Xtalks and Cals flags
  roc_I2cAddr(roc_i2c);
  roc_Col_Enable(column, true);
  roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

  uDelay(5);

  // Send the triggers:
  for (uint16_t trig = 0; trig < nTriggers; trig++) {
    Pg_Single();
    uDelay(4);
  }

  // Clear the calibrate signal on thr ROC configured
  // Disable this column on the ROC configured:
  roc_ClrCal();
  roc_Col_Enable(column, false);
}
