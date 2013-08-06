/****************************************************************************
*  Copyright (C) 2008-2012 by Michael Fischer.
*
*  All rights reserved.
*
*  Parts of the source are based on FatFs from ChaN. Therefore
*  partial copyright (C) 2008 ChaN.
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
****************************************************************************
*  History:
*
*  07.11.2008  mifi  First Version
*  11.02.2012  mifi  Rework WaitReady (FFS_USE_REAL_TIME_OS).
****************************************************************************/
#define __FATFS_DISKIO_C__

/*=========================================================================*/
/*  Includes                                                               */
/*=========================================================================*/
#include "fatfs.h"
#include "diskio.h"

/*
 * Check if the possible supported platforms are defined
 */
#ifndef FFS_SUPPORT_HW_WP
   Error: FFS_SUPPORT_HW_WP must be defined in fatfs_config.h;
#endif

#ifndef FFS_USE_REAL_TIME_OS
   Error: FFS_USE_REAL_TIME_OS must be defined in fatfs_config.h;
#endif

/*=========================================================================*/
/*  Prototypes                                                             */
/*=========================================================================*/
static FFS_U8 WaitReady(void);

/*=========================================================================*/
/*  DEFINE: All Structures and Common Constants                            */
/*=========================================================================*/

/*
 * MMC/SD command (in SPI) 
 */
#define CMD0    (0x40+0)   /* GO_IDLE_STATE */
#define CMD1    (0x40+1)   /* SEND_OP_COND (MMC) */
#define ACMD41  (0xC0+41)  /* SEND_OP_COND (SDC) */
#define CMD8    (0x40+8)   /* SEND_IF_COND */
#define CMD9    (0x40+9)   /* SEND_CSD */
#define CMD10   (0x40+10)  /* SEND_CID */
#define CMD12   (0x40+12)  /* STOP_TRANSMISSION */
#define ACMD13  (0xC0+13)  /* SD_STATUS (SDC) */
#define CMD16   (0x40+16)  /* SET_BLOCKLEN */
#define CMD17   (0x40+17)  /* READ_SINGLE_BLOCK */
#define CMD18   (0x40+18)  /* READ_MULTIPLE_BLOCK */
#define CMD23   (0x40+23)  /* SET_BLOCK_COUNT (MMC) */
#define ACMD23  (0xC0+23)  /* SET_WR_BLK_ERASE_COUNT (SDC) */
#define CMD24   (0x40+24)  /* WRITE_BLOCK */
#define CMD25   (0x40+25)  /* WRITE_MULTIPLE_BLOCK */
#define CMD55   (0x40+55)  /* APP_CMD */
#define CMD58   (0x40+58)  /* READ_OCR */

/*
 * Card type flags (CardType) 
 */
#define CT_MMC          0x01  /* MMC ver 3 */
#define CT_SD1          0x02  /* SD ver 1 */
#define CT_SD2          0x04  /* SD ver 2 */
#define CT_SDC          (CT_SD1|CT_SD2)   /* SD */
#define CT_BLOCK        0x08  /* Block addressing */


/*
 * Card socket defines
 */
#define SOCK_CD_EMPTY   0x01  /* Card detect switch */
#define SOCK_WP_ACTIVE  0x02  /* Write protect switch */

/* 
 * Wait for ready in timeout of 500ms 
 */
#define WAIT_READY_TIME_MAX_MS   500 
#define WAIT_READY_TIME_RTOS_MS  5
#define WAIT_READY_TIME_CNT_RTOS (WAIT_READY_TIME_MAX_MS / WAIT_READY_TIME_RTOS_MS)
#define WAIT_READY_LOOP_CNT_MAX  16

/*=========================================================================*/
/*  DEFINE: Definition of all local Data                                   */
/*=========================================================================*/
static volatile DSTATUS Stat = STA_NOINIT;   /* Disk status */
static FFS_U8           CardType = 0;        /* b0:MMC, b1:SDv1, b2:SDv2, b3:Block addressing */
static volatile FFS_U16 Timer1 = 0;          /* 100Hz decrement timers */
static volatile FFS_U16 Timer2 = 0;          /* 100Hz decrement timers */
static FFS_U8           XMITDummy = 0;

