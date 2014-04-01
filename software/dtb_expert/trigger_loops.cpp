// trigger_loops.cpp

#include "dtb_hal.h"
#include "pixel_dtb.h"
#include "dtb_config.h"
#include "rpc.h"

#define TRIGGER_DELAY 4

// -------- Helper Functions -------------------------------

// Return the Row to be pulsed with a calibrate signal
// If "xtalk" is set, move the row by one count up or down
uint8_t CTestboard::GetXtalkRow(uint8_t row, bool xtalk) {
  
  if (xtalk) {
    if (row == ROC_NUMROWS - 1) { return (row - 1); }
    else { return (row + 1); }
  }
  else { return row; }
}


// -------- Simple Calibrate Functions for Maps -------------------------------

void CTestboard::LoopMultiRocAllPixelsCalibrate(vector<uint8_t> &roc_i2c, uint16_t nTriggers, uint16_t flags) {

  // If FLAG_FORCE_MASKED is set, mask the chip:
  if(flags&FLAG_FORCE_MASKED) {
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Chip_Mask();
    }
  }

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
	// If masked, enable the pixel:
	if(flags&FLAG_FORCE_MASKED) roc_Pix_Trim(col, row, 15);
	roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
      }

      // Send the triggers:
      uDelay(5);
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	    Pg_Single();
	    // Delay the next trigger, depending in the data traffic we expect:
	    uDelay(TRIGGER_DELAY*roc_i2c.size());
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
    if(flags&FLAG_FORCE_MASKED) roc_Chip_Mask();
    roc_Col_Enable(column, true);
    // If masked, enable the pixel:
    if(flags&FLAG_FORCE_MASKED) roc_Pix_Trim(column, row, 15);
    roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
  }

  // Send the triggers:
  uDelay(5);
  for (uint16_t trig = 0; trig < nTriggers; trig++) {
    Pg_Single();
    // Delay the next trigger, depending in the data traffic we expect:
    uDelay(TRIGGER_DELAY*roc_i2c.size());
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
  // If FLAG_FORCE_MASKED is set, mask the chip:
  if(flags&FLAG_FORCE_MASKED) roc_Chip_Mask();

  // Loop over all columns:
  for (uint8_t col = 0; col < ROC_NUMCOLS; col++) {

    // Enable this column on the configured ROC:
    roc_Col_Enable(col, true);

    // Loop over all rows:
    for (uint8_t row = 0; row < ROC_NUMROWS; row++) {

      // If masked, enable the pixel:
      if(flags&FLAG_FORCE_MASKED) roc_Pix_Trim(col, row, 15);

      // Set the calibrate bits
      // Take into account both Xtalks and Cals flags
      roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

      // Send the triggers:
      uDelay(5);
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	    Pg_Single();
	    uDelay(TRIGGER_DELAY);
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
  // If FLAG_FORCE_MASKED is set, mask the chip:
  if(flags&FLAG_FORCE_MASKED) roc_Chip_Mask();

  roc_Col_Enable(column, true);
  // If masked, enable the pixel:
  if(flags&FLAG_FORCE_MASKED) roc_Pix_Trim(column, row, 15);
  roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

  // Send the triggers:
  uDelay(5);
  for (uint16_t trig = 0; trig < nTriggers; trig++) {
    Pg_Single();
    uDelay(TRIGGER_DELAY);
  }

  // Clear the calibrate signal on thr ROC configured
  // Disable this column on the ROC configured:
  roc_ClrCal();
  roc_Col_Enable(column, false);
}


// -------- Trigger Loop Functions for 1D Dac Scans -------------------------------

void CTestboard::LoopMultiRocAllPixelsDacScan(vector<uint8_t> &roc_i2c, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high) {

  // If FLAG_FORCE_MASKED is set, mask the chip:
  if(flags&FLAG_FORCE_MASKED) {
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Chip_Mask();
    }
  }

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
	    // If masked, enable the pixel:
	    if(flags&FLAG_FORCE_MASKED) roc_Pix_Trim(col, row, 15);
	    roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
      }

      // Loop over the DAC range specified:
      for (size_t dac1 = dac1low; dac1 <= dac1high; dac1++) {

	// Update the DAC setting on all configured ROCS:
	for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	  roc_I2cAddr(roc_i2c.at(roc));
	  roc_SetDAC(dac1register, dac1);
	}

	// Send the triggers:
	uDelay(5);
	for (uint16_t trig = 0; trig < nTriggers; trig++) {
	  Pg_Single();
	  // Delay the next trigger, depending in the data traffic we expect:
	  uDelay(TRIGGER_DELAY*roc_i2c.size());
	}
      } // Loop over the DAC range

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

