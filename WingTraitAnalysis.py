#install 
#cmd
# brew install opencv
# make virtual environment: uv venv

#load packages
import cv2
import numpy as np

#load raw image
image = cv2.imread('/Users/lbuckley/yolotemp/images/testimages/UCSB-IZC00006871_1.jpg.jpg')
image = cv2.imread('/Users/laurenbuckley/PieridTest/butterfly_testimages/data/SDNHM212512.jpg.png')

#load masks
#rt forewing
mask_rfw = cv2.imread('/Users/lbuckley/yolotemp/images/testimages_0ac29b92-5803-5b07-8308-0f9d0dddcf2e/masks/UCSB-IZC00006871_1.jpg_cls1.png')
mask_rfw = cv2.imread('/Users/laurenbuckley/PieridTest/testset_aa666eb1-ece0-5d23-94aa-1969adf8a7e3/masks/SDNHM212512.jpg_cls1.png')

#left forewing
mask_lfw = cv2.imread('/Users/lbuckley/yolotemp/images/testimages_0ac29b92-5803-5b07-8308-0f9d0dddcf2e/masks/UCSB-IZC00006871_1.jpg_cls2.png')
mask_lfw = cv2.imread('/Users/laurenbuckley/PieridTest/testset_aa666eb1-ece0-5d23-94aa-1969adf8a7e3/masks/SDNHM212512.jpg_cls2.png')

#rt hindwing
mask_rhw = cv2.imread('/Users/lbuckley/yolotemp/images/testimages_0ac29b92-5803-5b07-8308-0f9d0dddcf2e/masks/UCSB-IZC00006871_1.jpg_cls3.png')
mask_rhw = cv2.imread('/Users/laurenbuckley/PieridTest/testset_aa666eb1-ece0-5d23-94aa-1969adf8a7e3/masks/SDNHM212512.jpg_cls3.png')

#left highwing
mask_lhw = cv2.imread('/Users/lbuckley/yolotemp/images/testimages_0ac29b92-5803-5b07-8308-0f9d0dddcf2e/masks/UCSB-IZC00006871_1.jpg_cls4.png')
mask_lhw = cv2.imread('/Users/laurenbuckley/PieridTest/testset_aa666eb1-ece0-5d23-94aa-1969adf8a7e3/masks/SDNHM212512.jpg_cls4.png')

#convert to grayscale
image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
mask_rfw = cv2.cvtColor(mask_rfw, cv2.COLOR_BGR2GRAY)
mask_lfw = cv2.cvtColor(mask_lfw, cv2.COLOR_BGR2GRAY)
mask_rhw = cv2.cvtColor(mask_rhw, cv2.COLOR_BGR2GRAY)
mask_lhw = cv2.cvtColor(mask_lhw, cv2.COLOR_BGR2GRAY)

##show image
#cv2.imshow("image",image)
## waits for user to press any key
#cv2.waitKey(0)
## closing all open windows
#cv2.destroyAllWindows()

#--------
#tool for finding extreme ne and nw points 
#https://pyimagesearch.com/2016/04/11/finding-extreme-points-in-contours-with-opencv/

#----
#function to place circle as far to the side as possible and centered on wing

def position_circle(contour, circle_diameter, image_shape, side='left'):
    # Create a mask from the contour
    mask = np.zeros(image_shape[:2], dtype=np.uint8)
    cv2.drawContours(mask, [contour], 0, 255, -1)

    radius = circle_diameter // 2
    
    # Find the leftmost and rightmost points of the contour
    leftmost = tuple(contour[contour[:,:,0].argmin()][0])
    rightmost = tuple(contour[contour[:,:,0].argmax()][0])

    if side == 'left':
        x_range = range(leftmost[0], rightmost[0] - circle_diameter)
    elif side == 'right':
        x_range = range(rightmost[0] - circle_diameter, leftmost[0], -1)
    else:
        raise ValueError("Side must be 'left' or 'right'")

    for x in x_range:
        for y in range(image_shape[0]):
            # Create a temporary circular mask
            temp_mask = np.zeros(image_shape[:2], dtype=np.uint8)
            cv2.circle(temp_mask, (x + radius, y), radius, 255, -1)
            
            # Check if the circle fits entirely within the contour
            if cv2.countNonZero(cv2.bitwise_and(mask, temp_mask)) == cv2.countNonZero(temp_mask):
                return (x + radius, y)
    
    return None  # If no position is found

#----------------
#vertically center the mask within the contour if the contour is vertically bigger than the mask

