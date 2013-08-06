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
*  23.08.2012  mifi  Added NiosII (Altera DE1, simple SPI with pio) support
****************************************************************************/
#if !defined(__FATFS_HWSUPPORT_H__)
#define __FATFS_HWSUPPORT_H__

/*
 * Check if the possible supported platforms are defined
 */
#ifndef FFS_SUPPORT_HW_OLIMEX_LPC_P2148
   Error: FFS_SUPPORT_HW_OLIMEX_LPC_P2148 must be defined in fatfs_config.h;
#endif   

#ifndef FFS_SUPPORT_HW_OLIMEX_LPC_L2294
   Error: FFS_SUPPORT_HW_OLIMEX_LPC_L2294 must be defined in fatfs_config.h;
#endif 

#ifndef FFS_SUPPORT_HW_OLIMEX_REV_E_SAM7_P256
   Error: FFS_SUPPORT_HW_OLIMEX_REV_E_SAM7_P256 must be defined in fatfs_config.h;
#endif

#ifndef FFS_SUPPORT_HW_OLIMEX_LPC_E2468_SSP0
   Error: FFS_SUPPORT_HW_OLIMEX_LPC_E2468_SSP0 must be defined in fatfs_config.h;
#endif  

#ifndef FFS_SUPPORT_HW_EIR_SPI
   Error: FFS_SUPPORT_HW_EIR_SPI must be defined in fatfs_config.h;
#endif  

#ifndef FFS_SUPPORT_HW_EIR_SSC
   Error: FFS_SUPPORT_HW_EIR_SSC must be defined in fatfs_config.h;
#endif 

#ifndef FFS_SUPPORT_HW_NIOS2_DE1_PIO 
   Error: FFS_SUPPORT_HW_NIOS2_DE1_PIO must be defined in fatfs_config.h;
#endif 

#ifndef FFS_SUPPORT_HW_NIOS2_DE1_SPI
   Error: FFS_SUPPORT_HW_NIOS2_DE1_SPI must be defined in fatfs_config.h;
#endif 

/*=========================================================================*/
/*  Includes                                                               */
/*=========================================================================*/
#if (FFS_SUPPORT_HW_OLIMEX_LPC_P2148 >= 1)
#include "fatfs_olimex_lpc_p2148.c"
#endif

#if (FFS_SUPPORT_HW_OLIMEX_LPC_L2294 >= 1)
#include "fatfs_olimex_lpc_l2294.c"
#endif

#if (FFS_SUPPORT_HW_OLIMEX_REV_E_SAM7_P256 >= 1)
#include "fatfs_olimex_sam7_p256_e.c"
#endif

#if (FFS_SUPPORT_HW_OLIMEX_LPC_E2468_SSP0 >= 1)
#include "fatfs_olimex_lpc_e2468_ssp0.c"
#endif

#if (FFS_SUPPORT_HW_EIR_SPI >= 1)
#include "fatfs_eir_spi.c"
#endif

#if (FFS_SUPPORT_HW_EIR_SSC >= 1)
#include "fatfs_eir_ssc.c"
#endif

#if (FFS_SUPPORT_HW_NIOS2_DE1_PIO >= 1)
#include "fatfs_nios2_de1_pio.c_"
#endif

#if (FFS_SUPPORT_HW_NIOS2_DE1_SPI >= 1)
#include "fatfs_nios2_de1_spi.c_"
#endif

#endif /* !__FATFS_HWSUPPORT_H__ */
/*** EOF ***/
