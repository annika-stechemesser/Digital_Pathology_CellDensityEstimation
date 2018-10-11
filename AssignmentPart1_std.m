clear; close all; clc;

imageName = './images/imageh15.jp2'; %load the image
level = 3; 

im = imread(imageName,'ReductionLevel',level);%read the image at reduction level 3

f=@stdfilt; %build a function handle, use local standard deviation filter

[mask, features] = Segmentation(im,f); %run the function Segmentation (see below)

% pruning out regions that are smaller than a threshold
mask_prune = imopen(mask, strel('disk',25));         %morphologically open the image, structuring element: disc with radius 25
mask_prune2 = imclose(mask_prune, strel('disk',25)); %morphologically close the image, structuring element: disc with radius 25


%%
%check if the pruning works properly

figure;
subplot(1,3,1);imshow(mask); 
subplot(1,3,2); imshow(mask_prune);
subplot(1,3,3); imshow(mask_prune2);

%%

B = bwboundaries(mask_prune2/255,'noholes');
disp('Done stdfilt')
save('./tissue_mask_std.mat','mask_prune2'); %save the binary mask for tissue segments

% Visualiztion of each step of segmentation process
figure(1); clf;
subplot(1,4,1);imshow(im);title('WSI at Level 3');
subplot(1,4,2);imagesc(features);colormap jet;truesize;title('Local standard deviation');
subplot(1,4,3);imshow(mask_prune2); title('Segmentation Mask stdfilt');
subplot(1,4,4);imshow(im); title('Segmentation Boundary Overlay stdfilt');
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mask, features] = Segmentation(im,f) %takes the image and a function handle

    % Convert image into grayscale image
    grayImage = rgb2gray(im);
    
    neighbourhoood = ones(15,15); % specify local neighbourhood. Can't be too big or too small.
    features = f(grayImage,neighbourhoood);
    % f is a function handle to the filter (entrpoyfilter), compute the local
    %entropy of the grayscale image
    
    features = features/max(max(features)); %normalize
    threshold = graythresh(features);   %use otsu thresholding to set the threshold
 
    
    % Generate mask using threshold values
    mask = features;
    mask(mask>threshold) = 255;  %% if local entropy greater than threshold, put white (tissue)
    mask(mask<=threshold) = 0;   % if local entropy smaller than threshold, put black (no tissue)
    
end