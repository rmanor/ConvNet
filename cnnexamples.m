
clear; close all; clc; clear mex;

addpath('./c++/build');
addpath('./data');
load mnist_uint8;

kWorkspaceFolder = './workspase';
%load(fullfile(kWorkspaceFolder, 's.mat'), 's');
%rng(s);

kXSize = [28 28];
kTrainNum = 60000;
kTestNum = 10000;
train_x = double(reshape(train_x', kXSize(1), kXSize(2), kTrainNum))/255;
test_x = double(reshape(test_x', kXSize(1), kXSize(2), kTestNum))/255;
train_y = double(train_y)';
test_y = double(test_y)';
kOutputs = size(train_y, 1);

kTrainNum = 60000;
train_x = train_x(:, :, 1:kTrainNum);
train_y = train_y(:, 1:kTrainNum);

params.alpha = 1;
params.batchsize = 50;
params.numepochs = 1;
params.momentum = 0;  
params.adjustrate = 0;

layers = {
    struct('type', 'i', 'mapsize', kXSize) %input layer    
    struct('type', 'c', 'kernelsize', [5 5], 'outputmaps', 6, 'function', 'relu') %convolution layer
    struct('type', 's', 'scale', [2 2], 'function', 'mean') %sub sampling layer
    struct('type', 'c', 'kernelsize', [5 5], 'outputmaps', 12, 'function', 'relu') %convolution layer
    struct('type', 's', 'scale', [2 2], 'function', 'mean') %subsampling layer    
    struct('type', 'f', 'length', kOutputs) %subsampling layer    
};

%funtype = 'mexfun';
funtype = 'matlab';
weights_in = genweights(layers, funtype);
save(fullfile(kWorkspaceFolder, 'weights_in.mat'), 'weights_in');
load(fullfile(kWorkspaceFolder, 'weights_in.mat'), 'weights_in');
[weights, trainerr] = cnntrain(layers, params, train_x, train_y, funtype, weights_in);
plot(trainerr);
%save(fullfile(kWorkspaceFolder, 'weights.mat'), 'weights');
%load(fullfile(kWorkspaceFolder, 'weights.mat'), 'weights');
[pred, err]  = cnntest(layers, weights, test_x, test_y, funtype);
disp([num2str(err*100) '% error']);
