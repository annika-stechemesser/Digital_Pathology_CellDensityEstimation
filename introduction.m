clear all; close all; clc;

imageName = './images/imageh15.jp2';

info = imfinfo(imageName);
height = info.Height;
width = info.Width;
no_of_levels = info.WaveletDecompositionLevels;

xCentre = 175000;
yCentre = 30000;
% 
% patch_Height = 512;
% patch_Width = 512;
% 
% figure;
% for level = 0 : no_of_levels
%     region = {ceil([xCentre-patch_Height/2,xCentre+patch_Height/2-1]/2^level), ...
%               ceil([yCentre-patch_Width/2,yCentre+patch_Width/2-1]/2^level)};
%     patch = imread(imageName,'ReductionLevel',level,'PixelRegion', region);
%     subplot(3,4,level+1);imshow(patch);title(sprintf('Level %d',level));
% end
% 
figure;
patch=imread(imageName,'ReductionLevel',2);
imshow(patch);