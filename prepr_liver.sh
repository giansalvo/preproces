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

echo "Copying and renaming clean sample images to $2/$CLEAN_SUBFOLDER..."
# Luigi
# maligne
mv $2/"LCM001.png"  $2/$CLEAN_SUBFOLDER/LC001.png
mv $2/"LCM002.png"  $2/$CLEAN_SUBFOLDER/LC002.png
mv $2/"LCM003.png"  $2/$CLEAN_SUBFOLDER/LC003.png
mv $2/"LCM004.png"  $2/$CLEAN_SUBFOLDER/LC004.png
mv $2/"LCM005.png"  $2/$CLEAN_SUBFOLDER/LC005.png
mv $2/"LCM006.png"  $2/$CLEAN_SUBFOLDER/LC006.png
mv $2/"LCM007.png"  $2/$CLEAN_SUBFOLDER/LC007.png
mv $2/"LCM008.png"  $2/$CLEAN_SUBFOLDER/LC008.png
mv $2/"LCM009.png"  $2/$CLEAN_SUBFOLDER/LC009.png
# benigne
mv $2/"LCB010.png"  $2/$CLEAN_SUBFOLDER/LC010.png
# maligne
mv $2/"LCM011.png"  $2/$CLEAN_SUBFOLDER/LC011.png
mv $2/"LCM012.png"  $2/$CLEAN_SUBFOLDER/LC012.png
mv $2/"LCM013.png"  $2/$CLEAN_SUBFOLDER/LC013.png
mv $2/"LCM014.png"  $2/$CLEAN_SUBFOLDER/LC014.png
# benigne
mv $2/"LCB015.png"  $2/$CLEAN_SUBFOLDER/LC015.png
mv $2/"LCB016.png"  $2/$CLEAN_SUBFOLDER/LC016.png
# maligne
mv $2/"LCM017.png"  $2/$CLEAN_SUBFOLDER/LC017.png
mv $2/"LCM018.png"  $2/$CLEAN_SUBFOLDER/LC018.png
mv $2/"LCM019.png"  $2/$CLEAN_SUBFOLDER/LC019.png
mv $2/"LCM020.png"  $2/$CLEAN_SUBFOLDER/LC020.png
mv $2/"LCM021.png"  $2/$CLEAN_SUBFOLDER/LC021.png
mv $2/"LCM022.png"  $2/$CLEAN_SUBFOLDER/LC022.png
# benigne
mv $2/"LCB023.png"  $2/$CLEAN_SUBFOLDER/LC023.png
mv $2/"LCB024.png"  $2/$CLEAN_SUBFOLDER/LC024.png
mv $2/"LCB025.png"  $2/$CLEAN_SUBFOLDER/LC025.png
mv $2/"LCB026.png"  $2/$CLEAN_SUBFOLDER/LC026.png
# maligne
mv $2/"LCM027.png"  $2/$CLEAN_SUBFOLDER/LC027.png
mv $2/"LCM028.png"  $2/$CLEAN_SUBFOLDER/LC028.png
mv $2/"LCM029.png"  $2/$CLEAN_SUBFOLDER/LC029.png
mv $2/"LCM030.png"  $2/$CLEAN_SUBFOLDER/LC030.png
# benigne
mv $2/"LCB031.png"  $2/$CLEAN_SUBFOLDER/LC031.png
mv $2/"LCB032.png"  $2/$CLEAN_SUBFOLDER/LC032.png
mv $2/"LCB033.png"  $2/$CLEAN_SUBFOLDER/LC033.png
mv $2/"LCB034.png"  $2/$CLEAN_SUBFOLDER/LC034.png
# maligne
mv $2/"LCM035.png"  $2/$CLEAN_SUBFOLDER/LC035.png
mv $2/"LCM036.png"  $2/$CLEAN_SUBFOLDER/LC036.png
mv $2/"LCM037.png"  $2/$CLEAN_SUBFOLDER/LC037.png
mv $2/"LCM038.png"  $2/$CLEAN_SUBFOLDER/LC038.png
mv $2/"LCM039.png"  $2/$CLEAN_SUBFOLDER/LC039.png
mv $2/"LCM040.png"  $2/$CLEAN_SUBFOLDER/LC040.png
mv $2/"LCM041.png"  $2/$CLEAN_SUBFOLDER/LC041.png
mv $2/"LCM042.png"  $2/$CLEAN_SUBFOLDER/LC042.png
mv $2/"LCM043.png"  $2/$CLEAN_SUBFOLDER/LC043.png
mv $2/"LCM044.png"  $2/$CLEAN_SUBFOLDER/LC044.png
mv $2/"LCM045.png"  $2/$CLEAN_SUBFOLDER/LC045.png
# normale
mv $2/"LCN046.png"  $2/$CLEAN_SUBFOLDER/LC046.png
mv $2/"LCN047.png"  $2/$CLEAN_SUBFOLDER/LC047.png
mv $2/"LCN048.png"  $2/$CLEAN_SUBFOLDER/LC048.png
mv $2/"LCN049.png"  $2/$CLEAN_SUBFOLDER/LC049.png
mv $2/"LCN050.png"  $2/$CLEAN_SUBFOLDER/LC050.png
mv $2/"LCN051.png"  $2/$CLEAN_SUBFOLDER/LC051.png
mv $2/"LCN052.png"  $2/$CLEAN_SUBFOLDER/LC052.png
mv $2/"LCN053.png"  $2/$CLEAN_SUBFOLDER/LC053.png
mv $2/"LCN054.png"  $2/$CLEAN_SUBFOLDER/LC054.png
mv $2/"LCN055.png"  $2/$CLEAN_SUBFOLDER/LC055.png
mv $2/"LCN056.png"  $2/$CLEAN_SUBFOLDER/LC056.png
mv $2/"LCN057.png"  $2/$CLEAN_SUBFOLDER/LC057.png
mv $2/"LCN058.png"  $2/$CLEAN_SUBFOLDER/LC058.png
mv $2/"LCN059.png"  $2/$CLEAN_SUBFOLDER/LC059.png
mv $2/"LCN060.png"  $2/$CLEAN_SUBFOLDER/LC060.png
mv $2/"LCN061.png"  $2/$CLEAN_SUBFOLDER/LC061.png
mv $2/"LCN062.png"  $2/$CLEAN_SUBFOLDER/LC062.png
# benigne
mv $2/"LCB063.png"  $2/$CLEAN_SUBFOLDER/LC063.png
mv $2/"LCB064.png"  $2/$CLEAN_SUBFOLDER/LC064.png
mv $2/"LCB065.png"  $2/$CLEAN_SUBFOLDER/LC065.png

