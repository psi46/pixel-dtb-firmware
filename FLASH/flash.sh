#!/bin/sh

nios2-flash-programmer "dtb_out.flash" --base=0x8000000 --epcs --accept-bad-sysid '--cable=USB-Blaster [2-2]' --program -g
