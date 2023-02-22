function [mse_i,error_i] = PFI(table,model, model_error)
%PFI performs permutation features importance.
%Input variables:   - table: table containing the features you want to
%                            permute and the output as last column.
%                   - model: model you want to use for permutation.
%                   - model_error: error of the model, considered as mse
%                                  value
%Output variables:  - mse_i: list of the mse obtained for each permuted
%                            variable
%                   - error_i: ratio between the mse coming from the i-th
%                              permuted feature and model_error

selected_table=table2array(table);
default=selected_table;
for i=1:length(table.Properties.VariableNames(1:end-1))
    permutation=selected_table(randperm(size(selected_table,1)),i);
    selected_table(:,i)=permutation;
    newtable=array2table(selected_table,'VariableNames',table.Properties.VariableNames);
    yPred(:,i)=model.predictFcn(newtable(:,1:end-1));
    mse_i(:,i)=mean((selected_table(:,end)-yPred(:,i)).^2);
    error_i(:,i)=mse_i(:,i)/model_error;
    selected_table=default;
end
end