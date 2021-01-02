function [noisySpeech] = noisySpeechGeneration(speech,f_speech,noise,f_noise,rir,f_rir)
% Time domain processing
f_new = 16000;
speech = resample(speech,f_new,f_speech);
noise = resample(noise,f_new,f_noise);
rir = resample(rir,f_new,f_rir);
x1 = speech; x2 = noise; 
x1 = conv(x1,rir(:,1));
% Length equalization for Noise/Clean
l1 = length(x1);l2 = length(x2); 
L = min(l1,l2);
if l1>L
    x_speech = x1(l1/2-L/2:l1/2+L/2-1,1);
    x_noise = x2;
elseif l2>L
    x_speech = x1;
    x_noise = x2(l2/2-L/2:l2/2+L/2-1,1);
end
noisy = x_speech+x_noise;
% Add to the struture
noisySpeech = [];
noisySpeech.noisy = noisy;
noisySpeech.speech = x_speech;
noisySpeech.noise = x_noise;
% STFT domain processing
winLen = (16*10^-3)*f_new; % 16ms window
overlap = winLen/2; % 50% overlp
fftLen = winLen*2;
% Obtain the STFT
speech_stft = stft(x_speech,f_new,'Window',hamming(winLen,'periodic'),'OverlapLength',overlap,'FFTLength',fftLen);
noise_stft = stft(x_noise,f_new,'Window',hamming(winLen,'periodic'),'OverlapLength',overlap,'FFTLength',fftLen);
noisy_stft = stft(noisy,f_new,'Window',hamming(winLen,'periodic'),'OverlapLength',overlap,'FFTLength',fftLen);
% Log spectrum
speech_stft_M = log10((abs(speech_stft)).^2); noise_stft_M = log10((abs(noise_stft)).^2); noisy_stft_M = log10((abs(noisy_stft)).^2); 
% Normalization - Global
mu_speech = mean(speech_stft_M,2); std_speech = std(speech_stft_M,0,2); speech_stft_M_norm = (speech_stft_M-mu_speech)./(std_speech);
mu_noise = mean(noise_stft_M,2); std_noise = std(noise_stft_M,0,2); noise_stft_M_norm = (noise_stft_M-mu_noise)./(std_noise);
mu_noisy = mean(noisy_stft_M,2); std_noisy = std(noisy_stft_M,0,2); noisy_stft_M_norm = (noisy_stft_M-mu_noisy)./(std_noisy);
% Add to the struture
noisySpeech.noisy_stft = noisy_stft_M_norm;
noisySpeech.speech_stft = speech_stft_M_norm;
noisySpeech.noise_stft = noise_stft_M_norm;
end