/*=========================================================================*/
/*  DEFINE: Definition of all local Procedures                             */
/*=========================================================================*/

/*
 * Include high platform dependent parts
 */
#include "fatfs_hwsupport.h"

/*-----------------------------------------------------------------------*/
/* Wait for card ready                                                   */
/*-----------------------------------------------------------------------*/
static FFS_U8 WaitReady (void)
{
   FFS_U8 res;
   
#if (FFS_USE_REAL_TIME_OS == 0)
   Timer2 = (WAIT_READY_TIME_MAX_MS / 10);
   ReceiveU8();
   do
   {
      res = ReceiveU8();
   }
   while ((res != 0xFF) && Timer2);
#else
   FFS_U8 cnt;

   /*
    * Use the fast way first
    */   
   cnt = 0; 
   ReceiveU8();
   do
   {
      res = ReceiveU8();
      if (0xFF == res)
      {
         return(res);
      }
      cnt++;
   } while (cnt < WAIT_READY_LOOP_CNT_MAX);
   
   /*
    * It looks that it takes longer...
    * Use the wait function from the RTOS.
    */ 
   cnt = 0;   
   do
   {
      res = ReceiveU8();
      cnt++;
      ff_wait_ms(WAIT_READY_TIME_RTOS_MS);
   }
   while ((res != 0xFF) && (cnt < WAIT_READY_TIME_CNT_RTOS));
#endif   

   return(res);
} /* WaitReady */

/*-----------------------------------------------------------------------*/
/* Deselect the card and release SPI bus                                 */
/*-----------------------------------------------------------------------*/
static void ReleaseBus (void)
{
   /*
    * First deselect the CS line, and now make a dummy transmission.
    * 
    * In SPI, each slave device is selected with separated CS signals, 
    * and plural devices can be attached to an SPI bus. Generic SPI slave 
    * device drives/releases its DO signal by CS signal asynchronously to 
    * share an SPI bus. However MMC/SDC drives/releases DO signal in 
    * synchronising to SCLK. There is a posibility of bus conflict when 
    * attach MMC/SDC and any other SPI slaves to an SPI bus. Right image 
    * shows the drive/release timing of MMC/SDC (DO is pulled to 1/2 vcc to 
    * see the bus state). Therefore to make MMC/SDC release DO signal, the 
    * master device must send a byte after deasserted CS signal.   
    *
    * More information can be found here:
    * http://elm-chan.org/docs/mmc/mmc_e.html
    */
   DESELECT();
   ReceiveU8();
} /* ReleaseBus */

/*-----------------------------------------------------------------------*/
/* Send a command packet to MMC                                          */
/*-----------------------------------------------------------------------*/
static FFS_U8 SendCMD (FFS_U8 cmd,   /* Command byte */
                       FFS_U32 arg)  /* Argument */
{
   FFS_U8 n, res;

   if (cmd & 0x80)   /* ACMD<n> is the command sequense of CMD55-CMD<n> */
   {
      cmd &= 0x7F;
      res = SendCMD(CMD55, 0);
      if (res > 1)
         return res;
   }

   /* Select the card and wait for ready */
   DESELECT();
   SELECT();

   if (WaitReady() != 0xFF)
      return 0xFF;

   /* Send command packet */
   TRANSMIT_U8(cmd); /* Start + Command index */
   TRANSMIT_U8((FFS_U8) (arg >> 24));  /* Argument[31..24] */
   TRANSMIT_U8((FFS_U8) (arg >> 16));  /* Argument[23..16] */
   TRANSMIT_U8((FFS_U8) (arg >> 8));   /* Argument[15..8] */
   TRANSMIT_U8((FFS_U8) arg); /* Argument[7..0] */

   n = 0x01;   /* Dummy CRC + Stop */
   if (cmd == CMD0)
      n = 0x95;   /* Valid CRC for CMD0(0) */
   if (cmd == CMD8)
      n = 0x87;   /* Valid CRC for CMD8(0x1AA) */
   TRANSMIT_U8(n);

   /* Receive command response */
   if (cmd == CMD12)
      ReceiveU8();   /* Skip a stuff byte when stop reading */

   n = 10;  /* Wait for a valid response in timeout of 10 attempts */
   do
   {
      res = ReceiveU8();
   }
   while ((res & 0x80) && --n);

   return(res); /* Return with the response value */
} /* SendCMD */

