#!/bin/sh
#Create flash files
sof2flash --input="../dtb/dtb.sof" --output="dtb.flash" --epcs
elf2flash --input="../software/dtb_expert/dtb_expert.elf" --output="dtb_expert.flash" --epcs --after="dtb.flash"
#Download flash files onto dtb over JTAG 
# Edit the "--cable" parameter to match with that shown in the Quartus II Programmer tool
nios2-flash-programmer "dtb.flash" --base=0x8000000 --epcs --accept-bad-sysid '--cable=USB-Blaster on localhost [USB-0]' --program
nios2-flash-programmer "dtb_expert.flash" --base=0x8000000 --epcs --accept-bad-sysid '--cable=USB-Blaster on localhost [USB-0]' --program

