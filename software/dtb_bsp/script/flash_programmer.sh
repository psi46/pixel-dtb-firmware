#!/bin/sh
#
# This file was automatically generated.
#
# It can be overwritten by nios2-flash-programmer-generate or nios2-flash-programmer-gui.
#

#
# Converting ELF File: dtb_expert.elf to: "../flash/dtb_expert_epcs_controller.flash"
#
elf2flash --input="dtb_expert.elf" --output="../flash/dtb_expert_epcs_controller.flash" --epcs --verbose 

#
# Programming File: "../flash/dtb_expert_epcs_controller.flash" To Device: epcs_controller
#
nios2-flash-programmer "../flash/dtb_expert_epcs_controller.flash" --base=0x8000000 --epcs --sidp=0x8001000 --id=0x1 --timestamp=1373490686 --device=1 --instance=0 '--cable=USB-Blaster on localhost [3-1]' --program --verbose 