/*=========================================================================*/
/*  DEFINE: All code exported                                              */
/*=========================================================================*/
/***************************************************************************/
/*  ffs_DiskIOInit                                                         */
/*                                                                         */
/*  Here the diskio interface is initialise.                               */
/*                                                                         */
/*  In    : none                                                           */
/*  Out   : none                                                           */
/*  Return: FFS_OK                                                         */
/***************************************************************************/
FFS_RESULT ffs_DiskIOInit (void)
{
   (void)XMITDummy;

   InitDiskIOHardware();

   return(FFS_OK);
} /* ffs_DiskIOInit */

#if (FFS_USE_REAL_TIME_OS == 0)
/***************************************************************************/
/*  ffs_DiskIOTimerproc                                                    */
/*                                                                         */
/*  Device timer interrupt procedure, will be called in period of 10ms.    */
/*                                                                         */
/*  In    : none                                                           */
/*  Out   : none                                                           */
/*  Return: none                                                           */
/***************************************************************************/
void ffs_DiskIOTimerproc (void)
{
   static FFS_U32 pvm;
   FFS_U32 n;
   DSTATUS s;

   /* 100Hz decrement timer */
   n = Timer1;
   if (n)
      Timer1 = (FFS_U16)-- n;
   n = Timer2;
   if (n)
      Timer2 = (FFS_U16)-- n;

   n = pvm;

   /* Sample socket switch */
   pvm = GetCDWP();

   /* Have contacts stabled? */
   if (n == pvm)
   {
      s = Stat;

      /* Check write protect */
      if (pvm & SOCK_WP_ACTIVE)
         s |= STA_PROTECT;
      else
         s &= ~STA_PROTECT;

      /* Check socket empty */
      if (pvm & SOCK_CD_EMPTY)
         s |= (STA_NODISK | STA_NOINIT);
      else
         s &= ~STA_NODISK;

#if (FFS_SUPPORT_HW_WP == 0)
      /* Ignore the write protect */
      s &= ~STA_PROTECT;
#endif

      Stat = s;
   }
} /* ffs_DiskIOTimerproc */
#endif /* (FFS_USE_REAL_TIME_OS == 0) */   

