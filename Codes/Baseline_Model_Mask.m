   input = noisySpeech(1).noisy_stft;in = noisySpeech(1).noisy_stft;
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
   
   output = noisySpeech(1).speech_stft;
%    output = output./in;
   target = reshape(output,1,1,size(output,1),size(output,2)*size(output,3));
   modelTarget = target;
   %% Model definition
   layers = layerForm(numFeatures,numSegments);
    miniBatchSize = 128;
    
    options = trainingOptions("adam", ...
    "MaxEpochs",30, ...
    "InitialLearnRate",1e-5,...
    "MiniBatchSize",miniBatchSize, ...
    "Shuffle","every-epoch", ...
    "Verbose",true, ...
    "ValidationFrequency",floor(size(modelIn,4)/miniBatchSize), ...
    "LearnRateSchedule","piecewise", ...
    "LearnRateDropFactor",0.9, ...
    "LearnRateDropPeriod",1);

denoiseNetFullyConnected = trainNetwork(modelIn,modelTarget,layers,options);

%% Tranfer learning
for i = 51:200
transLayer = denoiseNetFullyConnected.Layers(1:end-3);
WeightLearnRateFactor = 20; BiasLearnRateFactor = 20;
layers_new = transLayerForm(transLayer,numFeatures,WeightLearnRateFactor,BiasLearnRateFactor);
   input = noisySpeech(i).noisy_stft;in = noisySpeech(i).noisy_stft;
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
%    output = output./in;
   target = reshape(output,1,1,size(output,1),size(output,2)*size(output,3));
   modelTarget = target;
   if isnan(output(1,1))
       continue
   end
   denoiseNetFullyConnected = trainNetwork(modelIn,modelTarget,layers_new,options);
end







