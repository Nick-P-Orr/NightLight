%Computer Vision Final Project - 'Night Light'
%Nick Orr, orrn@wit.edu,
%Brendan Sileo, sileob@wit.edu

clc; close all; clear all;

A = imread('Night_Sample1.png');
B = imread('Night_Sample2.jpg');
ABlack = rgb2gray(A);
se1 = strel('square', 3);
ABlack2 = imdilate(ABlack, se1);
ABlack3 = imerode(ABlack, se1);
C = ABlack2-ABlack3;

I = ABlack;
gmag = imgradient(ABlack);
L = watershed(gmag);
Lrgb = label2rgb(L);
se = strel('disk',20);
Io = imopen(I,se);
Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);
Ioc = imclose(Io,se);
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
fgm = imregionalmax(Iobrcbr);
I2 = labeloverlay(I,fgm);
se2 = strel(ones(5,5));
fgm2 = imclose(fgm,se2);
fgm3 = imerode(fgm2,se2);
fgm4 = bwareaopen(fgm3,20);
I3 = labeloverlay(I,fgm4);
bw = imbinarize(Iobrcbr);
D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
title('Watershed Ridge Lines)')
gmag2 = imimposemin(gmag, bgm | fgm4);
L = watershed(gmag2);

M = containers.Map('KeyType','char','ValueType','any');

[wi, hi] = size(ABlack);

for x = 1:wi
       for y = 1:hi
          w = int2str(L(x,y));
          M(w) = [];
          M(w) = [M(w),ABlack(x,y)];
       end
end

N = containers.Map('KeyType','char','ValueType','any');

N('0') = 5;
N('1') = 4;
x=M.keys;
[xs1, xs2] = size(x);
for i = 1:xs2
    b = M.keys;
    h = b(i);
    h = char(h);
    d = M(h);
    N(h) = mean(d);
end

[wi, hi] = size(ABlack);
A = rgb2hsv(A);
hueImage = A(:, :, 1);
saturationImage = A(:, :, 2);
valueImage = A(:, :, 3);
for x = 1:wi
	for y = 1:hi
       num = L(x,y);
       num = int2str(num);
       num = N(num);
       num = num/255;
       pixel = valueImage(x,y);
       pixel = pixel + (.3-num);
       if pixel > 1
           pixel = 1;
       end
       valueImage(x,y) = pixel;
	end
end
disp(valueImage);
A = cat(3, hueImage, saturationImage, valueImage);
A = hsv2rgb(A);
imshow(A);


pause;
clc; close all; clear all;

% 
% -Convert image to black and white
% -Edge detection to pull different layers of scene
% -Calculate average intensity of layers
% -Compare intensities of each layer
% -Use gamma + white balance correction to brighten each layer of color image
% -Recombine layers
