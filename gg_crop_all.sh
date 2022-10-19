#!/bin/bash
# Copyright (C) 2022 Giansalvo Gusinu
#
# Permission is hereby granted, free of charge, to any person obtaining a 
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

if [ -z "$1" ]
then
    echo
    echo "usage: $0 <input_directory>"
    echo
    echo "        Crop all files in <input_directory> and write" 
    echo "        the cropped files in the 'cropped' directory."
    echo
    exit
fi

echo "Creating output directory: $1_cropped."
mkdir $1_cropped

echo "Cropping images..."
cd $1 || exit 1
for f in *; do
    # do some stuff here with "$f"
    # remember to quote it or spaces may misbehave
    convert -crop 300x300+330+165 "$f" "../$1_cropped/$f"
done

echo "Program ended."