/***************************************************************************/
/*  ffs_DiskIOInitialize                                                   */
/*                                                                         */
/*  The FFS_DiskIOInitialize function initializes a physical drive.        */
/*  When the function succeeded, STA_NOINIT flag in the return             */
/*  value is cleard.                                                       */
/*                                                                         */
/*  In    : Physical drive nmuber                                          */
/*  Out   : none                                                           */
/*  Return: DSTATUS                                                        */
/***************************************************************************/
DSTATUS ffs_DiskIOInitialize (FFS_U8 drv)
{
   FFS_U8 n, ty, cmd, ocr[4];

   (void)drv;

   if (Stat & STA_NODISK)  /* No card in the socket */
      return Stat;

   /* low speed during init */
   SetLowSpeed();

   POWER_ON(); /* Force socket power ON */
   for (n = 10; n; n--)
      ReceiveU8();   /* 80 dummy clocks */

   ty = 0;
   if (SendCMD(CMD0, 0) == 1)
   {  /* Enter Idle state */
      Timer1 = 100;  /* Initialization timeout of 1000 msec */
      if (SendCMD(CMD8, 0x1AA) == 1)
      {  /* SDC ver 2.00 */
         for (n = 0; n < 4; n++)
            ocr[n] = ReceiveU8();
         if (ocr[2] == 0x01 && ocr[3] == 0xAA)
         {  /* The card can work at vdd range of 2.7-3.6V */
            while (Timer1 && SendCMD(ACMD41, 1UL << 30)) ;  /* ACMD41 with HCS bit */
            if (Timer1 && SendCMD(CMD58, 0) == 0)
            {  /* Check CCS bit */
               for (n = 0; n < 4; n++)
                  ocr[n] = ReceiveU8();
               ty = (ocr[0] & 0x40) ? CT_SD2 | CT_BLOCK : CT_SD2; /* Card id SDv2 */
            }
         }
      }
      else
      {  /* SDC ver 1.XX or MMC */
         if (SendCMD(ACMD41, 0) <= 1)
         {
            ty  = CT_SD1;
            cmd = ACMD41;  /* SDC ver 1.XX */
         }
         else
         {
            ty  = CT_MMC;
            cmd = CMD1; /* MMC */
         }
         while (Timer1 && SendCMD(cmd, 0)) ; /* Wait for leaving idle state */
         if (!Timer1 || SendCMD(CMD16, 512) != 0)  /* Select R/W block length */
            ty = 0;
      }
   }
   CardType = ty;
   ReleaseBus();

   if (ty)
   {  /* Initialization succeded */
      Stat &= ~STA_NOINIT; /* Clear STA_NOINIT */

      SetHighSpeed();
   }
   else
   {  /* Initialization failed */
      POWER_OFF();
   }

   return(Stat);
} /* ffs_DiskIOInitialize */

/***************************************************************************/
/*  ffs_DiskIOStatus                                                       */
/*                                                                         */
/*  The FFS_DiskIOStatus function returns the current disk status.         */
/*                                                                         */
/*  In    : Physical drive nmuber                                          */
/*  Out   : none                                                           */
/*  Return: DSTATUS                                                        */
/***************************************************************************/
DSTATUS ffs_DiskIOStatus (FFS_U8 drv)
{
   (void)drv;

   return(Stat);
} /* ffs_DiskIOStatus */

/***************************************************************************/
/*  ffs_DiskIORead                                                         */
/*                                                                         */
/*  The disk_read function reads sector(s) from the disk drive.            */
/*                                                                         */
/*  In    :  drv     Physical drive nmuber (0)                             */
/*          *buff    Data buffer to store read data                        */
/*           sector  Sector number (LBA)                                   */
/*           count   Sector count (1..255)                                 */
/*                                                                         */
/*  Out   : buff                                                           */
/*  Return: DRESULT                                                        */
/***************************************************************************/
DRESULT ffs_DiskIORead (FFS_U8 drv, FFS_U8 * buff, FFS_U32 sector, FFS_U8 count)
{
   (void)drv;

   if (!count)
      return RES_PARERR;
   if (Stat & STA_NOINIT)
      return RES_NOTRDY;

   if (!(CardType & CT_BLOCK))
      sector *= 512; /* Convert LBA to byte address if needed */

   if (count == 1)
   {  /* Single block read */
      if ((SendCMD(CMD17, sector) == 0)   /* READ_SINGLE_BLOCK */
          && ReceiveDatablock(buff, 512))
         count = 0;
   }
   else
   {  /* Multiple block read */
      if (SendCMD(CMD18, sector) == 0)
      {  /* READ_MULTIPLE_BLOCK */
         do
         {
            if (!ReceiveDatablock(buff, 512))
               break;
            buff += 512;
         }
         while (--count);
         SendCMD(CMD12, 0);   /* STOP_TRANSMISSION */
      }
   }
   ReleaseBus();

   return(count ? RES_ERROR : RES_OK);
} /* ffs_DiskIORead */

