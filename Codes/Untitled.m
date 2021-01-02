%% Choose a clean data
lvl1 = ["emotional_speech\crema_d\";"mandarin_speech\SLR18_THCHS00\";"mandarin_speech\slr33_aishell\";"singing_voice/VocalSet11/Full/"];
lvl2 = ["belt";"breathy";"fast_forte";"fast_piano";"lip_trill";"slow_forte";"slow_piano";"straight";"vibrto";"vocal_fry"];
lvl3 = ["spoken";"straight";"vibrato"];
lvl4 = ["forte";"inhaled";"messa";"pp";"straight";"trill";"trillo"];
i = randi([1 4],1);
src1 = lvl1(i);

%%
[x,f] = audioread('Room005-00009.wav');
[x1,~] = boxcox(x);
figure;
subplot(2,1,1);
stft(x,f);
subplot(2,1,2);
stft(x1,f);
%%
figure;
t = 1:size(spt,2);
f = 1:size(spt,1);
waterfall(f,t,spt');