function [TrainPredictors,TestPredictors] = feature_selection(dataTrain, dataTest, lambda, alpha)
% VARIABLES_SELECTION is a function to select the most important features
% based on the training set and Lasso Regularization. 
% Input variables:   - dataTrain: table composed by the normalized features
%                                 and the output. Features appear in the N-1
%                                 columns, while the last (N) column is the
%                                 output.
%                    - dataTest: table composed by the normalized features
%                                respect to the dataTrain features and the output.
%                                Features appear in the N-1 columns, output in the N
%                                column.
%                    - lambda: value or array of values for lasso function.
%                              For the paper, the lambda values ranged in: 0.001:0.05:5
%                    - alpha: value used for lasso function. The range is
%                             between 0.1 and 1.
% Output variables:  - TrainPredictors: table containing the selected
%                                       features of dataTrain after Lasso regularization 
%                                       and the output in the last column.
%                    - TestPredictors: table containing the selected
%                                      features of dataTest after Lasso regularization
%                                      and the output in the last column.
 

% LASSO for feature selection
[coeffN, InfoModelN]= lasso(table2array(dataTrain(:,1:end-1)),table2array(dataTrain(:,end)),"Lambda",lambda,"Alpha",alpha,"CV",10,'PredictorNames', dataTrain.Properties.VariableNames(1:end-1));

% LASSO for feature selection
idxLambdaMinMSE = InfoModelN.IndexMinMSE;
minMSEModelPredictors = InfoModelN.PredictorNames(coeffN(:,idxLambdaMinMSE)~=0);

%Dataset with the selected features and the output
TrainPredictors=[dataTrain(:,minMSEModelPredictors) dataTrain(:,end)];
TestPredictors=[dataTest(:,minMSEModelPredictors) dataTest(:,end)];
end