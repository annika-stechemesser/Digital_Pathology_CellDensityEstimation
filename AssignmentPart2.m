clear; close all; clc;

imageName = './images/imageh15.jp2';

fun=@NucleiDetection_H; % which method to use? (RJ+Otsu or Blueratio+Otsu)

%% Just a patch

xCentre = 175000;
yCentre = 30000;
patch_Height = 512;
patch_Width = 512;
level = 0;

region = {ceil([xCentre-patch_Height/2,xCentre+patch_Height/2-1]/2^level), ...
          ceil([yCentre-patch_Width/2,yCentre+patch_Width/2-1]/2^level)};
patch = imread(imageName,'ReductionLevel',level,'PixelRegion', region);

% RJ method 
[ DCh, M ] = Deconvolve(patch);                  
[ H, E, Bg ] = PseudoColourStains(DCh, M);

% compute the mask using the function handle we implemented above
block.data=patch;
mask=fun(block);

%%
% Plot the stain deconvolution
figure(1);
subplot(131); imshow(uint8(patch)); title('Source');
subplot(132); imshow(H); title('Haematoxylin');
subplot(133); imshow(E); title('Eosin');
%%
% plot the cell segmentation on a patch
subplot(121); imshow(blue_ratio);  title('Blue Ratio'); 
subplot(122); imshow(mask); title('Cell Segmentation');

%% The WSI

image = imread(imageName,'ReductionLevel',3);
I = blockproc(image,[64, 64],fun);

tissue_mask=load('./tissue_mask_std.mat');
tissue_mask=tissue_mask.mask_prune2;

I = I & tissue_mask;

% I(1:5000,:) = 0; 

%save('./cell_segmentation_WSI.mat','I');

figure(2);
imshow(I);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mask = NucleiDetection_blue_ratio(block_struct)

patch_float=double(block_struct.data);
R=patch_float(:,:,1);                        %extract the channel (red, green, blue)
G=patch_float(:,:,2);
B=patch_float(:,:,3);
blue_ratio =  (B./(1+R+G)) .* (256./(1+B+R+G));   % compute the blue ratio image according to the formula
thr=graythresh(blue_ratio);                       % perform otsu thresholding
mask=zeros(size(patch_float,1),size(patch_float,2));  % compute the binary mask
mask(blue_ratio>thr)=1;

end

%%

function mask = NucleiDetection_H(block_struct)

patch = block_struct.data;

% Stain separation
[ DCh, ~ ] = Deconvolve(patch);

h = DCh(:,:,1); % represent the Haematoxylin channel
thr = graythresh(h); % otsu tresholding on the Hematoxylin channel
h(h>thr) = 1.0;      % high hematoxylin -> nuclei
h(h<=thr) = 0.0;     % low hematoxylin -> no nuclei
mask = h;

end

