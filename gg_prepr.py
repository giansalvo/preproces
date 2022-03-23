"""
Copyright (C) 2022 Giansalvo Gusinu <profgusinu@gmail.com>

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
"""
import argparse
import logging
import os
import time
from venv import logger
import cv2
import numpy as np

# COPYRIGHT NOTICE AND PROGRAM VERSION
COPYRIGHT_NOTICE = "Copyright (C) 2022 Giansalvo Gusinu <profgusinu@gmail.com>"
PROGRAM_VERSION = "0.5"

# CONSTANTS
CROP_X_DEFAULT = 330
CROP_Y_DEFAULT = 165
CROP_W_DEFAULT = 300
CROP_H_DEFAULT = 300

# COLOUR MASKS
cyan_lower = np.array([34, 85, 30])
cyan_upper = np.array([180, 252, 234])
white_lower = np.array([0, 0, 255])
white_upper = np.array([180, 255, 255])
green_lower = np.array([1, 0, 0])
green_upper = np.array([80, 255, 255])
contour_color = (0, 255, 0)  # green contour (BGR)
fill_color = list(contour_color)

def measure_area(image_rgb, color_rgb):
    # Find all pixels where the 3 RGB values match "color", and count them
    result = np.count_nonzero(np.all(image_rgb == color_rgb, axis=2))
    return result


def anonimize(image):
    # Draw black background rectangle in the upper region of the image
    _, w, _ = image.shape
    x, y, w, h = 0, 0, w, 40
    cv2.rectangle(image, (x, x), (x + w, y + h), (0, 0, 0), -1)
    return image


def put_text(image, text):
    # blue = (209, 80, 0, 255),  # font color
    white = (255, 255, 255, 255)  # font color
    x, y, w, h = 10, 40, 20, 40
    # Draw black background rectangle
    cv2.rectangle(image, (x, x), (x + w, y + h), (0, 0, 0), -1)
    cv2.putText(
        image,  # numpy array on which text is written
        text,  # text
        (x, y),  # position at which writing has to start
        cv2.FONT_HERSHEY_SIMPLEX,  # font family
        1,  # font size
        white,  # font color
        1)  # font stroke
    return image


