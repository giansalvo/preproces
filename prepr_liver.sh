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
TRIMAP_SUBFOLDER="trimaps"

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

echo "Fix file extension BUG"
cd $1
ls -1 *.JPG | xargs -n 1 bash -c 'mv "$0" "${0%.JPG}.jpg_temp"'
ls -1 *.jpg_temp | xargs -n 1 bash -c 'mv "$0" "${0%.jpg_temp}.jpg"'
cd ..

echo "Start cropping sample images"
# python gg_prepr.py anonymize -i "$1" -o "$2" -x=0 -y=0 -w=800 -hi=200
# # clean bottom of images
# python gg_prepr.py anonymize -i "$2" -o "$2" -x=0 -y=600 -w=800 -hi=200
python gg_prepr.py crop -i "$1" -o "$2" -x=200 -y=200 -w=400 -hi=400


echo "Creating subfolders of $2..."
#mkdir $2
mkdir $2/$CLEAN_SUBFOLDER
mkdir $2/$TRACED_SUBFOLDER
mkdir $2/$FILLED_SUBFOLDER
mkdir $2/$TRIMAP_HC_SUBFOLDER
mkdir $2/$TRIMAP_SUBFOLDER
cd $2

echo "Copying and renaming traced images to $2/$TRACED_SUBFOLDER..."
# MA malign traced
for f in MAM*.1.png; 
do
    echo "$f"
    mv "$f" "$TRACED_SUBFOLDER/$(echo $f | sed 's/^MAM\(\w\+\).1.png/MA\1.png/g')"
done

# MA benign traced
for f in MAB*.1.png; 
do
    echo "$f"
    mv "$f" "$TRACED_SUBFOLDER/$(echo $f | sed 's/^MAB\(\w\+\).1.png/MA\1.png/g')"
done

# LC malign traced
for f in LCM*.1.png; 
do
    echo "$f"
    mv "$f" "$TRACED_SUBFOLDER/$(echo $f | sed 's/^LCM\(\w\+\).1.png/LC\1.png/g')"
done

# LC benign traced
for f in LCB*.1.png; 
do
    echo "$f"
    mv "$f" "$TRACED_SUBFOLDER/$(echo $f | sed 's/^LCB\(\w\+\).1.png/LC\1.png/g')"
done

echo "Copying and renaming clean sample images to $2/$CLEAN_SUBFOLDER..."
# MA malign clean
for f in MAM*.png; 
do
    echo "$f"
    mv "$f" "$CLEAN_SUBFOLDER/$(echo $f | sed 's/^MAM\(\w\+\).png/MA\1.png/g')"
done

# MA benign clean
for f in MAB*.png; 
do
    echo "$f"
    mv "$f" "$CLEAN_SUBFOLDER/$(echo $f | sed 's/^MAB\(\w\+\).png/MA\1.png/g')"
done

# LC malign clean
for f in LCM*.png; 
do
    echo "$f"
    mv "$f" "$CLEAN_SUBFOLDER/$(echo $f | sed 's/^LCM\(\w\+\).png/LC\1.png/g')"
done

# LC benign clean
for f in LCB*.png; 
do
    echo "$f"
    mv "$f" "$CLEAN_SUBFOLDER/$(echo $f | sed 's/^LCB\(\w\+\).png/LC\1.png/g')"
done

echo "Copying and renaming healthy controls' images to $2/$CLEAN_SUBFOLDER..."
# MA normal clean
for f in MAN*.png; 
do
    echo "$f"
    mv "$f" "$CLEAN_SUBFOLDER/$(echo $f | sed 's/^MAN\(\w\+\).png/MA\1.png/g')"
done

# LC normal clean
for f in LCN*.png; 
do
    echo "$f"
    mv "$f" "$CLEAN_SUBFOLDER/$(echo $f | sed 's/^LCN\(\w\+\).png/LC\1.png/g')"
done

echo "Convert sample images from .png to .jpg..."
cd $CLEAN_SUBFOLDER
ls -1 *.png | xargs -n 1 bash -c 'convert "$0" "${0%.png}.jpg"'
rm *.png
cd ..
cd $TRACED_SUBFOLDER
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


# Generating trimap files from masks
python gg_prepr.py trimap -i $2/$FILLED_SUBFOLDER -o $2/$TRIMAP_SUBFOLDER -cl 2

echo "Generating trimap file for Healthy Controls (HC)..."
python gg_prepr.py healthy -w 400 -hi 400 -cl 2
## Luigi
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_HC_SUBFOLDER/IXXX.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC046.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC047.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC048.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC049.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC050.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC051.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC052.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC053.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC054.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC055.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC056.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC057.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC058.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC059.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC060.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC061.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC062.png
## Marco
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA002.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA017.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA018.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA019.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA020.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA026.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA027.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA029.png

cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA032.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA033.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA034.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA035.png
#
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA037.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA038.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA039.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA040.png
#
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA043.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA044.png
#
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA045.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA046.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA047.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA048.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA049.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA051.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA052.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA054.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA056.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA058.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA059.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA060.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA062.png



echo $(date +%d/%m/%Y)-$(date +%H:%M): script end ----
