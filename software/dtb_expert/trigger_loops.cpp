// trigger_loops.cpp

#include "dtb_hal.h"
#include "pixel_dtb.h"
#include "dtb_config.h"
#include "rpc.h"

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

uint8_t CTestboard::GetTrimValue(uint8_t roc_i2c, uint8_t column, uint8_t row) {

	// Lookup the trim bits value of this particular pixel from a huge map stored somewhere in the NIOS
	// trim[MOD_NUMROCS*ROC_NUMCOLS*ROC_NUMCOLS]
	return 0xf;
}

bool CTestboard::GetMaskState(unit8_t roc_i2c, uint8_t column, uint8_t row) {

	// Lookup the mask state of this particular pixel from a huge map stored somewhere in the NIOS
	// mask[MOD_NUMROCS*ROC_NUMCOLS*ROC_NUMCOLS]
	return false;
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
        if(!GetMaskState(roc_i2c.at(roc),col,row)) roc_Pix_Trim(col, row, GetTrimValue(roc_i2c.at(roc),col,row));
	    roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
      }

      // Send the triggers:
      uDelay(5);
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	    Pg_Single();
	    // Delay the next trigger, depending in the data traffic we expect:
	    uDelay(4*roc_i2c.size());
      }

      // Clear the calibrate signal on every ROC configured
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	    roc_I2cAddr(roc_i2c.at(roc));
	    roc_Pix_Mask(col,row);
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
    if(!GetMaskState(roc_i2c.at(roc),column,row)) roc_Pix_Trim(column, row, GetTrimValue(roc_i2c.at(roc),column,row));
    roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
  }

  // Send the triggers:
  uDelay(5);
  for (uint16_t trig = 0; trig < nTriggers; trig++) {
    Pg_Single();
    // Delay the next trigger, depending in the data traffic we expect:
    uDelay(4*roc_i2c.size());
  }

  // Clear the calibrate signal on every ROC configured
  // Disable this column on every ROC configured:
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    roc_Pix_Mask(column,row);
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
      if(!GetMaskState(roc_i2c,col,row)) roc_Pix_Trim(col, row, GetTrimValue(roc_i2c,col,row));
      roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

      // Send the triggers:
      uDelay(5);
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	    Pg_Single();
	    uDelay(4);
      }

      // Clear the calibrate signal
      roc_Pix_Mask(col,row);
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
  if(!GetMaskState(roc_i2c,column,row)) roc_Pix_Trim(column, row, GetTrimValue(roc_i2c,column,row));
  roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

  // Send the triggers:
  uDelay(5);
  for (uint16_t trig = 0; trig < nTriggers; trig++) {
    Pg_Single();
    uDelay(4);
  }

  // Clear the calibrate signal on thr ROC configured
  // Disable this column on the ROC configured:
  roc_Pix_Mask(column,row);
  roc_ClrCal();
  roc_Col_Enable(column, false);
}


// -------- Trigger Loop Functions for 1D Dac Scans -------------------------------

void CTestboard::LoopMultiRocAllPixelsDacScan(vector<uint8_t> &roc_i2c, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high) {

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
	    if(!GetMaskState(roc_i2c.at(roc),col,row)) roc_Pix_Trim(col, row, GetTrimValue(roc_i2c.at(roc),col,row));
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
	  uDelay(4*roc_i2c.size());
	}
      } // Loop over the DAC range

      // Clear the calibrate signal on every ROC configured
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    	  roc_I2cAddr(roc_i2c.at(roc));
    	  roc_Pix_Mask(col,row);
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
    roc_Col_Enable(column, true);
    if(!GetMaskState(roc_i2c.at(roc),column,row)) roc_Pix_Trim(column, row, GetTrimValue(roc_i2c.at(roc),column,row));
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
      uDelay(4*roc_i2c.size());
    }
  } // Loop over the DAC range

  // Clear the calibrate signal on every ROC configured
  // Disable this column on every ROC configured:
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    roc_Pix_Mask(column,row);
    roc_ClrCal();
    roc_Col_Enable(column, false);
  }
}

void CTestboard::LoopSingleRocAllPixelsDacScan(uint8_t roc_i2c, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high) {

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
      if(!GetMaskState(roc_i2c,col,row)) roc_Pix_Trim(col, row, GetTrimValue(roc_i2c,col,row));
      roc_Pix_Cal(col, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

      // Loop over the DAC range specified:
      for (size_t dac1 = dac1low; dac1 <= dac1high; dac1++) {

	// Update the DAC setting on the ROC:
	roc_SetDAC(dac1register, dac1);

	// Send the triggers:
	uDelay(5);
	for (uint16_t trig = 0; trig < nTriggers; trig++) {
	  Pg_Single();
	  uDelay(8);
	}
      } // Loop over the DAC range

      // Clear the calibrate signal
      roc_Pix_Mask(col,row);
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
  roc_Col_Enable(column, true);
  if(!GetMaskState(roc_i2c,column,row)) roc_Pix_Trim(column, row, GetTrimValue(roc_i2c,column,row));
  roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));

  // Loop over the DAC range specified:
  for (size_t dac = dac1low; dac <= dac1high; dac++) {

    // Update the DAC setting on the ROC:
    roc_SetDAC(dac1register, dac);

    // Send the triggers:
    uDelay(5);
    for (uint16_t trig = 0; trig < nTriggers; trig++) {
      Pg_Single();
      uDelay(4);
    }
  } // Loop over the DAC range

  // Clear the calibrate signal on thr ROC configured
  // Disable this column on the ROC configured:
  roc_Pix_Mask(column,row);
  roc_ClrCal();
  roc_Col_Enable(column, false);
}