def center_circle_mask(contour, center_x, diameter, image_shape):
    # Create a mask from the contour
    contour_mask = np.zeros(image_shape[:2], dtype=np.uint8)
    cv2.drawContours(contour_mask, [contour], 0, 255, -1)

    # Find the vertical extent of the contour at the given x-coordinate
    y_values = contour_mask[:, center_x]
    y_min = np.min(np.where(y_values > 0))
    y_max = np.max(np.where(y_values > 0))
    contour_height = y_max - y_min + 1

    # Center the circle vertically within the available space
    center_y = (y_min + y_max) // 2
    radius = diameter // 2

    # Create the circular mask
    circle_mask = np.zeros(image_shape[:2], dtype=np.uint8)
    cv2.circle(circle_mask, (center_x, center_y), radius, 255, -1)

    # Check if the circle fits within the contour
    intersection = cv2.bitwise_and(contour_mask, circle_mask)
    if cv2.countNonZero(intersection) == cv2.countNonZero(circle_mask):
        return (center_x, center_y)
    else:
        # If it doesn't fit, try to adjust vertically
        for offset in range(1, radius):
            for sign in [-1, 1]:
                new_center_y = center_y + sign * offset
                cv2.circle(circle_mask, (center_x, new_center_y), radius, 255, -1)
                intersection = cv2.bitwise_and(contour_mask, circle_mask)
                if cv2.countNonZero(intersection) == cv2.countNonZero(circle_mask):
                    return (center_x, new_center_y)
                cv2.circle(circle_mask, (center_x, new_center_y), radius, 0, -1)  # Clear the mask

    return None  # Circle doesn't fit

#-----------------------------
#pip3 install scikit-image
#pip3 install scipy

from skimage.morphology import skeletonize
from scipy.ndimage import distance_transform_edt

#Function to find medial axis (or longest axis)
def estimate_wing_medial_axis(image_path):
    # Read the image
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    
    # Threshold the image to create a binary mask
    _, binary = cv2.threshold(img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    
    # Invert the binary image if necessary (wing should be white)
    if np.sum(binary == 255) < np.sum(binary == 0):
        binary = cv2.bitwise_not(binary)
    
    # Compute the distance transform
    dist_transform = distance_transform_edt(binary)
    
    # Normalize the distance transform for visualization
    dist_transform = cv2.normalize(dist_transform, None, 0, 255, cv2.NORM_MINMAX)
    dist_transform = np.uint8(dist_transform)
    
    # Compute the skeleton using skimage
    skeleton = skeletonize(binary // 255)
    
    # Multiply the skeleton with the distance transform
    medial_axis = skeleton.astype(np.uint8) * dist_transform
    
    return binary, dist_transform, medial_axis

image_path = 'path/to/your/butterfly_wing_image.jpg'
binary, dist_transform, medial_axis = estimate_wing_medial_axis(image_path)

# Display results
cv2.imshow('Binary Wing', binary)
cv2.imshow('Distance Transform', dist_transform)
cv2.imshow('Medial Axis', medial_axis)
cv2.waitKey(0)
cv2.destroyAllWindows()

#Place circle as close to body as possible


#---------------------------
#TRAIT DFM: Doral forewing melanism
mask1= mask_rhw
side_lr= 'left' 

#apply mask
masked = cv2.bitwise_and(image, image, mask=mask1)

# Find contours of the mask
contours, _ = cv2.findContours(mask1, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

wing_contour = max(contours, key=cv2.contourArea)

# Draw the contours on the original image
outlined_image = image.copy()
cv2.drawContours(outlined_image, contours, -1, (0, 255, 0), 2)

#------
#Determine the wing length
x, y, w, h = cv2.boundingRect(wing_contour)
wing_length = max(w, h)

#make a circle for grayscale measurement that has a diameter that is 25% of wing length
circle_diameter = int(0.25 * wing_length)

#TEST for right forewing
center = position_circle(wing_contour, circle_diameter, image.shape, side=side_lr)

#if circle is diameter is smaller than vertical extent, center vertically
xval= center[0]
new_center = center_circle_mask(wing_contour, xval, circle_diameter, image.shape)

# Draw the result
result = image.copy()
cv2.drawContours(result, [wing_contour], 0, (0, 255, 0), 2)
cv2.circle(result, center, circle_diameter // 2, (0, 0, 255), 2)

#write out to check
#cv2.imwrite('/Users/lbuckley/yolotemp/images/image.jpg', result)
cv2.imwrite('/Users/laurenbuckley/PieridTest/image.jpg', result)

#---

#make mask
cv2.circle(mask, center, circle_diameter // 2, 255, -1)

#Apply the mask:
masked_wing = cv2.bitwise_and(image, image, mask=mask)

#save image
#cv2.imwrite('/Users/lbuckley/yolotemp/images/masked_image.jpg', masked_wing)
cv2.imwrite('/Users/laurenbuckley/PieridTest/masked_image.jpg', masked_wing)

#calculate the average grayscale value
dfm = cv2.mean(masked_wing, mask=mask)[0]