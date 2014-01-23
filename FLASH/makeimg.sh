#!/bin/sh

sof2flash --input="../dtb/dtb.sof" --output="dtb.flash" --epcs
elf2flash --input="../software/dtb_expert/dtb_expert.elf" --output="dtb_expert.flash" --epcs --after="dtb.flash"
cat dtb.flash dtb_expert.flash > dtb_v1.16.flash
rm dtb.flash
rm dtb_expert.flash
