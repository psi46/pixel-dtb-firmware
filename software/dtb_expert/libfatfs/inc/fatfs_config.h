/****************************************************************************
*  Copyright (C) 2008-2012 by Michael Fischer.
*
*  All rights reserved.
*
*  Redistribution and use in source and binary forms, with or without 
*  modification, are permitted provided that the following conditions 
*  are met:
*  
*  1. Redistributions of source code must retain the above copyright 
*     notice, this list of conditions and the following disclaimer.
*  2. Redistributions in binary form must reproduce the above copyright
*     notice, this list of conditions and the following disclaimer in the 
*     documentation and/or other materials provided with the distribution.
*  3. Neither the name of the author nor the names of its contributors may 
*     be used to endorse or promote products derived from this software 
*     without specific prior written permission.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
*  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
*  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
*  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
*  THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
*  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
*  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
*  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
*  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
*  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
*  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
*  SUCH DAMAGE.
*
*****************************************************************************
*  History:
*
*  11.11.2008  mifi  First Version
*  11.02.2012  mifi  Added EIR support
*  23.08.2012  mifi  Added Altera DE1 support with a simple SPI with pio.
****************************************************************************/
#if !defined(__FATFS_CONFIG_H__)
#define __FATFS_CONFIG_H__

/***************************************************************************/
/*  DEFINE: All Structures and Commn Constants                             */
/***************************************************************************/
/*
 * Will the Filesystem used with a real time os?
 * 0:No RTOS or 1:RTOS available
 */
#define FFS_USE_REAL_TIME_OS     0

/*
 * 0:Read/Write or 1:Read only 
 */
#define FFS_READONLY_MODE        0

/*
 * 0 to 3
 */
#define FFS_MINIMIZE             0 

/* 
 * Should the write protect switch supported (0,1)?
 * If the hardware has no WP or the WP should be 
 * ignored, set this flag to 0.
 */
#define FFS_SUPPORT_HW_WP        0 

/*
 * For the next selection only one MUST be selected (0,1)
 */
#define FFS_SUPPORT_HW_OLIMEX_LPC_P2148         0   /* LPC2148,   SSP  / 16 bit / FIFO */
#define FFS_SUPPORT_HW_OLIMEX_LPC_L2294         0   /* LPC2294,   SPI0 /  8 bit        */
#define FFS_SUPPORT_HW_OLIMEX_LPC_E2468_SSP0    0   /* LPC2468,   SSP0 / 16 bit / FIFO */
#define FFS_SUPPORT_HW_OLIMEX_REV_E_SAM7_P256   0   /* SAM7S256,  SPI  /  8 bit / DMA  */
#define FFS_SUPPORT_HW_EIR_SPI                  0   /* SAM7SE512, SPI  / 16 bit        */
#define FFS_SUPPORT_HW_EIR_SSC                  0   /* SAM7SE512, SSC  /  8 bit        */
#define FFS_SUPPORT_HW_NIOS2_DE1_PIO            0   /* NiosII,    PIO  / 16 bit        */
#define FFS_SUPPORT_HW_NIOS2_DE1_SPI            1   /* NiosII,    SPI  / 16 bit        */

/***************************************************************************/
/*                 P R O T O T Y P E S                                     */
/***************************************************************************/

#endif /* !__FATFS_CONFIG_H__ */
/*** EOF ***/
