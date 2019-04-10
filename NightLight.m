%Computer Vision Final Project - 'Night Light'
%Nick Orr, orrn@wit.edu,
%Brendan Sileo, sileob@wit.edu

clc; close all; clear all;
simpleGUI;

function simpleGUI
    hFig = figure('Visible','off', 'Menu','none', 'Name','Night Light', 'Resize','off', 'Position',[100 100 1050 600]);
    movegui(hFig,'center')          %# Move the GUI to the center of the screen

    hBtnGrp = uibuttongroup('Position',[0 0 0.3 1], 'Units','Normalized');
    uicontrol('Style','Radio', 'Parent',hBtnGrp, 'HandleVisibility','off', 'Position',[15 150 70 30], 'String','Load Image', 'Tag','li')
    uicontrol('Style','Radio', 'Parent',hBtnGrp, 'HandleVisibility','off', 'Position',[15 120 70 30], 'String','Quit', 'Tag','q')

    uicontrol('Style','pushbutton', 'String','Choose', 'Position',[15  90 70 30], 'Callback',{@button_callback})

    set(hFig, 'Visible','on')        %# Make the GUI visible

    %# callback function
    function button_callback(src,ev)
        switch get(get(hBtnGrp,'SelectedObject'),'Tag')
            case 'li', processImage();
            case 'q',  return;
        end
    end
end

function processImage
    name = uigetfile('*');
    A = imread(name);
    ABlack = rgb2gray(A);
    
    [wi, hi] = size(ABlack);
    
    A = rgb2hsv(A);
    hueImage = A(:, :, 1);
    saturationImage = A(:, :, 2);
    valueImage = A(:, :, 3);
    foundNonEdge = true;
    while foundNonEdge == true
        for x = 1:wi
            for y = 1:hi
                foundNonEdge = false;
                if hueImage(x,y) == 0
                    try
                        adjValues = [];
                        if hueImage(x+1,y) ~= 0
                            adjValues = [adjValues, hueImage(x+1,y)];
                        end
                        if hueImage(x-1,y) ~= 0
                            adjValues = [adjValues, hueImage(x-1,y)];
                        end
                        if hueImage(x-1,y-1) ~= 0
                            adjValues = [adjValues, hueImage(x-1,y-1)];
                        end
                        if hueImage(x,y-1) ~= 0
                            adjValues = [adjValues, hueImage(x,y-1)];
                        end
                        if hueImage(x-1,y+1) ~= 0
                            adjValues = [adjValues, hueImage(x-1,y+1)];
                        end
                        if hueImage(x,y+1) ~= 0
                            adjValues = [adjValues, hueImage(x,y+1)];
                        end
                        if hueImage(x+1,y+1) ~= 0
                            adjValues = [adjValues, hueImage(x+1,y+1)];
                        end
                      
                        newVal = mean(adjValues);
                        if size(adjValues) ~= 0
                            hueImage(x,y) = newVal;
                        else
                            foundNonEdge = true;
                        end
                    catch 
                    end
                end
            end
        end
    end
    foundNonEdge = true;
    while foundNonEdge == true
        for x = 1:wi
            for y = 1:hi
                foundNonEdge = false;
                if saturationImage(x,y) == 0
                    try
                        adjValues = [];
                        if saturationImage(x+1,y) ~= 0
                            adjValues = [adjValues, saturationImage(x+1,y)];
                        end
                        if saturationImage(x-1,y) ~= 0
                            adjValues = [adjValues, saturationImage(x-1,y)];
                        end
                        if saturationImage(x-1,y-1) ~= 0
                            adjValues = [adjValues, saturationImage(x-1,y-1)];
                        end
                        if saturationImage(x,y-1) ~= 0
                            adjValues = [adjValues, saturationImage(x,y-1)];
                        end
                        if saturationImage(x-1,y+1) ~= 0
                            adjValues = [adjValues, saturationImage(x-1,y+1)];
                        end
                        if saturationImage(x,y+1) ~= 0
                            adjValues = [adjValues, saturationImage(x,y+1)];
                        end
                        if saturationImage(x+1,y+1) ~= 0
                            adjValues = [adjValues, saturationImage(x+1,y+1)];
                        end
                      
                        newVal = mean(adjValues);
                        if size(adjValues) ~= 0
                            saturationImage(x,y) = newVal;
                        else
                            foundNonEdge = true;
                        end
                    catch 
                    end
                end
            end
        end
    end
    for x = 1:wi
        for y = 1:hi
           pixel = valueImage(x,y);
           if pixel < .09
               dist = 1-pixel;
               pixel = pixel + (dist/4);
               valueImage(x,y) = pixel;
           end
           
        end
    end
    A = cat(3, hueImage, saturationImage, valueImage);
    A = hsv2rgb(A);
    imshow(A);


    pause;
    clc; close all; clear all;
end

% -Convert image to black and white
% -Edge detection to pull different layers of scene
% -Calculate average intensity of layers
% -Compare intensities of each layer
% -Use gamma + white balance correction to brighten each layer of color image
% -Recombine layers