## Marco
# benigne
mv $2/"MAB001.png"  $2/$CLEAN_SUBFOLDER/MA001.png
# normali don't have second version
mv $2/"MAN002.png"  $2/$CLEAN_SUBFOLDER/MA002.png
# benigne
mv $2/"MAB003.png"  $2/$CLEAN_SUBFOLDER/MA003.png
mv $2/"MAB004.png"  $2/$CLEAN_SUBFOLDER/MA004.png
mv $2/"MAB005.png"  $2/$CLEAN_SUBFOLDER/MA005.png
mv $2/"MAB006.png"  $2/$CLEAN_SUBFOLDER/MA006.png
mv $2/"MAB007.png"  $2/$CLEAN_SUBFOLDER/MA007.png
mv $2/"MAB008.png"  $2/$CLEAN_SUBFOLDER/MA008.png
mv $2/"MAB009.png"  $2/$CLEAN_SUBFOLDER/MA009.png
#
mv $2/"MAB011.png"  $2/$CLEAN_SUBFOLDER/MA011.png
mv $2/"MAB012.png"  $2/$CLEAN_SUBFOLDER/MA012.png
mv $2/"MAB013.png"  $2/$CLEAN_SUBFOLDER/MA013.png
mv $2/"MAB014.png"  $2/$CLEAN_SUBFOLDER/MA014.png
mv $2/"MAB015.png"  $2/$CLEAN_SUBFOLDER/MA015.png
mv $2/"MAB016.png"  $2/$CLEAN_SUBFOLDER/MA016.png
#
mv $2/"MAN017.png"  $2/$CLEAN_SUBFOLDER/MA017.png
mv $2/"MAN018.png"  $2/$CLEAN_SUBFOLDER/MA018.png
mv $2/"MAN019.png"  $2/$CLEAN_SUBFOLDER/MA019.png
mv $2/"MAN020.png"  $2/$CLEAN_SUBFOLDER/MA020.png
#
mv $2/"MAB021.png"  $2/$CLEAN_SUBFOLDER/MA021.png
#
mv $2/"MAM022.png"  $2/$CLEAN_SUBFOLDER/MA022.png
#
mv $2/"MAB023.png"  $2/$CLEAN_SUBFOLDER/MA023.png
mv $2/"MAB024.png"  $2/$CLEAN_SUBFOLDER/MA024.png
mv $2/"MAB025.png"  $2/$CLEAN_SUBFOLDER/MA025.png
#
mv $2/"MAN026.png"  $2/$CLEAN_SUBFOLDER/MA026.png
mv $2/"MAN027.png"  $2/$CLEAN_SUBFOLDER/MA027.png
#
mv $2/"MAM028.png"  $2/$CLEAN_SUBFOLDER/MA028.png
#
mv $2/"MAN029.png"  $2/$CLEAN_SUBFOLDER/MA029.png
#
mv $2/"MAB030.png"  $2/$CLEAN_SUBFOLDER/MA030.png
mv $2/"MAM031.png"  $2/$CLEAN_SUBFOLDER/MA031.png
#
mv $2/"MAN032.png"  $2/$CLEAN_SUBFOLDER/MA032.png
mv $2/"MAN033.png"  $2/$CLEAN_SUBFOLDER/MA033.png
mv $2/"MAN034.png"  $2/$CLEAN_SUBFOLDER/MA034.png
mv $2/"MAN035.png"  $2/$CLEAN_SUBFOLDER/MA035.png
#
mv $2/"MAB036.png"  $2/$CLEAN_SUBFOLDER/MA036.png
#
mv $2/"MAN037.png"  $2/$CLEAN_SUBFOLDER/MA037.png
#
mv $2/"MAN038.png"  $2/$CLEAN_SUBFOLDER/MA038.png
mv $2/"MAN039.png"  $2/$CLEAN_SUBFOLDER/MA039.png
mv $2/"MAN040.png"  $2/$CLEAN_SUBFOLDER/MA040.png
#
mv $2/"MAB041.png"  $2/$CLEAN_SUBFOLDER/MA041.png
#
mv $2/"MAM042.png"  $2/$CLEAN_SUBFOLDER/MA042.png
#
mv $2/"MAN043.png"  $2/$CLEAN_SUBFOLDER/MA043.png
#
mv $2/"MAN045.png"  $2/$CLEAN_SUBFOLDER/MA045.png
mv $2/"MAN046.png"  $2/$CLEAN_SUBFOLDER/MA046.png
mv $2/"MAN047.png"  $2/$CLEAN_SUBFOLDER/MA047.png
mv $2/"MAN048.png"  $2/$CLEAN_SUBFOLDER/MA048.png
mv $2/"MAN049.png"  $2/$CLEAN_SUBFOLDER/MA049.png


