%% stereo_needle_proc.m
%
% Perform needle 3d segmentation (MATLAB wrapper for Python code written)
%
% - written by: Dimitri Lezcano
clear all;

% JF
path = 'C:\Users\jfcoe\OneDrive - Johns Hopkins\Documents\GitHub\Stereo Cameras';
addpath(genpath(path));
cd 'C:\Users\jfcoe\OneDrive - Johns Hopkins\Documents\GitHub\Stereo Cameras\Python'
%

mod = py.importlib.import_module('stereo_needle_proc');
py.importlib.reload(mod);

%% Set-up 
% options

% python set-up
% if ispc % windows file system
%     pydir = "..\Python";
% 
% else
%     pydir = "../Python";
% 
% end
pydir = cd; % JF

if count(py.sys.path, pydir) == 0
    insert(py.sys.path, int32(0), pydir);
end

None = py.None;

% directories for files
stereo_param_dir = 'C:\Users\jfcoe\OneDrive - Johns Hopkins\Documents\GitHub\Stereo Cameras\Files\Calibration\';
stereo_needle_dir = 'C:\Users\jfcoe\OneDrive - Johns Hopkins\Documents\GitHub\Stereo Cameras\Files\Validation\C:\Users\jfcoe\OneDrive - Johns Hopkins\Documents\GitHub\Stereo Cameras\Files\Validation\Sample images\';
stereo_param_cvfile = stereo_param_dir + "stereoParams_opencv-struct.mat";
stereo_param_file = stereo_param_dir + "stereoParams.mat";

% load the stereo parameters
stereo_params = load(stereo_param_file, 'stereoParams').stereoParams;
stereo_params_py = py.stereo_needle_proc.load_stereoparams_matlab(stereo_param_cvfile);

%% Stereo processing
% read in the images
num = 1;
file_base = "%s-%04d.png";

l_img_file = stereo_needle_dir + sprintf(file_base, 'left', num);
r_img_file = stereo_needle_dir + sprintf(file_base, 'right', num);

l_img = imread(l_img_file);
r_img = imread(r_img_file);

% needle_proc(l_img, r_img)

% stereo needle processing
roi_l = py.tuple({{int16(194), int16(519)}, {int16(709), int16(847)}});
roi_r = py.tuple({{int16(207), int16(690)}, {int16(742), int16(1029)}}); 
res = py.stereo_needle_proc.needleproc_stereo(py.numpy.array(l_img), py.numpy.array(r_img),...
                                              py.list(), py.list(), roi_l, roi_r);                
left_skel = logical(res{1});
right_skel = logical(res{2});
conts_l = res{3};
conts_r = res{4};

% perform contour matching
res = py.stereo_needle_proc.stereomatch_needle(conts_l{1}, conts_r{1});
cont_l_match = squeeze(double(res{1}));
cont_r_match = squeeze(double(res{2}));

%% 3-D Reconstruction
needle_3d = triangulate_stereomatch(cont_l_match, cont_r_match, stereo_params);

plot3(needle_3d(:,1), needle_3d(:,2), needle_3d(:,3));
axis equal; grid on;



