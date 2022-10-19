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
COPYRIGHT_NOTICE = "Copyright (C) 2022 Giansalvo Gusinu"
PROGRAM_VERSION = "1.0"

# CONSTANTS
ACTION_ANONYMIZE = "anonymize"
ACTION_CROP = "crop"
ACTION_MASK = "mask"
ACTION_MEASURE = "measure"
ACTION_TRIMAP = "trimap"
ACTION_HEALTHY = "healthy"
ACTION_IMBALANCE = "imbalance"
CROP_X_DEFAULT = 330
CROP_Y_DEFAULT = 165
CROP_W_DEFAULT = 300
CROP_H_DEFAULT = 300
ANONYMIZE_X_DEFAULT = 0
ANONYMIZE_Y_DEFAULT = 0
ANONYMIZE_W_DEFAULT = 1240
ANONYMIZE_H_DEFAULT = 100
VALUE_FOREGROUND    = 1
VALUE_BORDER        = 2
VALUE_BACKGROUND    = 3

# COLOUR MASKS
cyan_lower = np.array([34, 85, 30])
cyan_upper = np.array([180, 252, 234])
white_lower = np.array([0, 0, 255])
white_upper = np.array([180, 255, 255])
green_lower = np.array([1, 0, 0])
green_upper = np.array([80, 255, 255])
contour_color = (0, 255, 0)  # green contour (BGR)
fill_color = list(contour_color)

# DIRECTORIES
SUBDIR_WHITE = "white"
SUBDIR_CYAN = "cyan"
SUBDIR_BINARY = "bin"
SUBDIR_VISIBLE = "visible"

def measure_area(image_rgb, color_rgb):
    # Find all pixels where the 3 RGB values match "color", and count them
    result = np.count_nonzero(np.all(image_rgb == color_rgb, axis=2))
    return result


def anonimize(image, x=ANONYMIZE_X_DEFAULT, y=ANONYMIZE_Y_DEFAULT, 
                w=ANONYMIZE_W_DEFAULT, h=ANONYMIZE_H_DEFAULT):
    # Draw black background rectangle in the upper region of the image
    # _, w, _ = image.shape
    # x, y, w, h = 0, 0, w, 40
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
            # Save the file
            subdir = output_directory + "/" + SUBDIR_WHITE + "/"
            cv2.imwrite(subdir + fn + ".png", img_filled, [int(cv2.IMWRITE_PNG_COMPRESSION), 0])
            # cyan contours
            img_filled = fill_contours_cyan(input_directory + "/" + fname)
            # Save the file
            subdir = output_directory + "/" + SUBDIR_CYAN + "/"
            cv2.imwrite(subdir + fn + ".png", img_filled, [int(cv2.IMWRITE_PNG_COMPRESSION), 0])
    return


def generate_trimaps_all_files(input_directory, output_directory, n_cl=3):
    ext = ('.jpg', '.jpeg', '.png')
    print("input direcotry: " + input_directory)
    for fname in os.listdir(input_directory):
        print(fname)
        if fname.endswith(ext):
            fn, fext = os.path.splitext(os.path.basename(fname))
            fpath = os.path.join(input_directory, fname)
            img_visible, img_binary = generate_trimap(fpath, n_classes=n_cl)
            fpath = os.path.join(output_directory, SUBDIR_VISIBLE, fn + ".png")
            cv2.imwrite(fpath, img_visible, [int(cv2.IMWRITE_PNG_COMPRESSION), 0])
            fpath = os.path.join(output_directory, SUBDIR_BINARY, fn + ".png")
            cv2.imwrite(fpath, img_binary, [int(cv2.IMWRITE_PNG_COMPRESSION), 0])
    return


def generate_trimap(fname, erosion_iter=6, dilate_iter=6, n_classes=3):
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
    if n_classes == 2:
        unknowns[unknowns == 255] = 0
    else:
        unknowns[unknowns == 255] = 127
    trimap = cv2.add(mask, unknowns)
    # cv2.imwrite("mask.png",mask)
    # cv2.imwrite("dilate.png",dilate)
    # cv2.imwrite("tri.png",trimap)
    labels = trimap.copy()
    # print("Annotations before values' conversions:")
    # for i in range(256):
    #     n = np.sum(labels == i)
    #     print("number of {}={}".format(i, n))
    labels[trimap == 0]     = VALUE_BACKGROUND
    labels[trimap == 127]   = VALUE_BORDER
    labels[trimap == 255]   = VALUE_FOREGROUND   
    # print("Annotations after values' conversions:")
    # for i in range(256):
    #     n = np.sum(labels == i)
    #     print("number of {}={}".format(i, n))
    return trimap, labels


def anonymize_all_files(input_directory, output_directory, 
                x=ANONYMIZE_X_DEFAULT, y=ANONYMIZE_X_DEFAULT, 
                w=ANONYMIZE_W_DEFAULT, h=ANONYMIZE_H_DEFAULT):
    ext = ('.jpg', '.jpeg', '.png')
    for fname in os.listdir(input_directory):
        if fname.endswith(ext):
            fn, fext = os.path.splitext(os.path.basename(fname))
            img = cv2.imread(input_directory + "/" + fname)
            img = anonimize(img, x, y, w, h)
            cv2.imwrite(output_directory + "/" + fn + ".png", img,  [int(cv2.IMWRITE_PNG_COMPRESSION), 0])
    return