void CTestboard::LoopMultiRocOnePixelDacScan(vector<uint8_t> &roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high) {

  // Enable this column on every configured ROC:
  // Set the calibrate bits on every configured ROC
  // Take into account both Xtalks and Cals flags
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    if(flags&FLAG_FORCE_MASKED) roc_Chip_Mask();
    roc_Col_Enable(column, true);

    // If masked, enable the pixel:
    if(flags&FLAG_FORCE_MASKED) roc_Pix_Trim(column, row, 15);

    roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
  }

  // Loop over the DAC range specified:
  for (size_t dac1 = dac1low; dac1 <= dac1high; dac1++) {

    // Update the DAC setting on all configured ROCS:
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_SetDAC(dac1register, dac1);
    }

    // Send the triggers:
    uDelay(5);
    for (uint16_t trig = 0; trig < nTriggers; trig++) {
      Pg_Single();
      // Delay the next trigger, depending in the data traffic we expect:
      uDelay(TRIGGER_DELAY*roc_i2c.size());
    }
  } // Loop over the DAC range

  // Clear the calibrate signal on every ROC configured
  // Disable this column on every ROC configured:
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    roc_ClrCal();
    roc_Col_Enable(column, false);
  }
}

void CTestboard::LoopSingleRocAllPixelsDacScan(uint8_t roc_i2c, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high) {

  // Set the I2C output to the correct ROC:
  roc_I2cAddr(roc_i2c);
  // If FLAG_FORCE_MASKED is set, mask the chip:
  if(flags&FLAG_FORCE_MASKED) roc_Chip_Mask();

  // Loop over all columns:
  for (uint8_t col = 0; col < ROC_NUMCOLS; col++) {

    // Enable this column on the configured ROC:
    roc_Col_Enable(col, true);

    // Loop over all rows:
    for (uint8_t row = 0; row < ROC_NUMROWS; row++) {

      // If masked, enable the pixel:
      if(flags&FLAG_FORCE_MASKED) roc_Pix_Trim(col, row, 15);

      // Set the calibrate bits
      // Take into account both Xtalks and Cals flags
      roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

      // Loop over the DAC range specified:
      for (size_t dac1 = dac1low; dac1 <= dac1high; dac1++) {

	// Update the DAC setting on the ROC:
	roc_SetDAC(dac1register, dac1);

	// Send the triggers:
	uDelay(5);
	for (uint16_t trig = 0; trig < nTriggers; trig++) {
	  Pg_Single();
	  uDelay(TRIGGER_DELAY);
	}
      } // Loop over the DAC range

      // Clear the calibrate signal
      roc_ClrCal();
    } // Loop over all rows

    // Disable this column on every ROC configured:
    roc_Col_Enable(col, false);

  } // Loop over all columns
}

void CTestboard::LoopSingleRocOnePixelDacScan(uint8_t roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high) {

  // Enable this column on the configured ROC:
  // Set the calibrate bits on every configured ROC
  // Take into account both Xtalks and Cals flags
  roc_I2cAddr(roc_i2c);
  // If FLAG_FORCE_MASKED is set, mask the chip:
  if(flags&FLAG_FORCE_MASKED) roc_Chip_Mask();

  roc_Col_Enable(column, true);
  // If masked, enable the pixel:
  if(flags&FLAG_FORCE_MASKED) roc_Pix_Trim(column, row, 15);
  roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

  // Loop over the DAC range specified:
  for (size_t dac = dac1low; dac <= dac1high; dac++) {

    // Update the DAC setting on the ROC:
    roc_SetDAC(dac1register, dac);

    // Send the triggers:
    uDelay(5);
    for (uint16_t trig = 0; trig < nTriggers; trig++) {
      Pg_Single();
      uDelay(TRIGGER_DELAY);
    }
  } // Loop over the DAC range

  // Clear the calibrate signal on thr ROC configured
  // Disable this column on the ROC configured:
  roc_ClrCal();
  roc_Col_Enable(column, false);
}

// -------- Trigger Loop Functions for 2D DacDac Scans ----------------------------

void CTestboard::LoopMultiRocAllPixelsDacDacScan(vector<uint8_t> &roc_i2c, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high, uint8_t dac2register, uint8_t dac2low, uint8_t dac2high) {

  // If FLAG_FORCE_MASKED is set, mask the chip:
  if(flags&FLAG_FORCE_MASKED) {
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_Chip_Mask();
    }
  }

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
	// If masked, enable the pixel:
	if(flags&FLAG_FORCE_MASKED) roc_Pix_Trim(col, row, 15);
	roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
      }

      // Loop over the DAC1 range specified:
      for (size_t dac1 = dac1low; dac1 <= dac1high; dac1++) {

	// Update the DAC1 setting on all configured ROCS:
	for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	  roc_I2cAddr(roc_i2c.at(roc));
	  roc_SetDAC(dac1register, dac1);
	}

	// Loop over the DAC2 range specified:
	for (size_t dac2 = dac2low; dac2 <= dac2high; dac2++) {

	  // Update the DAC2 setting on all configured ROCS:
	  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	    roc_I2cAddr(roc_i2c.at(roc));
	    roc_SetDAC(dac2register, dac2);
	  }

	  // Send the triggers:
	  uDelay(5);
	  for (uint16_t trig = 0; trig < nTriggers; trig++) {
	    Pg_Single();
	    // Delay the next trigger, depending in the data traffic we expect:
	    uDelay(TRIGGER_DELAY*roc_i2c.size());
	  }
	} // Loop over the DAC2 range
      } // Loop over the DAC1 range

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