/***************************************************************************/
/*  ffs_DiskIOWrite                                                        */
/*                                                                         */
/*  The disk_write function writes sector(s) to the disk.                  */
/*                                                                         */
/*  In    :  drv     Physical drive nmuber (0)                             */
/*          *buff    Data buffer to be written                             */
/*           sector  Sector number (LBA)                                   */
/*           count   Sector count (1..255)                                 */
/*                                                                         */
/*  Out   : buff                                                           */
/*  Return: DRESULT                                                        */
/***************************************************************************/
DRESULT ffs_DiskIOWrite (FFS_U8 drv, const FFS_U8 * buff, FFS_U32 sector, FFS_U8 count)
{
   (void)drv;

   if (!count)
      return RES_PARERR;
   if (Stat & STA_NOINIT)
      return RES_NOTRDY;
   if (Stat & STA_PROTECT)
      return RES_WRPRT;

   if (!(CardType & CT_BLOCK))
      sector *= 512; /* Convert LBA to byte address if needed */

   if (count == 1)
   {  /* Single block write */
      if ((SendCMD(CMD24, sector) == 0)   /* WRITE_BLOCK */
          && TransmitDatablock(buff, 0xFE))
         count = 0;
   }
   else
   {  /* Multiple block write */
      if (CardType & CT_SDC)
      {
         SendCMD(CMD55, 0);
         SendCMD(CMD23, count);  /* ACMD23 */
      }
      if (SendCMD(CMD25, sector) == 0)
      {  /* WRITE_MULTIPLE_BLOCK */
         do
         {
            if (!TransmitDatablock(buff, 0xFC))
               break;
            buff += 512;
         }
         while (--count);
         if (!TransmitDatablock(0, 0xFD)) /* STOP_TRAN token */
            count = 1;
      }
   }
   ReleaseBus();

   return(count ? RES_ERROR : RES_OK);
} /* ffs_DiskIOWrite */

