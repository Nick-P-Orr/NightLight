%Computer Vision Final Project - 'Night Light'
%Nick Orr, orrn@wit.edu,
%Brendan Sileo, sileob@wit.edu

clc; close all; clear all;
simpleGUI;

function simpleGUI
    hFig = figure('Visible','off', 'Menu','none', 'Name','Night Light', 'Resize','off', 'Position',[100 100 1050 600]);
    movegui(hFig,'center')          %# Move the GUI to the center of the screen

    hBtnGrp = uibuttongroup('Position',[0 0 0.1 1], 'Units','Normalized');
    uicontrol('Style','Radio', 'Parent',hBtnGrp, 'HandleVisibility','off', 'Position',[15 150 70 30], 'String','Load Image', 'Tag','s')
    uicontrol('Style','Radio', 'Parent',hBtnGrp, 'HandleVisibility','off', 'Position',[15 120 70 30], 'String','Web Cam', 'Tag','w')
    uicontrol('Style','Radio', 'Parent',hBtnGrp, 'HandleVisibility','off', 'Position',[15 90 70 30], 'String','Quit', 'Tag','q')
    

    uicontrol('Style','pushbutton', 'String','Choose', 'Position',[15  60 70 30], 'Callback',{@button_callback})

    set(hFig, 'Visible','on')        %# Make the GUI visible

    %# callback function
    function button_callback(src,ev)
        switch get(get(hBtnGrp,'SelectedObject'),'Tag')
            case 'w', webcamImage();
            case 's', selectImage();
            case 'q',  return;
        end
    end
end

function camGUI
    hFig = figure('Visible','off', 'Menu','none', 'Name','Night Light', 'Resize','off', 'Position',[100 100 1050 600]);
    movegui(hFig,'center')          %# Move the GUI to the center of the screen

    hBtnGrp = uibuttongroup('Position',[0 0 0.1 1], 'Units','Normalized');
    uicontrol('Style','Radio', 'Parent',hBtnGrp, 'HandleVisibility','off', 'Position',[15 150 70 30], 'String','Take Picture', 'Tag','tp')
    uicontrol('Style','Radio', 'Parent',hBtnGrp, 'HandleVisibility','off', 'Position',[15 120 70 30], 'String','Preview Picture', 'Tag','pp')
    
    uicontrol('Style','pushbutton', 'String','Take Picture', 'Position',[15  90 70 30], 'Callback',{@button_callback})

    set(hFig, 'Visible','on')        %# Make the GUI visible

    %# callback function
    function button_callback(src,ev)
        switch get(get(hBtnGrp,'SelectedObject'),'Tag')
            case 'tp', takeImage;
            case 'pp', previewImage;
        end
    end
end

function selectImage
    name = uigetfile('*');
    selectedImage = imread(name);
    processImage(selectedImage);
end

function takeImage
    cam = webcam;  
    img = snapshot(cam);
    clear cam;
    processImage(img);  
end

function previewImage
    cam = webcam;  
    preview(cam);
    pause;
    clear cam;
    takeImage;
end

function webcamImage
    camGUI;
end

function processImage(A) 
    ABlack = rgb2gray(A); 
    avg = mean2(ABlack);
    if avg < 75
        wavelength = 2.^(0:5) * 3;
        orientation = 0:45:135;
        g = gabor(wavelength,orientation);
        gabormag = imgaborfilt(ABlack,g);
        for i = 1:length(g)
            sigma = 0.5*g(i).Wavelength;
            gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),3*sigma); 
        end
        nrows = size(A,1);
        ncols = size(A,2);
        [X,Y] = meshgrid(1:ncols,1:nrows);
        featureSet = cat(3,ABlack,gabormag,X,Y);
        L = imsegkmeans(featureSet,5,'NormalizeInput',true);

        seg1 = getSegment(A, 1, L);
        seg2 = getSegment(A, 2, L);
        seg3 = getSegment(A, 3, L);
        seg4 = getSegment(A, 4, L);
        seg5 = getSegment(A, 5, L);

        final = seg1;
        [wi, hi] = size(final);
        hi = hi/3;
        for x = 1:wi
            for y = 1:hi
                if final(x,y,1) <= .13 && final(x,y,2) <= .13 && final(x,y,3) <= .13
                   if seg2(x,y,1) > .13 || seg2(x,y,2) > .13 || seg2(x,y,3) > .13
                       final(x,y,1) = seg2(x,y,1);
                       final(x,y,2) = seg2(x,y,2);
                       final(x,y,3) = seg2(x,y,3);
                   end
                   if seg3(x,y,1) > .13 || seg3(x,y,2) > .13 || seg3(x,y,3) > .13
                       final(x,y,1) = seg3(x,y,1);
                       final(x,y,2) = seg3(x,y,2);
                       final(x,y,3) = seg3(x,y,3);
                   end
                   if seg4(x,y,1) > .13 || seg4(x,y,2) > .13 || seg4(x,y,3) > .13
                       final(x,y,1) = seg4(x,y,1);
                       final(x,y,2) = seg4(x,y,2);
                       final(x,y,3) = seg4(x,y,3);
                   end
                   if seg5(x,y,1) > .13 || seg5(x,y,2) > .13 || seg5(x,y,3) > .13
                       final(x,y,1) = seg5(x,y,1);
                       final(x,y,2) = seg5(x,y,2);
                       final(x,y,3) = seg5(x,y,3);
                   end
                end
            end
        end
    else
        final = lin2rgb(A);
    end
        
  
    imshow(final);
    pause;
    clc; close all;
end

function [output] = getSegment(A, i, L)
%     L = imsegkmeans(ABlack,5);
    [rows, cols] = find(L~=i);
%     indices = find(L=1);
%     L(indices) = NaN;
    [w,~] = size(rows);
    for i = 1:w
        x = rows(i);
        y = cols(i);
        A(x,y, 1) = 0;
        A(x,y, 2) = 0;
        A(x,y, 3) = 0;
    end
%     B = labeloverlay(ABlack,L);
    HSV = rgb2hsv(A);
    Heq = adapthisteq(HSV(:,:,3));
    HSV_mod = HSV;
    HSV_mod(:,:,3) = Heq;
    A = hsv2rgb(HSV_mod);
    A = lin2rgb(A);
    output = A;
end