def crop_all_files(input_directory, output_directory, 
                x=CROP_X_DEFAULT, y=CROP_X_DEFAULT, w=CROP_W_DEFAULT, h=CROP_H_DEFAULT):
    ext = ('.jpg', '.jpeg', '.png')
    for fname in os.listdir(input_directory):
        if fname.endswith(ext):
            fn, fext = os.path.splitext(os.path.basename(fname))
            img = cv2.imread(input_directory + "/" + fname)
            img = img[y:y+h, x:x+w]
            cv2.imwrite(output_directory + "/" + fn + ".png", img,  [int(cv2.IMWRITE_PNG_COMPRESSION), 0])
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
                # img2 = scipy.ndimage.imread(filename)   # IS THIS FASTER? another way with scipy lib
                img_bn = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
                number_of_black_pix = np.sum(img_bn == 0)
                area_pixels = img.shape[0]*img.shape[1]-number_of_black_pix  # DEBUG IS THIS RELIABLE?
                area = (area_pixels - coeff_q) / coeff_m
                line = fname + ", " + str(area_pixels) + ", " + str(area) +"\n"
                f.write(line)
    return

def compute_imbalance(input_directory, output_file, n_classes=3):
    ext = ('.jpg', '.jpeg', '.png')
    npix_tot = np.empty(n_classes, dtype=int)
    npix = np.empty(n_classes, dtype=int)
    with open(output_file, 'w') as f:
        f.write("file_name")
        for i in range(n_classes):
            npix_tot[i] = 0
            f.write(", classes_{}".format(i))
        f.write(", total\n")

        for fname in os.listdir(input_directory):
            if fname.endswith(ext):
                fn, fext = os.path.splitext(os.path.basename(fname))
                img = cv2.imread(input_directory + "/" + fname, cv2.IMREAD_GRAYSCALE)

                # black_pixels_mask = np.all(img == [0, 0, 0], axis=-1)
                # non_black_pixels_mask = ~black_pixels_mask
                # a4 = np.sum(non_black_pixels_mask)

                # Measure the area
                # img2 = scipy.ndimage.imread(filename)   # IS THIS FASTER? another way with scipy lib
                # img_bn = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

                line = fname
                tot = 0
                for i in range(n_classes):
                    npix[i] = np.sum(img == i)
                    tot += npix[i]
                    npix_tot[i] += npix[i]
                    line = line + ", " + "{:d}".format(npix[i])
                line = line + ", " + "{:d}".format(tot) + "\n"
                f.write(line)
        line = "total:"
        tot = 0
        for i in range(n_classes):
            tot += npix_tot[i]
            line = line + ", " + "{:d}".format(npix_tot[i])
        line = line + ", " + "{:d}".format(tot) + "\n"
        f.write(line)
    return



