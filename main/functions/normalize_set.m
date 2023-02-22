function [yourNormDataset] = normalize_set(yourDataset)
%NORMALIZE_SET is a function able to normalize your dataset based on the
%mean value and sigma value of the train set used to create the models
%present in the "results" folder.
% Input variables:  - yourDataset: dataset obtained from the
%                                  estimated_jump_v2 function. Table
%                                  containing all the extracted features.
load('data_for_normalization.mat');
yourNormDataset = (yourDataset-muN)./sigmaN;

end