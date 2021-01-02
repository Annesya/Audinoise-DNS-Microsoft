classdef dotMult < nnet.layer.Layer

    properties
        % (Optional) Layer properties.

        % Layer properties go here.
    end

    properties (Learnable)
        % (Optional) Layer learnable parameters.

        % Layer learnable parameters go here.
    end
    
    methods
        function layer = dotMult(name)
            % (Optional) Create a myLayer.
            % This function must have the same name as the class.
            layer.NumInputs = 2;
            layer.NumOutputs = 1;
            layer.Name = name;
            % Layer constructor function goes here.
        end
        
        function [Z] = predict(~, X1,X2)
            % Forward input data through the layer at prediction time and
            X21 = reshape(X2,size(X2,2),size(X2,3),size(X2,1),size(X2,4));
            Z = X1.*X21(end,:,:,:);
        end
        function [Z] = forward(~, X1,X2)
            X21 = reshape(X2,size(X2,2),size(X2,3),size(X2,1),size(X2,4));
            Z = X1.*X21(end,:,:,:);
        end
    end          
end