#  main
parser = argparse.ArgumentParser(
    description=COPYRIGHT_NOTICE,
    epilog="Examples:\n"
           "         $python %(prog)s anonymize -i images_folder -o anonym_folder\n"
           "         $python %(prog)s anonymize -i images_folder -o anonym_folder -x=0 -y=0 -w=640 -hi=100\n"
           "\n"
           "         $python %(prog)s crop -i images_folder -o cropped_folder\n"
           "         $python %(prog)s crop -i images_folder -o cropped_folder -x=330 -y=165 -w=300 -hi=300\n"
           "\n"
           "         $python %(prog)s mask -i cropped_folder -o masks_folder\n"
           "\n"
           "         $python %(prog)s measure -i trimap_folder -mf measures.txt\n"
           "\n"
           "         $python %(prog)s trimap -i masks_folder -o trimap_folder -cl 3\n"
           "\n"
           "         Generate trimap for Healthy Control with given width, height and number of classes:"
           "         $python %(prog)s healthy -w=width hi=height -cl 3\n"
           "\n"
           "         $python %(prog)s imbalance -i trimamp_folder -mf imbalance.txt\n",
            formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('--version', action='version', version='%(prog)s v.' + PROGRAM_VERSION)
group = parser.add_mutually_exclusive_group()
group.add_argument("-v", "--verbose", action="store_true")
group.add_argument("-q", "--quiet", action="store_true")
parser.add_argument("action", help="The action to be executed.",
        choices=(ACTION_ANONYMIZE, ACTION_CROP, ACTION_MASK, ACTION_MEASURE, ACTION_TRIMAP, ACTION_IMBALANCE, ACTION_HEALTHY))
parser.add_argument('-i', '--input_dir', required=False, help="The directory with the input images")
parser.add_argument("-o", "--output_dir", required=False, help="The directory with the resulting images")
parser.add_argument("-mf", "--measure_file", required=False, help="The file where to store measures")
parser.add_argument("-x", nargs="?", type=int, help="The starting point (x, y) used for: anonymize, crop.")
parser.add_argument("-y", nargs="?", type=int, help="The starting point (x, y) used for: anonymize, crop.")
parser.add_argument("-w", "--width", nargs="?", type=int, help="The width parameter is used for: anonymize, crop, healthy.")
parser.add_argument("-hi", "--height", nargs="?", type=int, help="The height parameter is used for: anonymize, crop, healthy.")
parser.add_argument("-cl", "--classes", nargs="?", type=int, required=False, help="Number of classes for each pixel in the trimap.")
args = parser.parse_args()

input_dir = args.input_dir
output_dir = args.output_dir

print(COPYRIGHT_NOTICE)
print("Program started.")
if args.action is None:
        parser.error("Missing parameter action. Check with parameter --help")

if args.action == ACTION_ANONYMIZE or args.action == ACTION_CROP or args.action == ACTION_MASK or \
    args.action == ACTION_TRIMAP or args.action == ACTION_MEASURE or args.action == ACTION_IMBALANCE:
    if input_dir is None:
        parser.error("Missing input directory.")
    if not os.path.isdir(input_dir):
        print("Error: input directory " + input_dir + " doesn't exist!")    
        exit()

if args.action == ACTION_ANONYMIZE or args.action == ACTION_CROP or args.action == ACTION_MASK or args.action == ACTION_TRIMAP:
    if args.output_dir is None:
        parser.error("Missing output directory.")
    if os.path.isdir(output_dir):
        print("Warning: output directory " + output_dir + " already exists.")
    else:
        print("Creating output directory " + output_dir)
        os.mkdir(output_dir)
    if args.action == ACTION_MASK:
        subdir = output_dir + "/" + SUBDIR_WHITE
        print("Creating output subdirectory " + subdir)
        os.mkdir(subdir)
        subdir = output_dir + "/" + SUBDIR_CYAN
        print("Creating output subdirectory " + subdir)
        os.mkdir(subdir)
    if args.action == ACTION_TRIMAP:
        subdir = output_dir + "/" + SUBDIR_VISIBLE
        print("Creating output subdirectory " + subdir)
        os.mkdir(subdir)
        subdir = output_dir + "/" + SUBDIR_BINARY
        print("Creating output subdirectory " + subdir)
        os.mkdir(subdir)

if args.action == ACTION_ANONYMIZE:
    print("Generating anonymized images for all files in the input directory...")
    if args.x is None:
        x_coord = ANONYMIZE_X_DEFAULT
    else:
        x_coord = args.x
    if args.y is None:
        y_coord = ANONYMIZE_Y_DEFAULT
    else:
        y_coord = args.y
    if args.width is None:
        width = ANONYMIZE_W_DEFAULT
    else:
        width = args.width
    if args.height is None:
        height = ANONYMIZE_H_DEFAULT
    else:
        height = args.height
    anonymize_all_files(input_dir, output_dir, x_coord, y_coord, width, height)
elif args.action == ACTION_CROP:
    print("Generating cropped images for all files in the input directory...")
    if args.x is None:
        x_coord = CROP_X_DEFAULT
    else:
        x_coord = args.x
    if args.y is None:
        y_coord = CROP_Y_DEFAULT
    else:
        y_coord = args.y
    if args.width is None:
        width = CROP_W_DEFAULT
    else:
        width = args.width
    if args.height is None:
        height = CROP_H_DEFAULT
    else:
        height = args.height
    crop_all_files(input_dir, output_dir, x_coord, y_coord, width, height)
elif args.action == ACTION_MASK:
    print("Generating visible masks (green on black) for all images in the input directory...")
    fill_contours_all_files(input_dir, output_dir)
elif args.action == ACTION_MEASURE:
    if args.measure_file is None:
        parser.error("Missing measure file.")
    print("Generating measures of the areas for all images in the input directory...")
    measure_all_files(input_dir, args.measure_file)
elif args.action == ACTION_TRIMAP:
    n_classes = args.classes
    if n_classes is None:
        n_classes = 3
    print("Generating trimaps for all images in the input directory...")
    print("Classes per pixel: " + str(n_classes))
    generate_trimaps_all_files(input_dir, output_dir, n_cl=n_classes)

elif args.action == ACTION_IMBALANCE:
    if args.measure_file is None:
        parser.error("Missing measure file paramenter. Check with --help.")
    print("Calcuating class imbalance and writing to output file...")
    compute_imbalance(input_dir, args.measure_file, 6)

elif args.action == ACTION_HEALTHY:
    n_classes = args.classes
    width = args.width
    height = args.height
    if width is None:
        parser.error("Missing -w width paramenter. Check syntax with --help.")
    if height is None:
        parser.error("Missing -hi height paramenter. Check syntax with --help.")
    if n_classes is None:
        parser.error("Missing -cl classes paramenter. Check syntax with --help.")

    fname = "trimap_HC_" + str(width) + "x" + str(height) + "_cl" + str(n_classes) + ".png"
    print("Saving healthy control trimap to file: " + fname)
    trimap = np.full(shape=(height, width, 1), fill_value=n_classes, dtype="uint8")
    cv2.imwrite(fname, trimap, [int(cv2.IMWRITE_PNG_COMPRESSION), 0])
print("Program ended.")
