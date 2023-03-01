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
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA071.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA099.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA110.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA116.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA187.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC072.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA096.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC081.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA120.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA082.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA078.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC092.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC078.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC095.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC093.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC084.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA072.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA114.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA074.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA077.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA083.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA107.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC083.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA080.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC079.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC076.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA063.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA095.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC094.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA067.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA167.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC025.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA102.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA157.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA149.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA137.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA056.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC019.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC011.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC055.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA064.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC080.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA093.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA084.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC001.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA161.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC051.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC036.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA184.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA098.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC065.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC033.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC028.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA139.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC054.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA031.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA164.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA041.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA189.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA156.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA085.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA002.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA134.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC077.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA159.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC021.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA007.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA088.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA195.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA129.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA168.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC071.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA011.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA030.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC074.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA024.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA051.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC032.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA166.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA163.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA172.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA115.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC101.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA165.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA070.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA180.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA073.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA103.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA100.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA101.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA104.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC073.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA097.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA086.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA108.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA081.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC085.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA112.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA113.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC075.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA111.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA105.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA042.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA133.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA126.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA015.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA010.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA161.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA185.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA095.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA167.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC005.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA025.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA175.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA152.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA116.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA172.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA041.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC049.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA141.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC014.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA046.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA159.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA146.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA050.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC033.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA117.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC095.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA118.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC100.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC010.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA123.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA014.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC102.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA089.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC027.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC059.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC071.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA162.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA094.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC065.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA002.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA030.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC104.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA156.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC048.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA017.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA075.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA165.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA122.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA004.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA036.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA193.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC082.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA084.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA170.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC029.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC015.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA065.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/MA052.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/bin/LC022.png

echo $(date +%d/%m/%Y)-$(date +%H:%M): script end ----
