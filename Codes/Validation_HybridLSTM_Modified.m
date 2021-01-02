%% Validation
for num = 1:800
fprintf(['Data ID = ',num2str(num),'\n']);
% Read input time-domain noisy data and clean speech data
noisy = noisySpeech(num).noisy; %log normalized stft of noisy input
x_speech = noisySpeech(num).speech; %log normalized stft of noisy input
% Define the frequency and STFT window overlap
f_new = 16000;
winLen = (16*10^-3)*f_new; % 16ms window
overlap = winLen/2; % 50% overlp
fftLen = winLen*2;
% Obtain the STFT
noisy_stft = stft(noisy,f_new,'Window',hamming(winLen,'periodic'),'OverlapLength',overlap,'FFTLength',fftLen);
clean_stft = stft(x_speech,f_new,'Window',hamming(winLen,'periodic'),'OverlapLength',overlap,'FFTLength',fftLen);
phase_all = angle(noisy_stft); % Preserve the phase
% Obtain the magnitude STFT
noisy_abs = abs(noisy_stft);
clean_abs = abs(clean_stft);
% Obtain the log power spectra (LPS)
noisy_lps = log10(((noisy_abs).^2));
clean_lps = log10(((clean_abs).^2));
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
% clean_estimated = noisy_abs;
   input = log10(clean_estimated.^2);
   numFeatures = size(input,1); tind = size(input,2); numSegments = 1;
   input = [input(:,1:numSegments - 1,:), input];
   stftSegments = zeros(numFeatures, numSegments , size(input,2) - numSegments + 1,size(input,3));
   for num1 = 1:size(input,3)
   for index = 1:size(input,2) - numSegments + 1
       stftSegments(:,:,index,num1) = (input(:,index:index + numSegments - 1,num1)); 
   end
   end
   stftSegments = squeeze(num2cell(stftSegments,[1 2]));
   modelIn = stftSegments;
   out = predict(denoiseNetFullyConnected,modelIn);
end
%% Plot function
t_idx = 1:tidx;
f_idx = 1:fbin;
figure;
subplot(2,1,1);
waterfall(t_idx,f_idx,clean_abs);colormap jet; colorbar; view(0,90);axis xy; axis tight;
subplot(2,1,2);
waterfall(t_idx,f_idx,clean_estimated);colormap jet; colorbar; view(0,90);axis xy; axis tight;
%%
X_noise = stft(noisySpeech(1).noise,f_new,'Window',hamming(winLen,'periodic'),'OverlapLength',overlap,'FFTLength',fftLen);
X_noise = abs(X_noise);
figure;
subplot(2,1,1);
waterfall(t_idx,f_idx,X_noise);colormap jet; colorbar; view(0,90);axis xy; axis tight;
subplot(2,1,2);
waterfall(t_idx,f_idx,sqrt(NPsd));colormap jet; colorbar; view(0,90);axis xy; axis tight;
