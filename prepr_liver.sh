#!/usr/bin/bash 
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

CLEAN_SUBFOLDER="clean"
TRACED_SUBFOLDER="traced"
FILLED_SUBFOLDER="filled"
TRIMAP_HC_SUBFOLDER="trimap_HC"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Syntax error!"
    echo "Usage: $0 path_origin path_destination"
    exit
fi

if [ -d "$2" ]; then
    echo "Error: destination folder $2 does exist, specify a different destination folder!"
    exit
fi

# *** START ***
echo $(date +%d/%m/%Y)-$(date +%H:%M): Starting script $0

echo "Start anonymizing sample images"
python gg_prepr.py anonymize -i "$1" -o "$2" -x=0 -y=0 -w=640 -hi=100

echo "Creating subfolders of $2..."
#mkdir $2
mkdir $2/$CLEAN_SUBFOLDER
mkdir $2/$TRACED_SUBFOLDER
mkdir $2/$FILLED_SUBFOLDER
mkdir $2/$TRIMAP_HC_SUBFOLDER

echo "Copying and renaming clean sample images to $2/$CLEAN_SUBFOLDER..."
mv $2/"Case 7 image 4.png"  $2/$CLEAN_SUBFOLDER/I000.png
mv $2/"Case 8 image 3.png"  $2/$CLEAN_SUBFOLDER/I001.png
mv $2/"Case 10 image 3.png" $2/$CLEAN_SUBFOLDER/I002.png
mv $2/"Case 10 image 4.png" $2/$CLEAN_SUBFOLDER/I003.png
mv $2/"Case 12 image 2.png" $2/$CLEAN_SUBFOLDER/I004.png
mv $2/"Case 13 image 2.png" $2/$CLEAN_SUBFOLDER/I005.png
mv $2/"Case 14 image 2.png" $2/$CLEAN_SUBFOLDER/I006.png
mv $2/"Case 16 image 2.png" $2/$CLEAN_SUBFOLDER/I007.png
mv $2/"Case 17 image 4.png" $2/$CLEAN_SUBFOLDER/I008.png
mv $2/"Case 17 image 5.png" $2/$CLEAN_SUBFOLDER/I009.png
mv $2/"Case 20 image 2.png" $2/$CLEAN_SUBFOLDER/I010.png
mv $2/"Case 22 image 2.png" $2/$CLEAN_SUBFOLDER/I011.png
mv $2/"Case 28 image 2.png" $2/$CLEAN_SUBFOLDER/I012.png
mv $2/"Case 32 image 2.png" $2/$CLEAN_SUBFOLDER/I013.png
mv $2/"Case 34 image 3.png" $2/$CLEAN_SUBFOLDER/I014.png
mv $2/"Case 35 image 2.png" $2/$CLEAN_SUBFOLDER/I015.png
mv $2/"Case 35 image 3.png" $2/$CLEAN_SUBFOLDER/I016.png
mv $2/"Case 35 image 4.png" $2/$CLEAN_SUBFOLDER/I017.png
mv $2/"Case 36 image 3.png" $2/$CLEAN_SUBFOLDER/I018.png
mv $2/"Case 37 image 2.png" $2/$CLEAN_SUBFOLDER/I019.png
mv $2/"Case 38 image 1.png" $2/$CLEAN_SUBFOLDER/I020.png
mv $2/"Case 38 image 3.png" $2/$CLEAN_SUBFOLDER/I021.png
mv $2/"Case 40 image 2.png" $2/$CLEAN_SUBFOLDER/I022.png
mv $2/"Case 43 image 2.png" $2/$CLEAN_SUBFOLDER/I023.png
mv $2/"Case 43 image 4.png" $2/$CLEAN_SUBFOLDER/I024.png
mv $2/"Case 46 image 1.png" $2/$CLEAN_SUBFOLDER/I025.png
mv $2/"Case 46 image 3.png" $2/$CLEAN_SUBFOLDER/I026.png
mv $2/"Case 47 image 6.png" $2/$CLEAN_SUBFOLDER/I027.png
mv $2/"Case 50 image 2.png" $2/$CLEAN_SUBFOLDER/I028.png
mv $2/"Case 50 image 3.png" $2/$CLEAN_SUBFOLDER/I029.png
mv $2/"Case 51 image 1.png" $2/$CLEAN_SUBFOLDER/I030.png
mv $2/"Case 52 image 1.png" $2/$CLEAN_SUBFOLDER/I031.png


