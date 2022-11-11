# Overview
Machine vision code written in matlab capable of measuring the angular orientation of features in an image.  Originally designed for inline measurement of tubular braided structures, many of the features in this code are specific to that application.

The .mlapp program can be run in the MATLAB 2017 App Designer environment.
To see how the functions intereact with one-another, see the example.m file

### Braid angle measurement
The braid angle is defined as the angle between the fibers and the longitudinal direction of the composite part, denoted by theta.

![figure8](https://user-images.githubusercontent.com/25425685/35190875-b8dc905a-fe29-11e7-856b-054cfc305cee.jpg)

This measurement approach uses frequnecy domain image processing to obtain an estimate of the primary braid angle in the image.
The directions in the frequnecy domain with the strongest frequency responce are found with a search routine.

![figure4](https://user-images.githubusercontent.com/25425685/35190854-4e430242-fe29-11e7-941a-8c34767248b6.jpg)

### Image pre-processing
To comensate for the 3D surface profile of the tubular samples in the 2D images, an interpolation based unwrapping scheme has been develloped.
The selection of the unwrap angle, denoted by alpha, is used to choose the region of interest for which to perform the measurement

![figure10](https://user-images.githubusercontent.com/25425685/35190868-978255f2-fe29-11e7-8047-bed884f45501.jpg)

![figure11](https://user-images.githubusercontent.com/25425685/35190861-66790848-fe29-11e7-94eb-6734ea0a4653.jpg)



See the example.m file to see the process flow

Any GUI files are non-functional and under development
 
realVideoBraid.m and realVideoBraidGige.m are real-time video streaming scripts that call relevant functions
