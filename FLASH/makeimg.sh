#!/bin/sh

echo "Generating SOF flash file..."
sof2flash --input="../dtb/dtb.sof" --output="dtb.flash" --epcs
echo "Generating ELF flash file..."
elf2flash --input="../software/dtb_expert/dtb_expert.elf" --output="dtb_expert.flash" --epcs --after="dtb.flash"
echo "Fetching SW version..."
version=$(grep "sw_version" ../software/dtb_expert/dtb_config.h | tr -dc '[:digit:]' | sed 's/^\(.\{1\}\)/\1./')
echo "Merging flash files to dtb_v${version}.flash..."
cat dtb.flash dtb_expert.flash > dtb_v${version}.flash
rm dtb.flash
rm dtb_expert.flash
echo "Done."