echo "Copying and renaming traced images to $2/$TRACED_SUBFOLDER..."
mv $2/"Case 7 image 4.1.png"  $2/$TRACED_SUBFOLDER/I000.png
mv $2/"Case 8 image 3.1.png"  $2/$TRACED_SUBFOLDER/I001.png
mv $2/"Case 10 image 3.1.png" $2/$TRACED_SUBFOLDER/I002.png
mv $2/"Case 10 image 4.1.png" $2/$TRACED_SUBFOLDER/I003.png
mv $2/"Case 12 image 2.1.png" $2/$TRACED_SUBFOLDER/I004.png
mv $2/"Case 13 image 2.1.png" $2/$TRACED_SUBFOLDER/I005.png
mv $2/"Case 14 image 2.1.png" $2/$TRACED_SUBFOLDER/I006.png
mv $2/"Case 16 image 2.1.png" $2/$TRACED_SUBFOLDER/I007.png
mv $2/"Case 17 image 4.1.png" $2/$TRACED_SUBFOLDER/I008.png
mv $2/"Case 17 image 5.1.png" $2/$TRACED_SUBFOLDER/I009.png
mv $2/"Case 20 image 2.1.png" $2/$TRACED_SUBFOLDER/I010.png
mv $2/"Case 22 image 2.1.png" $2/$TRACED_SUBFOLDER/I011.png
mv $2/"Case 28 image 2.1.png" $2/$TRACED_SUBFOLDER/I012.png
mv $2/"Case 32 image 2.1.png" $2/$TRACED_SUBFOLDER/I013.png
mv $2/"Case 34 image 3.1.png" $2/$TRACED_SUBFOLDER/I014.png
mv $2/"Case 35 image 2.1.png" $2/$TRACED_SUBFOLDER/I015.png
mv $2/"Case 35 image 3.1.png" $2/$TRACED_SUBFOLDER/I016.png
mv $2/"Case 35 image 4.1.png" $2/$TRACED_SUBFOLDER/I017.png
mv $2/"Case 36 image 3.1.png" $2/$TRACED_SUBFOLDER/I018.png
mv $2/"Case 37 image 2.1.png" $2/$TRACED_SUBFOLDER/I019.png
mv $2/"Case 38 image 1.1.png" $2/$TRACED_SUBFOLDER/I020.png
mv $2/"Case 38 image 3.1.png" $2/$TRACED_SUBFOLDER/I021.png
mv $2/"Case 40 image 2.1.png" $2/$TRACED_SUBFOLDER/I022.png
mv $2/"Case 43 image 2.1.png" $2/$TRACED_SUBFOLDER/I023.png
mv $2/"Case 43 image 4.1.png" $2/$TRACED_SUBFOLDER/I024.png
mv $2/"Case 46 image 1.1.png" $2/$TRACED_SUBFOLDER/I025.png
mv $2/"Case 46 image 3.1.png" $2/$TRACED_SUBFOLDER/I026.png
mv $2/"Case 47 image 6.1.png" $2/$TRACED_SUBFOLDER/I027.png
mv $2/"Case 50 image 2.1.png" $2/$TRACED_SUBFOLDER/I028.png
mv $2/"Case 50 image 3.1.png" $2/$TRACED_SUBFOLDER/I029.png
mv $2/"Case 51 image 1.1.png" $2/$TRACED_SUBFOLDER/I030.png
mv $2/"Case 52 image 1.1.png" $2/$TRACED_SUBFOLDER/I031.png

echo "Convert sample images from .png to .jpg..."
cd $2/$CLEAN_SUBFOLDER
ls -1 *.png | xargs -n 1 bash -c 'convert "$0" "${0%.png}.jpg"'
rm *.png
cd ../..
cd $2/$TRACED_SUBFOLDER
ls -1 *.png | xargs -n 1 bash -c 'convert "$0" "${0%.png}.jpg"'
rm *.png
cd ../..

echo "Saving filled masks in subfolder $2/$FILLED_SUBFOLDER"
python gg_prepr.py mask -i $2/$TRACED_SUBFOLDER -o $2/$FILLED_SUBFOLDER

echo "Removing unnecessary generated files from subfolder $2/$FILLED_SUBFOLDER..."
cd $2/$FILLED_SUBFOLDER
# white subfolder
rm -fdR white
# cyan subfolder
mv cyan/*.png .
rm -fdR cyan
cd ../..

echo "Generating trimap file for Healthy Controls (HC)..."
python gg_prepr.py healthy -w 960 -hi 720 -cl 2
cp trimap_HC_960x720_cl2.png $2/$TRIMAP_HC_SUBFOLDER/IXXX.png

echo $(date +%d/%m/%Y)-$(date +%H:%M): script end ----
