%% align a floating image on top of a reference image
%  need to give rotation angle and translation matrix
% This script requires to add the ISS_analysis repository from
% www.github.com/Moldia to the path in order to use their functions
%  last update, 2015-2-8,21 Sergio Marco Salas

%At this point of the analysis, we have decoded ISS spots and we have done an extra imaging
%cycle where we have stained the samples using the H3-K27M antibody (IF).
%We will use this script to align the DAPI staining from both experiments
%and tranform the IF images to match our decoding rounds.

%% input
ref_image = 'U:\DIPG_AAA076530001\DIPG_Sample1\Stitched2DTiles_MIST_Ref1\Base_1_c1.tif'; % give sample snapshot image (blue DAPI)
input_image_prefix = 'G:\DIPG_IF\DIPG_IF_AAA076530001_B\DIPG_IF_AAA076530001_B_c';
flo_image = [input_image_prefix '1_ORG.tif']; % give sample snapshot image (blue DAPI)
output_image_prefix = 'G:\DIPG_IF';

%% original
ref = imread(ref_image);
size_ref = size(ref);
flo = imread(flo_image);
ref_resized = imresize(ref, .2);
clear ref;
flo_resized = imresize(flo, .2);
Ifuse = imfuse(flo_resized, ref_resized);
% green: floating
% purple: reference

%% rotation
angle = 0.65; % positive: counter clockwise -0.4
[flo_rotate, Ifuse_rotate] = rotateimage(flo_resized, angle, ref_resized);

%% translation 
% We will modify this coordinates, as well as the rotation angle to
% manually align both images. 
yup = 48;   % positive: move the floating image up, negative: down 52
xleft = -22;   % positive: move the floating image left, negative: right 107
Ifuse_translate = translateimage(yup, xleft, flo_rotate*30, ref_resized*1);
figure;imshow(Ifuse_translate*2);


% Once we have a perfect translation and rotation, we will apply it to all
% the channels imaged in the IF round and save them. The images will then
% be ready for segmentation. 
tic
for c = 1:2
    flo = imread([input_image_prefix num2str(c) '_ORG.tif']);
    %mkdir([output_image_prefix num2str(c)]);
    transformimage(flo,angle,yup,xleft,5,...
        [output_image_prefix 'IF_DIPG_IF_AAA076530001_B_ALI_' num2str(c) '.tif'],size_ref);
end
toc