echo "Copying and renaming traced images to $2/$TRACED_SUBFOLDER..."
# Luigi
# maligne
mv $2/"LCM001.1.png"  $2/$TRACED_SUBFOLDER/LC001.png
mv $2/"LCM002.1.png"  $2/$TRACED_SUBFOLDER/LC002.png
mv $2/"LCM003.1.png"  $2/$TRACED_SUBFOLDER/LC003.png
mv $2/"LCM004.1.png"  $2/$TRACED_SUBFOLDER/LC004.png
mv $2/"LCM005.1.png"  $2/$TRACED_SUBFOLDER/LC005.png
mv $2/"LCM006.1.png"  $2/$TRACED_SUBFOLDER/LC006.png
mv $2/"LCM007.1.png"  $2/$TRACED_SUBFOLDER/LC007.png
mv $2/"LCM008.1.png"  $2/$TRACED_SUBFOLDER/LC008.png
mv $2/"LCM009.1.png"  $2/$TRACED_SUBFOLDER/LC009.png
# benigne
mv $2/"LCB010.1.png"  $2/$TRACED_SUBFOLDER/LC010.png
# maligne 11-14
mv $2/"LCM011.1.png"  $2/$TRACED_SUBFOLDER/LC011.png
mv $2/"LCM012.1.png"  $2/$TRACED_SUBFOLDER/LC012.png
mv $2/"LCM013.1.png"  $2/$TRACED_SUBFOLDER/LC013.png
mv $2/"LCM014.1.png"  $2/$TRACED_SUBFOLDER/LC014.png
# benigne
mv $2/"LCB015.1.png"  $2/$TRACED_SUBFOLDER/LC015.png
mv $2/"LCB016.1.png"  $2/$TRACED_SUBFOLDER/LC016.png
# maligne 11-14
mv $2/"LCM017.1.png"  $2/$TRACED_SUBFOLDER/LC017.png
mv $2/"LCM018.1.png"  $2/$TRACED_SUBFOLDER/LC018.png
mv $2/"LCM019.1.png"  $2/$TRACED_SUBFOLDER/LC019.png
mv $2/"LCM020.1.png"  $2/$TRACED_SUBFOLDER/LC020.png
mv $2/"LCM021.1.png"  $2/$TRACED_SUBFOLDER/LC021.png
mv $2/"LCM022.1.png"  $2/$TRACED_SUBFOLDER/LC022.png
# benigne
mv $2/"LCB023.1.png"  $2/$TRACED_SUBFOLDER/LC023.png
mv $2/"LCB024.1.png"  $2/$TRACED_SUBFOLDER/LC024.png
mv $2/"LCB025.1.png"  $2/$TRACED_SUBFOLDER/LC025.png
mv $2/"LCB026.1.png"  $2/$TRACED_SUBFOLDER/LC026.png
# maligne
mv $2/"LCM027.1.png"  $2/$TRACED_SUBFOLDER/LC027.png
mv $2/"LCM028.1.png"  $2/$TRACED_SUBFOLDER/LC028.png
mv $2/"LCM029.1.png"  $2/$TRACED_SUBFOLDER/LC029.png
mv $2/"LCM030.1.png"  $2/$TRACED_SUBFOLDER/LC030.png
# benigne
mv $2/"LCB031.1.png"  $2/$TRACED_SUBFOLDER/LC031.png
mv $2/"LCB032.1.png"  $2/$TRACED_SUBFOLDER/LC032.png
mv $2/"LCB033.1.png"  $2/$TRACED_SUBFOLDER/LC033.png
mv $2/"LCB034.1.png"  $2/$TRACED_SUBFOLDER/LC034.png
# maligne
mv $2/"LCM035.1.png"  $2/$TRACED_SUBFOLDER/LC035.png
mv $2/"LCM036.1.png"  $2/$TRACED_SUBFOLDER/LC036.png
mv $2/"LCM037.1.png"  $2/$TRACED_SUBFOLDER/LC037.png
mv $2/"LCM038.1.png"  $2/$TRACED_SUBFOLDER/LC038.png
mv $2/"LCM039.1.png"  $2/$TRACED_SUBFOLDER/LC039.png
mv $2/"LCM040.1.png"  $2/$TRACED_SUBFOLDER/LC040.png
mv $2/"LCM041.1.png"  $2/$TRACED_SUBFOLDER/LC041.png
mv $2/"LCM042.1.png"  $2/$TRACED_SUBFOLDER/LC042.png
mv $2/"LCM043.1.png"  $2/$TRACED_SUBFOLDER/LC043.png
mv $2/"LCM044.1.png"  $2/$TRACED_SUBFOLDER/LC044.png
mv $2/"LCM045.1.png"  $2/$TRACED_SUBFOLDER/LC045.png
# normal images don't have traced version
# from 46 to 62
# benigne
mv $2/"LCB063.1.png"  $2/$TRACED_SUBFOLDER/LC063.png
mv $2/"LCB064.1.png"  $2/$TRACED_SUBFOLDER/LC064.png
mv $2/"LCB065.1.png"  $2/$TRACED_SUBFOLDER/LC065.png