// -------- Trigger Loop Functions for 2D DacDac Scans ----------------------------

void CTestboard::LoopMultiRocAllPixelsDacDacScan(vector<uint8_t> &roc_i2c, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high, uint8_t dac2register, uint8_t dac2low, uint8_t dac2high) {

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
    	  if(!GetMaskState(roc_i2c.at(roc),col,row)) roc_Pix_Trim(col, row, GetTrimValue(roc_i2c.at(roc),col,row));
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
	    uDelay(4*roc_i2c.size());
	  }
	} // Loop over the DAC2 range
      } // Loop over the DAC1 range

      // Clear the calibrate signal on every ROC configured
      for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
	roc_I2cAddr(roc_i2c.at(roc));
	roc_Pix_Mask(col,row);
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
    roc_Col_Enable(column, true);
    if(!GetMaskState(roc_i2c.at(roc),column,row)) roc_Pix_Trim(column, row, GetTrimValue(roc_i2c.at(roc),column,row));
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
        uDelay(4*roc_i2c.size());
      }
    } // Loop over the DAC2 range
  } // Loop over the DAC1 range

  // Clear the calibrate signal on every ROC configured
  // Disable this column on every ROC configured:
  for(size_t roc = 0; roc < roc_i2c.size(); roc++) {
    roc_I2cAddr(roc_i2c.at(roc));
    roc_Pix_Mask(column,row);
    roc_ClrCal();
    roc_Col_Enable(column, false);
  }
}

void CTestboard::LoopSingleRocAllPixelsDacDacScan(uint8_t roc_i2c, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high, uint8_t dac2register, uint8_t dac2low, uint8_t dac2high) {

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
      if(!GetMaskState(roc_i2c,col,row)) roc_Pix_Trim(col, row, GetTrimValue(roc_i2c,col,row));
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
	    uDelay(4);
	  }
	} // Loop over the DAC2 range
      } // Loop over the DAC1 range

      // Clear the calibrate signal
      roc_Pix_Mask(col,row);
      roc_ClrCal();
    } // Loop over all rows

    // Disable this column on every ROC configured:
    roc_Col_Enable(col, false);

  } // Loop over all columns
}

void CTestboard::LoopSingleRocOnePixelDacDacScan(uint8_t roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high, uint8_t dac2register, uint8_t dac2low, uint8_t dac2high) {

  // Enable this column on the configured ROC
  // Set the calibrate bits on the configured ROC
  // Take into account both Xtalks and Cals flags
  roc_I2cAddr(roc_i2c);
  roc_Col_Enable(column, true);
  if(!GetMaskState(roc_i2c,column,row)) roc_Pix_Trim(column, row, GetTrimValue(roc_i2c,column,row));
  roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
  uDelay(15);
  // Loop over the DAC range specified:
  for (size_t dac1 = dac1low; dac1 <= dac1high; dac1++) {
    
    // Update the DAC1 setting on the configured ROC:
    roc_SetDAC(dac1register, dac1);

    // Loop over the DAC2 range specified:
    	uDelay(15);
    for (size_t dac2 = dac2low; dac2 <= dac2high; dac2++) {

      // Update the DAC2 setting on the configured ROC:
      roc_SetDAC(dac2register, dac2);

      // Send the triggers:
      uDelay(15);
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	Pg_Single();
	uDelay(15);
      }
    } // Loop over the DAC2 range
  } // Loop over the DAC1 range

  // Clear the calibrate signal on the ROC configured
  // Disable this column on the ROC configured:
  roc_Pix_Mask(column,row);
  roc_ClrCal();
  roc_Col_Enable(column, false);
}

void CTestboard::LoopCheckerBoard(uint8_t roc_i2c, uint8_t column, uint8_t row, uint16_t nTriggers, uint16_t flags, uint8_t dac1register, uint8_t dac1low, uint8_t dac1high, uint8_t dac2register, uint8_t dac2low, uint8_t dac2high) {

  // Enable this column on the configured ROC:
  roc_I2cAddr(roc_i2c);
  roc_Col_Enable(column, true);

  // Loop over the DAC range specified:
  for (size_t dac1 = dac1low; dac1 <= dac1high; dac1++) {

    // Loop over the DAC2 range specified:
    for (size_t dac2 = dac2low; dac2 <= dac2high; dac2++) {

      // Only set calibrate every other pixel, checker board patterns:
      if((dac2%2 + dac1%2) == 1) roc_Pix_Cal(column, GetXtalkRow(row,(flags&FLAG_XTALK)), (flags&FLAG_CALS));
      else roc_ClrCal();

      // Send the triggers:
      uDelay(5);
      for (uint16_t trig = 0; trig < nTriggers; trig++) {
	Pg_Single();
	uDelay(4);
      }
    } // Loop over the DAC2 range
  } // Loop over the DAC1 range

  // Clear the calibrate signal on the ROC configured
  // Disable this column on the ROC configured:
  roc_ClrCal();
  roc_Col_Enable(column, false);
}
