   input = noisySpeech(1).noisy_stft;in = noisySpeech(1).noisy_stft;
   numFeatures = size(input,1); tind = size(input,2); numSegments = 1;
   input = [input(:,1:numSegments - 1,:), input];
   stftSegments = zeros(numFeatures, numSegments , size(input,2) - numSegments + 1,size(input,3));
   for num = 1:size(input,3)
   for index = 1:size(input,2) - numSegments + 1
       stftSegments(:,:,index,num) = (input(:,index:index + numSegments - 1,num)); 
   end
   end
   stftSegments = squeeze(num2cell(stftSegments,[1 2]));
   modelIn = stftSegments;
   
   output = noisySpeech(1).speech_stft;
   target = reshape(output,size(output,1),1,size(output,2));
   target = squeeze(num2cell(target,[1 2]));
   modelTarget = target;
   %% Model definition
   layers = layerGeneration(numFeatures,numSegments);
    miniBatchSize = 128;
    
    options = trainingOptions("adam", ...
    "MaxEpochs",30, ...
    "InitialLearnRate",1e-3,...
    "MiniBatchSize",miniBatchSize, ...
    "Shuffle","every-epoch", ...
    "Verbose",true, ...
    "LearnRateSchedule","piecewise", ...
    "LearnRateDropFactor",0.9, ...
    "LearnRateDropPeriod",1);

denoiseNetFullyConnected = trainNetwork(modelIn,modelTarget,layers,options);

%% Tranfer learning
for i = 2:50
transLayer = denoiseNetFullyConnected.Layers(1:end-3);
WeightLearnRateFactor = 20; BiasLearnRateFactor = 20;
lgraph = layerGraph();
tempLayers = [
    transLayer
    fullyConnectedLayer(numFeatures,"Name","newFC",'WeightLearnRateFactor',WeightLearnRateFactor,'BiasLearnRateFactor',BiasLearnRateFactor)];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    reluLayer("Name","relu_2")
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);
lgraph = connectLayers(lgraph,"seqfold/miniBatchSize","sequnfold/miniBatchSize");
lgraph = connectLayers(lgraph,"newFC","relu_2");
clear tempLayers;
layers_new = lgraph;

   input = noisySpeech(i).noisy_stft;in = noisySpeech(i).noisy_stft;
   numFeatures = size(input,1); tind = size(input,2); numSegments = 1;
   input = [input(:,1:numSegments - 1,:), input];
   stftSegments = zeros(numFeatures, numSegments , size(input,2) - numSegments + 1,size(input,3));
   for num = 1:size(input,3)
   for index = 1:size(input,2) - numSegments + 1
       stftSegments(:,:,index,num) = (input(:,index:index + numSegments - 1,num)); 
   end
   end
    stftSegments = squeeze(num2cell(stftSegments,[1 2]));   modelIn = stftSegments;
   
   output = noisySpeech(i).speech_stft;
%    output = output./in;
   target = reshape(output,size(output,1),1,size(output,2));
   target = squeeze(num2cell(target,[1 2]));
   if isnan(output(1,1))
       continue
   end
   denoiseNetFullyConnected = trainNetwork(modelIn,modelTarget,layers_new,options);
end
%%
function lgraph = layerGeneration(numFeatures,numSegments)
lgraph = layerGraph();
tempLayers = [
    sequenceInputLayer([numFeatures numSegments 1],"Name","sequence")
    sequenceFoldingLayer("Name","seqfold")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    convolution2dLayer([3 3],32,"Name","conv_1","Padding","same")
    batchNormalizationLayer("Name","batchnorm_1")
    reluLayer("Name","relu_1")
    convolution2dLayer([3 3],128,"Name","conv_2","Padding","same")
    batchNormalizationLayer("Name","batchnorm_2")
    reluLayer("Name","relu_4")];

lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    sequenceUnfoldingLayer("Name","sequnfold")
    flattenLayer("Name","flatten")
    bilstmLayer(256,"Name","bilstm_1")
    bilstmLayer(256,"Name","bilstm_2")
    bilstmLayer(256,"Name","bilstm_3")
    dropoutLayer(0.5,"Name","dropout")
    fullyConnectedLayer(1024,"Name","fc_1")
    reluLayer("Name","relu_3")
    fullyConnectedLayer(numFeatures,"Name","fc_2")
    reluLayer("Name","relu_2")
    regressionLayer("Name","regressionoutput")];

    lgraph = addLayers(lgraph,tempLayers);
    lgraph = connectLayers(lgraph,"seqfold/out","conv_1");
    lgraph = connectLayers(lgraph,"seqfold/miniBatchSize","sequnfold/miniBatchSize");
    lgraph = connectLayers(lgraph,"relu_4","sequnfold/in");
    clear tempLayers;
end


function lgraph = transLayerForm(transLayer,numFeatures,WeightLearnRateFactor,BiasLearnRateFactor)
lgraph = layerGraph();
tempLayers = [
    transLayer
    fullyConnectedLayer(numFeatures,"Name","newFC",'WeightLearnRateFactor',WeightLearnRateFactor,'BiasLearnRateFactor',BiasLearnRateFactor)];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    reluLayer("Name","relu_2")
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);

clear tempLayers;
end