## Marco
# benigne
mv $2/"MAB001.1.png"  $2/$TRACED_SUBFOLDER/MA001.png
# normal images don't have traced version
# benigne
mv $2/"MAB003.1.png"  $2/$TRACED_SUBFOLDER/MA003.png
mv $2/"MAB004.1.png"  $2/$TRACED_SUBFOLDER/MA004.png
mv $2/"MAB005.1.png"  $2/$TRACED_SUBFOLDER/MA005.png
mv $2/"MAB006.1.png"  $2/$TRACED_SUBFOLDER/MA006.png
mv $2/"MAB007.1.png"  $2/$TRACED_SUBFOLDER/MA007.png
mv $2/"MAB008.1.png"  $2/$TRACED_SUBFOLDER/MA008.png
mv $2/"MAB009.1.png"  $2/$TRACED_SUBFOLDER/MA009.png
#
mv $2/"MAM011.1.png"  $2/$TRACED_SUBFOLDER/MA011.png
mv $2/"MAB012.1.png"  $2/$TRACED_SUBFOLDER/MA012.png
mv $2/"MAB013.1.png"  $2/$TRACED_SUBFOLDER/MA013.png
mv $2/"MAB014.1.png"  $2/$TRACED_SUBFOLDER/MA014.png
mv $2/"MAB015.1.png"  $2/$TRACED_SUBFOLDER/MA015.png
mv $2/"MAB016.1.png"  $2/$TRACED_SUBFOLDER/MA016.png
#
mv $2/"MAB021.1.png"  $2/$TRACED_SUBFOLDER/MA021.png
#
mv $2/"MAM022.1.png"  $2/$TRACED_SUBFOLDER/MA022.png
#
mv $2/"MAB023.1.png"  $2/$TRACED_SUBFOLDER/MA023.png
mv $2/"MAB024.1.png"  $2/$TRACED_SUBFOLDER/MA024.png
mv $2/"MAB025.1.png"  $2/$TRACED_SUBFOLDER/MA025.png
#
mv $2/"MAM028.1.png"  $2/$TRACED_SUBFOLDER/MA028.png
#
mv $2/"MAB030.1.png"  $2/$TRACED_SUBFOLDER/MA030.png
#
mv $2/"MAM031.1.png"  $2/$TRACED_SUBFOLDER/MA031.png
#
mv $2/"MAB036.1.png"  $2/$TRACED_SUBFOLDER/MA036.png
#
mv $2/"MAB041.1.png"  $2/$TRACED_SUBFOLDER/MA041.png
mv $2/"MAM042.1.png"  $2/$TRACED_SUBFOLDER/MA042.png


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


# Generating trimap files from masks
python gg_prepr.py trimap -i $2/$FILLED_SUBFOLDER -o $2/$TRIMAP_SUBFOLDER -cl 2

echo "Generating trimap file for Healthy Controls (HC)..."
python gg_prepr.py healthy -w 400 -hi 400 -cl 2
## Luigi
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_HC_SUBFOLDER/IXXX.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC046.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC047.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC048.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC049.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC050.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC051.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC052.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC053.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC054.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC055.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC056.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC057.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC058.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC059.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC060.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC061.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/LC062.png
## Marco
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA002.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA017.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA018.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA019.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA020.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA026.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA027.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA029.png

cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA032.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA033.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA034.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA035.png
#
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA037.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA038.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA039.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA040.png
#
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA043.png
#
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA045.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA046.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA047.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA048.png
cp trimap_HC_400x400_cl2.png $2/$TRIMAP_SUBFOLDER/BIN/MA049.png


echo $(date +%d/%m/%Y)-$(date +%H:%M): script end ----