void CTestboard::LoopMultiRocOnePixelDacDacScan(vector<uint8_t> &roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high, uint8_t dac2register, uint8_t dac2low, uint8_t dac2high) {

  // Enable this column on every configured ROC:
  // Set the calibrate bits on every configured ROC
  // Take into account both Xtalks and Cals flags
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    if(flags&FLAG_FORCE_MASKED) roc_Chip_Mask();
    roc_Col_Enable(column, true);
    // If masked, enable the pixel:
    if(flags&FLAG_FORCE_MASKED) roc_Pix_Trim(column, row, 15);
    roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
  }

  // Loop over the DAC1 range specified:
  for (size_t dac1 = dac1low; dac1 <= dac1high; dac1++) {
    
    // Update the DAC1 setting on all configured ROCS:
    for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
      roc_I2cAddr(roc_i2c.at(roc));
      roc_SetDAC(dac1register, dac1);
    }

    // Loop over the DAC2 range specified:
    for (size_t dac2 = dac2low; dac2 <= dac2high; dac2++) {

      // Update the DAC2 setting on all configured ROCS:
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	roc_I2cAddr(roc_i2c.at(roc));
	roc_SetDAC(dac2register, dac2);
      }

      // Send the triggers:
      uDelay(5);
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	    Pg_Single();
	    // Delay the next trigger, depending in the data traffic we expect:
        uDelay(TRIGGER_DELAY*roc_i2c.size());
      }
    } // Loop over the DAC2 range
  } // Loop over the DAC1 range

  // Clear the calibrate signal on every ROC configured
  // Disable this column on every ROC configured:
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    roc_ClrCal();
    roc_Col_Enable(column, false);
  }
}

void CTestboard::LoopSingleRocAllPixelsDacDacScan(uint8_t roc_i2c, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high, uint8_t dac2register, uint8_t dac2low, uint8_t dac2high) {

  // Set the I2C output to the correct ROC:
  roc_I2cAddr(roc_i2c);
  // If FLAG_FORCE_MASKED is set, mask the chip:
  if(flags&FLAG_FORCE_MASKED) roc_Chip_Mask();

  // Loop over all columns:
  for (uint8_t col = 0; col < ROC_NUMCOLS; col++) {

    // Enable this column on the configured ROC:
    roc_Col_Enable(col, true);

    // Loop over all rows:
    for (uint8_t row = 0; row < ROC_NUMROWS; row++) {

      // If masked, enable the pixel:
      if(flags&FLAG_FORCE_MASKED) roc_Pix_Trim(col, row, 15);

      // Set the calibrate bits
      // Take into account both Xtalks and Cals flags
      roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

      // Loop over the DAC1 range specified:
      for (size_t dac1 = dac1low; dac1 <= dac1high; dac1++) {
    
	// Update the DAC1 setting on the configured ROC:
	roc_SetDAC(dac1register, dac1);

	// Loop over the DAC2 range specified:
	for (size_t dac2 = dac2low; dac2 <= dac2high; dac2++) {

	  // Update the DAC2 setting on the configured ROC:
	  roc_SetDAC(dac2register, dac2);

	  // Send the triggers:
	  uDelay(5);
	  for (uint16_t trig = 0; trig < nTriggers; trig++) {
	    Pg_Single();
	    uDelay(TRIGGER_DELAY);
	  }
	} // Loop over the DAC2 range
      } // Loop over the DAC1 range

      // Clear the calibrate signal
      roc_ClrCal();
    } // Loop over all rows

    // Disable this column on every ROC configured:
    roc_Col_Enable(col, false);

  } // Loop over all columns
}

void CTestboard::LoopSingleRocOnePixelDacDacScan(uint8_t roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high, uint8_t dac2register, uint8_t dac2low, uint8_t dac2high) {

  // Enable this column on the configured ROC:
  // Set the calibrate bits on every configured ROC
  // Take into account both Xtalks and Cals flags
  roc_I2cAddr(roc_i2c);
  // If FLAG_FORCE_MASKED is set, mask the chip:
  if(flags&FLAG_FORCE_MASKED) roc_Chip_Mask();

  roc_Col_Enable(column, true);
  // If masked, enable the pixel:
  if(flags&FLAG_FORCE_MASKED) roc_Pix_Trim(column, row, 15);
  roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

  // Loop over the DAC range specified:
  for (size_t dac1 = dac1low; dac1 <= dac1high; dac1++) {
    
    // Update the DAC1 setting on the configured ROC:
    roc_SetDAC(dac1register, dac1);

    // Loop over the DAC2 range specified:
    for (size_t dac2 = dac2low; dac2 <= dac2high; dac2++) {

      // Update the DAC2 setting on the configured ROC:
      roc_SetDAC(dac2register, dac2);

      // Send the triggers:
      uDelay(5);
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	Pg_Single();
	uDelay(TRIGGER_DELAY);
      }
    } // Loop over the DAC2 range
  } // Loop over the DAC1 range

  // Clear the calibrate signal on thr ROC configured
  // Disable this column on the ROC configured:
  roc_ClrCal();
  roc_Col_Enable(column, false);
}
