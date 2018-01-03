# JPEG-Coding-and-decoding
Use Matlab to coding a JPEG and then decoding. This also contains Gaussian filter and Median filter.

Getting Started
This program is used for practicing the encoding and processing of digital images. 
This contains the following process:
color conversion
size conversion
DCT
Quantize
Zig-zag
Run-length Code
Huffman Code(Not finish yet)

Gaussian filter
Median filter

Prerequisites
System Environment: Windows 10
Software: Matlab 2014
Source file: indoor.jpg and outdoor.jpg, indoor2.m and outdoor2.m

the steps of running the program
download all the file and upzip in a local directory 
double click matlab 2014
at matlab, open indoor2.m and outdoor2.m file
run the code
show the result and check the file in the same directory

file explain:
indoor2.m  ---source code file
indoor.jpg  ---source jpg file
indoor_1024gray.jpg  ---convert source jpg file to gray
indoor_1024convert.jpg  ---convert gray jpg file to 1024*1024
indoor_1024DF.jpg  --- the image after DCT convertion
indoor_1024ReverseDF.jpg ---the image after reverse DCT convertion
indoor_1024reverse.jpg ---the decoding image
indoor_Quafilter_3x3.jpg ---Quafilter 3*3 file by median filter
indoor_Quafilter_5x5.jpg ---Quafilter 5*5 file by Gaussian filter
indoor_Quafilter_9x9.jpg ---Quafilter 9*9 file by median filter

outdoor2.m  ---source code file
outdoor.jpg  ---source jpg file
outdoor_1024gray.jpg  ---convert source jpg file to gray
outdoor_1024convert.jpg  ---convert gray jpg file to 1024*1024
outdoor_1024DF.jpg  --- the image after DCT convertion
outdoor_1024ReverseDF.jpg ---the image after reverse DCT convertion
outdoor_1024reverse.jpg ---the decoding image
outdoor_Quafilter_3x3.jpg ---Quafilter 3*3 file by median filter
outdoor_Quafilter_5x5.jpg ---Quafilter 5*5 file by Gaussian filter
outdoor_Quafilter_9x9.jpg ---Quafilter 9*9 file by median filter


Versioning
1.0.0

Authors
Huafu Hu 
Computer Science of Georgia State University
huhuapop@outlook.com/hhu4@student.gsu.edu 

Quote
Use some code for Run-length Code model 
https://www.mathworks.com/matlabcentral/fileexchange/15335-jpeg-encoder-decoder?requestedDomain=www.mathworks.com


