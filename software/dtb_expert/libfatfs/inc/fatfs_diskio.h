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
*  07.11.08  mifi   First Version
****************************************************************************/
#if !defined(__FATFS_DISKIO_H__)
#define __FATFS_DISKIO_H__

/***************************************************************************/
/*  Includes                                                               */
/***************************************************************************/
#include "fatfs_types.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/***************************************************************************/
/*  DEFINE: All Structures and Commn Constants                             */
/***************************************************************************/

/***************************************************************************/
/*                 P R O T O T Y P E S                                     */
/***************************************************************************/
FFS_RESULT ffs_DiskIOInit (void);
void       ffs_DiskIOTimerproc (void);
DSTATUS    ffs_DiskIOInitialize (FFS_U8 drv);
DSTATUS    ffs_DiskIOStatus (FFS_U8 drv);
DRESULT    ffs_DiskIORead (FFS_U8 drv, FFS_U8 *buff, FFS_U32 sector, FFS_U8 count);
DRESULT    ffs_DiskIOWrite (FFS_U8 drv, const FFS_U8 *buff, FFS_U32 sector, FFS_U8 count);
DRESULT    ffs_DiskIOIoctl (FFS_U8 drv, FFS_U8 ctrl, void *buff);

#if (FFS_USE_REAL_TIME_OS >= 1)
void ff_wait_ms (uint16_t time);
#endif

#ifdef __cplusplus
}
#endif

#endif /* !__FATFS_DISKIO_H__ */
/*** EOF ***/
