# Introduction
This script allows to do some image preprocessing activities on sonography images.

The actions that can be performed are:
- anonymize;
- crop;
- fill area inside the trace;
- measure area;
- generate trimap images (visible and binary formats).

# Setup Environment

## Linux and MacOS
```sh
$ python -m venv env
$ source env/bin/activate
$ python -m pip install --upgrade pip
$ pip install -r requirements.txt
```

## Windows
```sh
> python -m venv env
> .\env\Scripts\activate
> python -m pip install --upgrade pip
> pip install -r requirements.txt
```

# How to use it
Copy all images in one folder, than call the script with the appropriate parameters. To get help from the script just type:
```sh
$ python gg_prepr.py -h
```

## Examples

```sh
$ python gg_prepr.py anonymize -i images_original -o images_anonym -x=0 -y=0 -w=640 -hi=100

$ python gg_prepr.py crop -i images_original -o images_cropped -x=330 -y=165 -w=300 -hi=300

$ python gg_prepr.py mask -i images_cropped -o images_masks

$ python gg_prepr.py measure -i images_masks -mf measures.txt

$ python gg_prepr.py trimap -i images_masks -o images_trimap
```

# Workflow
This is an example of suggested workflow that you can adapt to your needs:
1. select and rename files as needed;
2. gg_prepr.py crop (this usually will also anonymize);
3. gg_prepr.py mask;
4. manually refine masked images files (i.e. with Gimp);
5. gg_prepr.py trimap;
6. rename files to match image<->trimap.

# License

Copyright (C) 2022 Giansalvo Gusinu

Permission is hereby granted, free of charge, to any person obtaining a 
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

# Citation
If you use our code in your project please cite our article:

```
@article{gusinu2023segmentation,
  title={Segmentation of Substantia Nigra in Brain Parenchyma Sonographic Images Using Deep Learning},
  author={Gusinu, Giansalvo and Frau, Claudia and Trunfio, Giuseppe A and Solla, Paolo and Sechi, Leonardo Antonio},
  journal={Journal of Imaging},
  volume={10},
  number={1},
  pages={1},
  year={2023},
  publisher={MDPI}
}

```
