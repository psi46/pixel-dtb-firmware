#!/bin/sh

echo "Generating SOF flash file..."
sof2flash --input="../dtb/dtb.sof" --output="dtb.flash" --epcs
echo "Generating ELF flash file..."
elf2flash --input="../software/dtb_expert/dtb_expert.elf" --output="dtb_expert.flash" --epcs --after="dtb.flash"
echo "Merging flash files..."
cat dtb.flash dtb_expert.flash > dtb_v1.17.flash
rm dtb.flash
rm dtb_expert.flash
echo "Done."
