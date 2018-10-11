clear;

% This section takes a long time to run. 

cells=load('cell_segmentation_WSI.mat'); %load the mask with the tissue
regions (std filt)

cells=cells.I;

fun = @numberconn; % which method to use? build function handle

B = blockproc(cells, [5, 5], fun, 'BorderSize', [30, 30]); %compute local
cell density

B = B/max(max(B));  %normalize
save('./B.mat','B');  %save

%%

% B=load('./B.mat');   %load results
% B=B.B;
Gauss= imgaussfilt(B);  %apply Gaussian filtering
wsi=imread('./images/imageh15.jp2','ReductionLevel',3);  %load wsi at level 3

%%
%overlay original slide at level 3 and local cell density (heatmap)

figure; imshow(wsi); title('Cell density heat map'); hold on;
hImg = imagesc(Gauss); colormap jet; set(hImg, 'AlphaData', 0.25);
colorbar;

%%

function d=numberconn(block_struct) %compute local cell density

CC = bwconncomp(block_struct.data);   %compute number of connected components in the block
d = CC.NumObjects * ones(size(block_struct.data));

end

