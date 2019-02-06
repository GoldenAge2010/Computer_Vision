# Computer_Vision Projects

## Project 1  Motion Detection Using Simple Image Filtering
### In this project you will explore a simple technique for motion detection in image sequences captured with a stationary camera where most of the pixels belong to a stationary background and relatively small moving objects pass in front of the camera. In this case, the intensity values observed at a pixel over time is a constant or slowly varying signal, except when a moving object begins to pass through that pixel, in which case the intensity of the background is replaced by the intensity of the foreground object. Thus, we can detect a moving object by looking at large gradients in the temporal evolution of the pixel values.

## Project 2  Image Mosaicing
### In this project you will apply a Harris corner detector to ﬁnd corners in two images, automatically ﬁnd corresponding features, estimate a homography between the two images, and warp one image into the coordinate system of the second one to produce a mosaic containing the union of all pixels in the two images.

## Project 3  Dense Optical Flow
### In this project you will implement the Lucas-Kanade method for estimating dense optic ﬂow from a pair of images. The input is a pair of greyscale images taken from a video sequence, and the output will be two matrices containing the x and y components of the ﬂow vector at each pixel.

## Project 4  Target Tracking
### The Circulant Matrix (CM) tracker that we discussed in class is very eﬃcient ﬁnding a translated copy of the target template (from the previous frame) by computing many convolutions in a single shot. This is accomplished by ﬁnding the peak response of a ﬁlter applied to a region of the current frame that is expected to include the target. This ﬁlter changes from frame to frame and it is computed based on the FFT of a larger region which contains the target in the current frame. (Eﬃciency is obtained by applying this ﬁlter in the frequency domain). 

## Project Extra  STEREO
### Find interesting features and correspondences between the left and right images. You can use the CORNERS and NCC algorithms that you wrote/used for the second project or SIFT features and descriptors. Display your results in the same way you did for project 2 i.e. by connecting corresponding features with a line. Using lines of diﬀerent colors for diﬀerent points makes it easier to visualize the results.

### Write a program to estimate the Fundamental Matrix for each pair using the correspondences above and RANSAC to eliminate outliers. Display the inlier correspondences in the same way as above.

### Compute a dense disparity map using the Fundamental matrix to help reduce the search space. The output should be three images, one image with the vertical disparity component, and another image with the horizontal disparity component, and a third image representing the disparity vector using color (similar to what you use for optical ﬂow display). For gray scale display, scale the disparity values so the lowest disparity is 0 and the highest disparity is 255.
