   input = noisySpeech(1).noisy_stft;
   numFeatures = size(input,1); tind = size(input,2); numSegments = 2;
   input = [input(:,1:numSegments - 1,:), input];
   stftSegments = zeros(numFeatures, numSegments , size(input,2) - numSegments + 1,size(input,3));
   for num = 1:size(input,3)
   for index = 1:size(input,2) - numSegments + 1
       stftSegments(:,:,index,num) = (input(:,index:index + numSegments - 1,num)); 
   end
   end
   stftSegments = reshape(stftSegments,size(stftSegments,1),size(stftSegments,2),1,size(stftSegments,3)*size(stftSegments,4));
   modelIn = stftSegments;
   
   output = noisySpeech.speech_stft;
   target = reshape(output,1,1,size(output,1),size(output,2)*size(output,3));
   modelTarget = target;
   %% Model definition
   layers = [
    imageInputLayer([numFeatures,numSegments])
    fullyConnectedLayer(2048)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(2048)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numFeatures)
    regressionLayer
    ];
    miniBatchSize = 128;
    
    options = trainingOptions("adam", ...
    "MaxEpochs",10, ...
    "InitialLearnRate",1e-5,...
    "MiniBatchSize",miniBatchSize, ...
    "Shuffle","every-epoch", ...
    "Plots","training-progress", ...
    "Verbose",false, ...
    "ValidationFrequency",floor(size(modelIn,4)/miniBatchSize), ...
    "LearnRateSchedule","piecewise", ...
    "LearnRateDropFactor",0.9, ...
    "LearnRateDropPeriod",1);

denoiseNetFullyConnected = trainNetwork(modelIn,modelTarget,layers,options);

%% Tranfer learning
for i = 295:300
transLayer = denoiseNetFullyConnected.Layers(1:end-2);
layers_new = [
    transLayer
    fullyConnectedLayer(numFeatures,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    regressionLayer
    ];
   input = noisySpeech(i).noisy_stft;
   numFeatures = size(input,1); tind = size(input,2); numSegments = 2;
   input = [input(:,1:numSegments - 1,:), input];
   stftSegments = zeros(numFeatures, numSegments , size(input,2) - numSegments + 1,size(input,3));
   for num = 1:size(input,3)
   for index = 1:size(input,2) - numSegments + 1
       stftSegments(:,:,index,num) = (input(:,index:index + numSegments - 1,num)); 
   end
   end
   stftSegments = reshape(stftSegments,size(stftSegments,1),size(stftSegments,2),1,size(stftSegments,3)*size(stftSegments,4));
   modelIn = stftSegments;
   
   output = noisySpeech(i).speech_stft;
   target = reshape(output,1,1,size(output,1),size(output,2)*size(output,3));
   modelTarget = target;

   denoiseNetFullyConnected = trainNetwork(modelIn,modelTarget,layers_new,options);
end







