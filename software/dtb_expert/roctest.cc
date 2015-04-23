/* roctest.cc
 *
 *  Created on: 28.07.2013
 *      Author: beat
 */

#include "pixel_dtb.h"


int PixelFired(const vector<uint16_t> &x, unsigned int &pos)
{
	// check header
	if (pos >= x.size()) return -1; // missing data
	if ((x[pos] & 0x8ffc) != 0x87f8) return -2; // wrong header
	pos++;

	if (pos >= x.size() || (x[pos] & 0x8000)) return 0; // empty data readout

	// read additional noisy pixel
	while (!(pos >= x.size() || (x[pos] & 0x8000))) { pos++; }

	return 1;
}


int GetPixel(unsigned int x)
{
	const unsigned int count = 20;
	unsigned int i;
	unsigned int n = 0;
	tb.roc_SetDAC(Vcal, x);
	tb.uDelay(30);

	tb.Daq_Start();
	for (i=0; i<count; i++)
	{
		tb.Pg_Single();
		tb.uDelay(5);
	}
	tb.Daq_Stop();
	vector<uint16_t> data;
	tb.Daq_Read(data, 10000);
	unsigned int pos = 0;

	for (i=0; i<count; i++)
	{
		int res = PixelFired(data, pos);
		if (res > 0) n++;
		else if (res < 0) return res;
	}

	return (n > count/2) ? 1 : 0;
}


/*
int FindLevel()
{
	static unsigned char x = 9;  // first estimation
	if (x>253) x = 200; else if (x<1) x=1;

	int res = GetPixel(x);
	if (res < 0) return res;
	if (res > 0)
	{
		do
		{
			x--;
			res = GetPixel(x);
			if (res < 0) return res;
		} while ((res > 0) && x>0);
		x++;
	}
	else
	{
		do
		{
			x++;
			res = GetPixel(x);
			if (res < 0) return res;
		} while (!(res > 0) && x<253);
	}

	return x;
}


bool sensorCal = false;

int test_PUC(unsigned char col, unsigned char row, unsigned char trim)
{
	tb.roc_Pix_Trim(col, row, trim);
	tb.roc_Pix_Cal (col, row, sensorCal);
	int res = FindLevel();
	tb.roc_ClrCal();
	tb.roc_Pix_Mask(col,row);
	return res;
}


bool CTestboard::TestColPixel(uint8_t col, uint8_t trimbit, bool sensor_cal, vectorR<uint8_t> &res)
{
	unsigned char row;
	sensorCal = sensor_cal;
	tb.roc_Col_Enable(col, 1);
	res.clear();
	res.reserve(ROC_NUMROWS);
	for(row=0; row<ROC_NUMROWS; row++)
	{
		int r = test_PUC(col,row,trimbit);
		if (r < 0) return false;
		res.push_back(r);
	}
	tb.roc_Col_Enable(col, 0);
	return true;
}
*/


int FindLevel(unsigned char x)
{
	//static unsigned char x = 9;  // now passed as an argument
	//if (x>253) x = 200; else if (x<1) x=1;

	int res = GetPixel(x);
	if (res < 0) return res;
	if (res > 0)
	{
		do
		{
			x--;
			res = GetPixel(x);
			if (res < 0) return res;
		} while ( (res > 0) && (x>0) );
		x++;
	}
	else
	{
		do
		{
			x++;
			res = GetPixel(x);
			if (res < 0) return res;
		} while (!(res > 0) && x<253);
	}

	return x;
}


bool sensorCal = false;

int test_PUC(unsigned char col, unsigned char row, unsigned char trim)
{
	static unsigned char res = 9;  // moved here from FindLevel

	if( (row==0) || ((res>250) && sensorCal) ) { res=100;} // ideally VCAL_BB_TARGET_REF
	if(res<1) res=20;

	tb.roc_Pix_Trim(col, row, trim);
	tb.roc_Pix_Cal (col, row, sensorCal);
	int x=FindLevel(res);
	tb.roc_ClrCal();
	tb.roc_Pix_Mask(col,row);
	if(x>=0) res=x;
	return x;
}


bool CTestboard::TestColPixel(uint8_t col, uint8_t trimbit, bool sensor_cal, vectorR<uint8_t> &res)
{
	unsigned char row;
	sensorCal = sensor_cal;
	tb.roc_Col_Enable(col, 1);
	res.clear();
	res.reserve(ROC_NUMROWS);
	bool good = true;
	for(row=0; row<ROC_NUMROWS; row++)
	{
		int r = test_PUC(col,row,trimbit);
		if (r < 0)
		{
			good = false;
			res.push_back(0);
		}
		else res.push_back(r);
	}
	tb.roc_Col_Enable(col, 0);
	return good;
}
