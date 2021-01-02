load('DevSet');f_new = 16000;
name = DevSet.name;
location = DevSet.loc;
num = randi([1 height(name)],1);
noisyFile = table2array(name(num,1));
path = table2array(location(num,1));
addpath(string(path));
[x,f] = audioread(noisyFile);
x = resample(x,f_new,f);
winLen = (16*10^-3)*f_new; % 16ms window
overlap = winLen/2; % 50% overlp
fftLen = winLen*2;
x_stft = stft(x,f_new,'Window',hamming(winLen,'periodic'),'OverlapLength',overlap,'FFTLength',fftLen);
x_stft_M = log10((abs(x_stft)).^2);
mu_x = mean(x_stft_M,2); std_x = std(x_stft_M,0,2); x_stft_M_norm = (x_stft_M-mu_x)./(std_x);
input = x_stft_M_norm;
numFeatures = size(input,1); tind = size(input,2); numSegments = 1;
   input = [input(:,1:numSegments - 1,:), input];
   stftSegments = zeros(numFeatures, numSegments , size(input,2) - numSegments + 1,size(input,3));
   for num = 1:size(input,3)
   for index = 1:size(input,2) - numSegments + 1
       stftSegments(:,:,index,num) = (input(:,index:index + numSegments - 1,num)); 
   end
   end
   stftSegments = squeeze(num2cell(stftSegments,[1 2]));
   modelIn = stftSegments;load('LSTM_model');
   modelOut = predict(denoiseNetFullyConnected,modelIn);
   %% Reconstruction
   noisyIN = input;
   enhancedIN = double(reshape(cell2mat(modelOut),size(input,1),size(input,2)));
   phaseX = angle(x_stft);
%% Obtain the STFT
t_idx = 1:size(input,2);
f_idx = 1:size(input,1);
figure;
subplot(2,1,1);
waterfall(t_idx,f_idx,noisyIN);colormap jet; view(0,90);axis xy; axis tight;
subplot(2,1,2);
waterfall(t_idx,f_idx,enhancedIN);colormap jet; view(0,90);axis xy; axis tight;
%% Time domain reconstruction
% j = sqrt(-1);
% enhancedAudio = istft((enhancedIN.*exp(j*phaseX)),f_new,'Window',hamming(winLen,'periodic'),'OverlapLength',overlap,'FFTLength',fftLen);





