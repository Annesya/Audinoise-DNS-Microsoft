% Evaluation
load('DevSet');
name = DevSet.name;
location = DevSet.loc;
num = randi([1 height(name)],1);
noisyFile = table2array(name(num,1));
path = table2array(location(num,1));
addpath(string(path));
[x,f] = audioread(noisyFile);
f_new = 16000;
x = resample(x,f_new,f);
noisy = x; %log normalized stft of noisy input
% Define the frequency and STFT window overlap
winLen = (16*10^-3)*f_new; % 16ms window
overlap = winLen/2; % 50% overlp
fftLen = winLen*2;
% Obtain the STFT
noisy_stft = stft(noisy,f_new,'Window',hamming(winLen,'periodic'),'OverlapLength',overlap,'FFTLength',fftLen);
phase_all = angle(noisy_stft); % Preserve the phase
% Obtain the magnitude STFT
noisy_abs = abs(noisy_stft);
% Obtain the log power spectra (LPS)
noisy_lps = log10(((noisy_abs).^2));
% Initialize parameters for the classical Noise Estiation
fbin = size(noisy_abs,1); tidx = size(noisy_abs,2);
NPsd = ones([fbin,tidx]); %Initialize the noise stft
X_estm = zeros(fbin,tidx);% Initialize clean speech psd estimate
A = zeros([fbin,tidx]); % Initialize the weight A
b = 20; % Parameter Beta Vary from 15 to 30 in steps of 5
g = zeros(fbin,tidx); % Function Gamma
pastFrame = 10;
tau = 0.5; % update factor
itr = 100; % Number of iteration
%% Noise Estimate: |N(f,k)|^2 = A.|N(f,k-1)|^2 + (1-A).(T/tau)|Y(f,k)|^2 pp.425(pdf) %% Modified update rule
start = tic;
for iteration = 1:itr
for i = 2:tidx
    % Calculate the mean of the previous 10 frames of noise
    Npast = zeros(fbin,1);
    if (i-pastFrame)<=0
        Npast = (NPsd(:,i-1).^2);
    else
        for j=1:pastFrame
            Npast = Npast+(NPsd(:,i-j).^2);
        end
        Npast = Npast/pastFrame;
    end
    g(:,i) = (noisy_abs(:,i).^2)./Npast;
   % A(:,i) = 1./(1+exp(-b*(g(:,i)-1.5)));
    A(:,i) = 1-min(1,(1./(g(:,i).^2)));
    NPsd(:,i) = A(:,i).*(NPsd(:,i-1).^2)+(i/tau)*(1-A(:,i)).*(noisy_abs(:,i).^2);
end
end

%% Maximum Likelihood Based Suppression Rule pp.234(pdf) Xestimated(f,k) = Gain(f,k)Noisy(f,k)
% where Gain(f,k) = 0.5+0.5*sqrt((p-1)/p) where p is the a-posteriori SNR
snr_upBound = 10^3;
apost_snr = (noisy_abs.^2)./NPsd;
apost_snr = min(apost_snr,snr_upBound);
gain = abs((0.5+0.5*sqrt((apost_snr-1)./apost_snr)));
clean_estimated = gain.*noisy_abs;
%% LSTM model to generate cleaner speech spectra from clean_estimated
   input = log10(clean_estimated.^2); in = input;
   numFeatures = size(input,1); tind = size(input,2); numSegments = 1;
   input = [input(:,1:numSegments - 1,:), input];
   stftSegments = zeros(numFeatures, numSegments , size(input,2) - numSegments + 1,size(input,3));
   for num = 1:size(input,3)
   for index = 1:size(input,2) - numSegments + 1
       stftSegments(:,:,index,num) = (input(:,index:index + numSegments - 1,num)); 
   end
   end
%   stftSegments = reshape(stftSegments,size(stftSegments,1),size(stftSegments,2),1,size(stftSegments,3)*size(stftSegments,4));
    stftSegments = squeeze(num2cell(stftSegments,[1 2]));
    modelIn = stftSegments;
    out = predict(denoiseNetFullyConnected,modelIn);
    time = toc(start)
    noisyIN = cell2mat(modelIn);
    noisyIN = double(reshape(noisyIN,size(in,1),size(in,2)));
    %  enhancedIN = double(modelOut');
    enhancedIN = cell2mat(out);
    enhancedIN = double(reshape(enhancedIN,size(in,1),size(in,2)));
    t_idx = 1:size(noisyIN,2);
    f_idx = 1:size(noisyIN,1);
% Plot Function
figure;
subplot(3,1,1);
waterfall(t_idx,f_idx,clean_estimated);colormap jet; colorbar; view(0,90);axis xy; axis tight;
subplot(3,1,2);
waterfall(t_idx,f_idx,noisy_abs);colormap jet; colorbar; view(0,90);axis xy; axis tight;
subplot(3,1,3);
waterfall(t_idx,f_idx,(enhancedIN.*noisy_abs));colormap jet; colorbar; view(0,90);axis xy; axis tight;
%%
j = sqrt(-1);
theta = exp(j*phase_all);
speech_reconstructed = real(istft(((enhancedIN.*noisy_abs).*theta),f_new,'Window',hamming(winLen,'periodic'),'OverlapLength',overlap,'FFTLength',fftLen));
recoName = (["Reconstructed_"+noisyFile]);
audiowrite(recoName,speech_reconstructed,f_new);
%% Evaluation Measure
% addpath('D:\DNS_Development_MATLAB\compositeNew\')
% [Csig,Cbak,Covl]= composite_new(noisyFile,recoName);