def fill_contours_white(finput, num_extra_iteration=4):
    lower_color = white_lower
    upper_color = white_upper

    logging.basicConfig(level=logging.WARNING)
    logger = logging.getLogger('gians')

    # thick=3 NOT GOOD! thick=2 THE BEST BUT NEED SECOND PASS BECAUSE OF DISCONNECTIONS!
    contour_thick = 2
    #fn, fext = os.path.splitext(os.path.basename(finput))

    img_orig = cv2.imread(finput)
    img = img_orig.copy()
    (img_h, img_w) = img_orig.shape[:2]
    logger.info("Image loaded: " + str(img_w) + "x" + str(img_h))

    # change color space and set color mask
    imghsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    mask_color = cv2.inRange(imghsv, lower_color, upper_color)

    # PASS 1: Close contour
    # ksize=(3,3,) more disconnections; ksize=(5,5) THE BEST; ksize=(7,7) bigger border
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
    # iteration=2 NOT GOOD!
    img_close_contours = cv2.morphologyEx(mask_color, cv2.MORPH_CLOSE, kernel, iterations=1)

    # PASS 1: Find outer contours
    cnts, _ = cv2.findContours(img_close_contours, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    # img_contours = np.zeros((img.shape[0], img.shape[1], 3), dtype="uint8")  # RGB image black
    # cv2.drawContours(img_contours, cnts, -1, contour_color, contour_thick)

    # PASS 1: fill contours
    img_filled = np.zeros((img.shape[0], img.shape[1], 3), dtype="uint8")  # BGR image black
    cv2.fillPoly(img_filled, pts=cnts, color=fill_color)

    # sharpen contours: change all non-black pixels to "fill_color"
    img_green_seg = img_filled.copy()
    black_pixels_mask = np.all(img_green_seg == [0, 0, 0], axis=-1)
    non_black_pixels_mask = ~black_pixels_mask
    img_green_seg[non_black_pixels_mask] = [0, 255, 0]

    for x in range(num_extra_iteration):
        # Close contour
        imghsv = cv2.cvtColor(img_green_seg, cv2.COLOR_BGR2HSV)
        mask_green = cv2.inRange(imghsv, green_lower, green_upper)
        # ksize=(3,3) more disconnections; ksize=(5,5) THE BEST; ksize=(7,7) too bigger border
        kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
        # iteration=2 NOT GOOD!
        img_close_contours = cv2.morphologyEx(mask_green, cv2.MORPH_CLOSE, kernel, iterations=1)

        # Find outer contours
        cnts, _ = cv2.findContours(img_close_contours, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
        img_contours = np.zeros((img.shape[0], img.shape[1], 3), dtype="uint8")  # BGR black image
        cv2.drawContours(img_contours, cnts, -1, contour_color, contour_thick)
        img_green_seg = img_contours

    # PASS LAST: fill contours
    img_filled = np.zeros((img.shape[0], img.shape[1], 3), dtype="uint8")  # BGR black image
    cv2.fillPoly(img_filled, pts=cnts, color=fill_color)

    # PASS LAST: erosion
    kernel_erosion = np.ones((5, 5), np.uint8)
    # using the OpenCV erode command to morphologically process the images that user wants to modify
    img_filled = cv2.erode(img_filled, kernel_erosion, iterations=1)
    return img_filled


def fill_contours_cyan(finput, num_extra_iteration=3):
    lower_color = cyan_lower
    upper_color = cyan_upper

    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger('gians')

    # thick=3 NOT GOOD! thick=2 THE BEST BUT NEED SECOND PASS BECAUSE OF DISCONNECTIONS!
    contour_thick = 2

    img_orig = cv2.imread(finput)
    img = img_orig.copy()
    (img_h, img_w) = img_orig.shape[:2]
    logger.info("Image loaded: " + str(img_w) + "x" + str(img_h))

    # change color space and set color mask
    imghsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    mask_color = cv2.inRange(imghsv, lower_color, upper_color)

    # PASS 1: Close contour
    # ksize=(3,3,) more disconnections; ksize=(5,5) THE BEST; ksize=(7,7) bigger border
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
    # iteration=2 NOT GOOD!
    img_close_contours = cv2.morphologyEx(mask_color, cv2.MORPH_CLOSE, kernel, iterations=1)

    # PASS 1: Find outer contours
    cnts, _ = cv2.findContours(img_close_contours, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    img_contours = np.zeros((img.shape[0], img.shape[1], 3), dtype="uint8")  # RGB image black
    cv2.drawContours(img_contours, cnts, -1, contour_color, contour_thick)

    # PASS 1: fill contours
    img_filled = np.zeros((img.shape[0], img.shape[1], 3), dtype="uint8")  # BGR image black
    cv2.fillPoly(img_filled, pts=cnts, color=fill_color)

    # sharpen contours: change all non-black pixels to "fill_color"
    img_green_seg = img_filled.copy()
    black_pixels_mask = np.all(img_green_seg == [0, 0, 0], axis=-1)
    non_black_pixels_mask = ~black_pixels_mask
    img_green_seg[non_black_pixels_mask] = [0, 255, 0]

    for x in range(num_extra_iteration):
        # Close contour
        imghsv = cv2.cvtColor(img_green_seg, cv2.COLOR_BGR2HSV)
        mask_green = cv2.inRange(imghsv, green_lower, green_upper)
        # ksize=(3,3) more disconnections; ksize=(5,5) THE BEST; ksize=(7,7) too bigger border
        kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
        # iteration=2 NOT GOOD!
        img_close_contours = cv2.morphologyEx(mask_green, cv2.MORPH_CLOSE, kernel, iterations=1)

        # Find outer contours
        cnts, _ = cv2.findContours(img_close_contours, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
        img_contours = np.zeros((img.shape[0], img.shape[1], 3), dtype="uint8")  # BGR black image
        cv2.drawContours(img_contours, cnts, -1, contour_color, contour_thick)
        img_green_seg = img_contours
    
    # PASS LAST: fill contours
    img_filled = np.zeros((img.shape[0], img.shape[1], 3), dtype="uint8")  # BGR black image
    cv2.fillPoly(img_filled, pts=cnts, color=fill_color)

    # PASS LAST: erosion
    kernel_erosion = np.ones((5, 5), np.uint8)
    # using the OpenCV erode command to morphologically process the images that user wants to modify
    img_filled = cv2.erode(img_filled, kernel_erosion, iterations=1)
    return img_filled

def fill_contours_all_files(input_directory, output_directory):
    ext = ('.jpg', '.jpeg', '.png')
    for fname in os.listdir(input_directory):
        if fname.endswith(ext):
            fn, fext = os.path.splitext(os.path.basename(fname))

            # white contours
            img_filled = fill_contours_white(input_directory + "/" + fname)
            # # Measure the area
            # area = measure_area(cv2.cvtColor(img_filled, cv2.COLOR_BGR2RGB), fill_color)
            # put_text(img_filled, "Area=" + str(area) + " px")
            # Save file with text
            cv2.imwrite(output_directory + "/" + fn + "_white" + fext, img_filled, [int(cv2.IMWRITE_JPEG_QUALITY), 100])  # TODO check JPEG/PNG

            img_filled = fill_contours_cyan(input_directory + "/" + fname)
            cv2.imwrite(output_directory + "/" + fn + "_cyan" + fext, img_filled, [int(cv2.IMWRITE_JPEG_QUALITY), 100])  # TODO check JPEG/PNG
    return


def generate_trimaps_all_files(input_directory, output_directory):
    ext = ('.jpg', '.jpeg', '.png')
    for fname in os.listdir(input_directory):
        if fname.endswith(ext):
            fn, fext = os.path.splitext(os.path.basename(fname))
            img_visible, img_binary = generate_trimap(input_directory + "/" + fname)
            cv2.imwrite(output_directory + "/" + fn + fext, img_visible, [int(cv2.IMWRITE_JPEG_QUALITY), 100])  # TODO check JPEG/PNG
            cv2.imwrite(output_directory + "/" + fn + "_bin" + fext, img_binary, [int(cv2.IMWRITE_JPEG_QUALITY), 100])  # TODO check JPEG/PNG
            # cv2.imwrite(output_directory + "/" + fn + ".png", img,  [int(cv2.IMWRITE_PNG_COMPRESSION), 0])
    return

def generate_trimap(fname, erosion_iter=6, dilate_iter=6):
    mask = cv2.imread(fname, 0)
    # define a threshold, 128 is the middle of black and white in grey scale
    thresh = 128
    # threshold the image
    mask = cv2.threshold(mask, thresh, 255, cv2.THRESH_BINARY)[1]
    mask[mask == 1] = 255
    d_kernel = np.ones((3, 3))
    erode = cv2.erode(mask, d_kernel, iterations=erosion_iter)
    dilate = cv2.dilate(mask, d_kernel, iterations=dilate_iter)
    unknown1 = cv2.bitwise_xor(erode, mask)
    unknown2 = cv2.bitwise_xor(dilate, mask)
    unknowns = cv2.add(unknown1, unknown2)
    unknowns[unknowns == 255] = 127
    trimap = cv2.add(mask, unknowns)
    # cv2.imwrite("mask.png",mask)
    # cv2.imwrite("dilate.png",dilate)
    # cv2.imwrite("tri.png",trimap)
    labels = trimap.copy()
    labels[trimap == 127] = 1  # unknown
    labels[trimap == 255] = 2  # foreground
    return trimap, labels


def crop_all_files(input_directory, output_directory, 
                x=CROP_X_DEFAULT, y=CROP_X_DEFAULT, w=CROP_W_DEFAULT, h=CROP_H_DEFAULT):
    ext = ('.jpg', '.jpeg', '.png')
    for fname in os.listdir(input_directory):
        if fname.endswith(ext):
            fn, fext = os.path.splitext(os.path.basename(fname))
            img = cv2.imread(input_directory + "/" + fname)
            img = img[y:y+h, x:x+w]
            cv2.imwrite(output_directory + "/" + fn + fext, img, [int(cv2.IMWRITE_JPEG_QUALITY), 100])  # TODO check JPEG/PNG
            # cv2.imwrite(output_directory + "/" + fn + ".png", img,  [int(cv2.IMWRITE_PNG_COMPRESSION), 0])
    return


def measure_all_files(input_directory, output_file, coeff_m=1.0, coeff_q=0.0):
    ext = ('.jpg', '.jpeg', '.png')
    with open(output_file, 'w') as f:
        f.write("file_name, area_in_pixels, area\n")
        for fname in os.listdir(input_directory):
            if fname.endswith(ext):
                fn, fext = os.path.splitext(os.path.basename(fname))
                img = cv2.imread(input_directory + "/" + fname)

                # black_pixels_mask = np.all(img == [0, 0, 0], axis=-1)
                # non_black_pixels_mask = ~black_pixels_mask
                # a4 = np.sum(non_black_pixels_mask)

                # Measure the area
                #img2 = scipy.ndimage.imread(filename)   # IS THIS FASTER? another way with scipy lib
                img_bn = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
                number_of_black_pix = np.sum(img_bn == 0)
                area_pixels = img.shape[0]*img.shape[1]-number_of_black_pix  # DEBUG IS THIS RELIABLE?
                area = (area_pixels - coeff_q) / coeff_m
                line = fname + ", " + str(area_pixels) + ", " + str(area) +"\n"
                f.write(line)
    return


#  main
action_crop = "crop"
action_mask = "mask"
action_measure = "measure"
action_trimap = "trimap"

parser = argparse.ArgumentParser(
    description=COPYRIGHT_NOTICE,
    epilog="Examples:\n"
           "         >python %(prog)s crop -i images_original -o images_cropped\n"
           "         >python %(prog)s crop -i images_original -o images_cropped -x=330 -y=165 -w=300 -hi=300\n"
           "\n"
           "         >python %(prog)s mask -i images_cropped -o images_masks\n"
           "\n"
           "         >python %(prog)s measure -i images_masks -mf measures.txt\n"
           "\n"
           "         >python %(prog)s trimap -i images_masks -o images_trimap\n",
            formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('--version', action='version', version='%(prog)s v.' + PROGRAM_VERSION)
group = parser.add_mutually_exclusive_group()
group.add_argument("-v", "--verbose", action="store_true")
group.add_argument("-q", "--quiet", action="store_true")
parser.add_argument("action", help="The action: " 
        + action_crop + ", " + action_mask + ", " + action_measure + ", " + action_trimap,
        choices=(action_crop, action_mask, action_measure, action_trimap))
parser.add_argument('-i', '--input_dir', required=True, help="The directory with the input images")
parser.add_argument("-o", "--output_dir", required=False, help="The directory with the resulting images")
parser.add_argument("-mf", "--measure_file", required=False, help="The file where to store measures")
parser.add_argument("-x", nargs="?", type=int, default=330, help="The point of coordinate (x, y) is used as starting point when cropping")
parser.add_argument("-y", nargs="?", type=int, default=165, help="The point of coordinate (x, y) is used as starting point when cropping")
parser.add_argument("-w", "--weigth", nargs="?", type=int, default=300, help="The width of the resulting image after cropping")
parser.add_argument("-hi", "--heigth", nargs="?", type=int, default=300, help="The heigth of the resulting image after cropping")
args = parser.parse_args()

input_dir = args.input_dir
output_dir = args.output_dir

print(COPYRIGHT_NOTICE)
print("Program started.")
if args.action is None:
        parser.error("Missing parameter action. It must be one of: " 
                    + action_crop + action_mask + action_measure + action_trimap)

if not os.path.isdir(input_dir):
    print("Error: input directory " + input_dir + " doesn't exist!")    
    exit()
if args.action == action_crop or args.action == action_mask or args.action == action_trimap:
    if args.output_dir is None:
        parser.error("Missing output directory.")
    if os.path.isdir(output_dir):
        print("Warning: output directory " + output_dir + " already exists.")
    else:
        print("Creating output directory " + output_dir)
        os.mkdir(output_dir)

if args.action == action_crop:
    print("Generating cropped images for all files in the input directory...")
    if args.x is None:
        x_coord = CROP_X_DEFAULT
    else:
        x_coord = args.x
    if args.y is None:
        y_coord = CROP_Y_DEFAULT
    else:
        y_coord = args.y
    if args.weigth is None:
        weigth = CROP_W_DEFAULT
    else:
        weigth = args.weigth
    if args.heigth is None:
        heigth = CROP_H_DEFAULT
    else:
        heigth = args.heigth
    crop_all_files(input_dir, output_dir, x_coord, y_coord, weigth, heigth)
elif args.action == action_mask:
    print("Generating visible masks (green on black) for all images in the input directory...")
    fill_contours_all_files(input_dir, output_dir)
elif args.action == action_measure:
    if args.measure_file is None:
        parser.error("Missing measure file.")
    print("Generating measures of the areas for all images in the input directory...")
    measure_all_files(input_dir, args.measure_file)
elif args.action == action_trimap:
    print("Generating trimaps for all images in the input directory...")
    generate_trimaps_all_files(input_dir, output_dir)

print("Program ended.")

#  1. crop
#  2. manually select images: i.e. separate images with no neurologist's traces
#  3. basic segmentation: green on black visible mask
#  4. manual adjustments needed here: i.e. remove unwanted artifacts
#  5. trimap: visible, binary
#
#   TODO measure area TODO define output format (jason? xml? csv?); define input coeff