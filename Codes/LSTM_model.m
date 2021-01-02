   input = noisySpeech(1).noisy_stft;
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
   
   output = noisySpeech.speech_stft;
   target = reshape(output,size(output,1),1,size(output,2));
   target = squeeze(num2cell(target,[1 2]));
   modelTarget = target;
   %% Model definition
   layers = [
    sequenceInputLayer(numFeatures,"Name","sequence")
    bilstmLayer(512,"Name","bilstm_1")
    bilstmLayer(512,"Name","bilstm_2")
    bilstmLayer(512,"Name","bilstm_3")
    dropoutLayer(0.5,"Name","dropout")
    fullyConnectedLayer(2048,"Name","fc_1")
    fullyConnectedLayer(numFeatures,"Name","fc_2")
    tanhLayer("Name","tanh")
    regressionLayer("Name","regressionoutput")];

    miniBatchSize = 128;
    
    options = trainingOptions("adam", ...
    "MaxEpochs",10, ...
    "InitialLearnRate",1e-5,...
    "MiniBatchSize",miniBatchSize, ...
    "Shuffle","every-epoch", ...
    "Plots","training-progress", ...
    "Verbose",false, ...
    "LearnRateSchedule","piecewise", ...
    "LearnRateDropFactor",0.9, ...
    "LearnRateDropPeriod",1);

denoiseNetFullyConnected = trainNetwork(modelIn,modelTarget,layers,options);

%% Tranfer learning
for i = 126:130
transLayer = denoiseNetFullyConnected.Layers(1:end-3);
layers_new = [
    transLayer
    fullyConnectedLayer(numFeatures,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    tanhLayer
    regressionLayer
    ];
   input = noisySpeech(i).noisy_stft;
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
    output = noisySpeech(i).speech_stft;
    target = reshape(output,size(output,1),1,size(output,2));
    target = squeeze(num2cell(target,[1 2]));
    modelTarget = target;
   if isnan(output(1,1))
       continue
   end
   denoiseNetFullyConnected = trainNetwork(modelIn,modelTarget,layers_new,options);
end