/***************************************************************************/
/*  ffs_DiskIOIoctl                                                        */
/*                                                                         */
/*  The FFS_DiskIOIoctl function cntrols device specified features and     */
/*  miscellaneous functions other than disk read/write.                    */
/*                                                                         */
/*  In    :  drv     Physical drive nmuber (0)                             */
/*           ctrl    Control code                                          */
/*          *buff    Buffer to send/receive data block                     */
/*                                                                         */
/*  Out   : buff                                                           */
/*  Return: DRESULT                                                        */
/***************************************************************************/
DRESULT ffs_DiskIOIoctl (FFS_U8 drv, FFS_U8 ctrl, void *buff)
{
   DRESULT res;
   FFS_U8 n, csd[16], *ptr = buff;
   FFS_U16 csize;

   (void)drv;

   if (Stat & STA_NOINIT)
      return RES_NOTRDY;

   res = RES_ERROR;
   switch (ctrl)
   {
      case CTRL_SYNC:  /* Make sure that pending write process has been finished */
         SELECT();
         if (WaitReady() == 0xFF)
            res = RES_OK;
         break;

      case GET_SECTOR_COUNT: /* Get number of sectors on the disk (DWORD) */
         if ((SendCMD(CMD9, 0) == 0) && ReceiveDatablock(csd, 16))
         {
            if ((csd[0] >> 6) == 1)
            {  /* SDC ver 2.00 */
               //@@MF csize = csd[9] + ((FFS_U16)csd[8] << 8) + 1;
               csize = (FFS_U16) ((FFS_U16) csd[9] | ((FFS_U16) csd[8] << 8)) + 1;
               *(FFS_U32 *) buff = (FFS_U32) csize << 10;
            }
            else
            {  /* MMC or SDC ver 1.XX */
               n = (csd[5] & 15) + ((csd[10] & 128) >> 7) + ((csd[9] & 3) << 1) + 2;
               csize = (csd[8] >> 6) + ((FFS_U16) csd[7] << 2) + ((FFS_U16) (csd[6] & 3) << 10) + 1;
               *(FFS_U32 *) buff = (FFS_U32) csize << (n - 9);
            }
            res = RES_OK;
         }
         break;

      case GET_SECTOR_SIZE:  /* Get sectors on the disk (WORD) */
         *(FFS_U16 *) buff = 512;
         res = RES_OK;
         break;

      case GET_BLOCK_SIZE:   /* Get erase block size in unit of sectors (DWORD) */
         if (CardType & CT_SD2)
         {  /* SDC ver 2.00 */
            if (SendCMD(ACMD13, 0) == 0)
            {  /* Read SD status */
               ReceiveU8();
               if (ReceiveDatablock(csd, 16))
               {  /* Read partial block */
                  for (n = 64 - 16; n; n--)
                     ReceiveU8();   /* Purge trailing data */
                  *(FFS_U32 *) buff = 16UL << (csd[10] >> 4);
                  res = RES_OK;
               }
            }
         }
         else
         {  /* SDC ver 1.XX or MMC */
            if ((SendCMD(CMD9, 0) == 0) && ReceiveDatablock(csd, 16))
            {  /* Read CSD */
               if (CardType & CT_SD1)
               {  /* SDC ver 1.XX */
                  *(FFS_U32 *) buff = (((csd[10] & 63) << 1) + ((FFS_U16) (csd[11] & 128) >> 7) + 1) << ((csd[13] >> 6) - 1);
               }
               else
               {  /* MMC */
                  *(FFS_U32 *) buff = ((FFS_U16) ((csd[10] & 124) >> 2) + 1) * (((csd[11] & 3) << 3) + ((csd[11] & 224) >> 5) + 1);
               }
               res = RES_OK;
            }
         }
         break;
         
      /* Following command are not used by FatFs module */
         
      case MMC_GET_TYPE:  /* Get MMC/SDC type (BYTE) */
         *ptr = CardType;
         res = RES_OK;
         break;

      case MMC_GET_CSD:   /* Receive CSD as a data block (16 bytes) */
         if (SendCMD(CMD9, 0) == 0  /* READ_CSD */
             && ReceiveDatablock(ptr, 16))
            res = RES_OK;
         break;

      case MMC_GET_CID:   /* Receive CID as a data block (16 bytes) */
         if (SendCMD(CMD10, 0) == 0 /* READ_CID */
             && ReceiveDatablock(ptr, 16))
            res = RES_OK;
         break;

      case MMC_GET_OCR:   /* Receive OCR as an R3 resp (4 bytes) */
         if (SendCMD(CMD58, 0) == 0)
         {  /* READ_OCR */
            for (n = 0; n < 4; n++)
               *ptr++ = ReceiveU8();
            res = RES_OK;
         }
         break;

      case MMC_GET_SDSTAT:   /* Receive SD statsu as a data block (64 bytes) */
         if (SendCMD(ACMD13, 0) == 0)
         {  /* SD_STATUS */
            ReceiveU8();
            if (ReceiveDatablock(ptr, 64))
               res = RES_OK;
         }
         break;

      default:
         res = RES_PARERR;
   }

   ReleaseBus();

   return(res);
} /* ffs_DiskIOIoctl */

/***************************************************************************/
/*  get_fattime                                                            */
/*                                                                         */
/*  Return a fix time                                                      */
/*                                                                         */
/*  In    : none                                                           */
/*  Out   : none                                                           */
/*  Return: time                                                           */
/***************************************************************************/
FFS_U32 get_fattime (void)
{
   FFS_U32 dTime;

   dTime = ((FFS_U32)(2008 - 1980) << 25) |
                     ((FFS_U32) 10 << 21) | 
                     ((FFS_U32) 30 << 16) | 
                     ((FFS_U32) 20 << 11) | 
                     ((FFS_U32) 15 << 5)  | 
                     ((FFS_U32) 2 >> 1);

   return(dTime);
} /* get_fattime */

/*** EOF ***/
