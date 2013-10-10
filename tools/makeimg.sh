#!/bin/sh

# Use this tool to create an image suitable for uploading using USB

versionMain=01
versionSub=07

echo Creating dtb_v$versionMain$versionSub.flash

sof2flash --input="../dtb/dtb.sof" --output="dtb.flash" --epcs
elf2flash --input="../software/dtb_expert/dtb_expert.elf" --output="dtb_expert.flash" --epcs --after="dtb.flash"
cat dtb.flash dtb_expert.flash > dtb_v$versionMain$versionSub.flash

echo Done

