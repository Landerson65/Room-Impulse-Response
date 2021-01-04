%ECE 4271: Applications of DSP
%Project 2: Room Impulse Response
%Lillian Anderson

clear;clc
%Part 1: Online Data

%Readin in Original RIR
[y00_00, Fs] = audioread('00x00y.wav'); %read in RIR file
Fs_resampled = 32000;
y00_00 = resample((y00_00.'), Fs_resampled,Fs); %downsample from 96kHz to 32kHz

y40_15 = audioread('40x15y.wav');
y40_15 = resample((y40_15.'), Fs_resampled,Fs);

%excitation signals
N = 1300000; % length of x. Must be 10-20 times length(RIR)
humanNoise = audioread('teaKettle_whistle.wav')';
humanNoise = humanNoise(1, 1:N);
humanNoise = 0.41*humanNoise./max(humanNoise);%noise level is 10 percent of received signal
myWhiteNoise = randn(1, N);

%received excitation signal
receivedSignal_white_00_00 = conv(y00_00, myWhiteNoise);
receivedSignal_white_00_00 = receivedSignal_white_00_00(1, 1:N);
receivedSignal_human_40_15 = conv(y40_15, humanNoise);
receivedSignal_human_40_15 = receivedSignal_human_40_15(1, 1:N);
receivedSignal_sum = receivedSignal_white_00_00 + receivedSignal_human_40_15;

%verify noise level is 10 percent of received signal
mySNR = 20*log10(rms(receivedSignal_white_00_00)/(rms(receivedSignal_human_40_15))); %calculate mean power still!!!!
desiredSNR = 20*log10(1/0.1);

%nLMS filter
M = 64000;%filter length... same length as RIR
B = 0.5;    %let B = 0.5-1

[w, e] = mynLMS(M, N, B, myWhiteNoise, receivedSignal_sum);

%evaluation (in percentage)
w = w';
MSE_normalized = 100*(norm(y00_00 - w)/norm(y00_00)); 
MSE_first400 = 100*(norm(y00_00(1, 1:400) - w(1, 1:400))/norm(y00_00(1, 1:400)));
MSE_last_third = 100*(norm(y00_00(1, 42666:64000) - w(1, 42666:64000))/norm(y00_00(1, 42666:64000)));

% %plot error
% myIndex = 1:100:N;
% myError = e(1:100:N, 1);
% plot(myIndex, myError)

%Plot RIR
figure
subplot(1, 2, 1)
pt1_x = 1:100:64000;
pt1_y = y00_00(1:100:64000);
plot(pt1_x, pt1_y)
title('Original RIR')
xlabel('Sample')
ylabel('y')
pt1_w = w(1:100:64000);
subplot(1,2,2)
plot(pt1_x, pt1_w)
title('Learned RIR')
xlabel('Sample')
ylabel('w')

%% Part 2: Real Data
%x is excitation signal
%y is recorded response

%read in structures
carpetStructQ = load('./RoomMeasurements/carpetroom_quiet.mat');
carpetStruct0 = load('./RoomMeasurements/carpetroom_music0.mat');
carpetStruct1 = load('./RoomMeasurements/carpetroom_music1.mat');
carpetStruct2 = load('./RoomMeasurements/carpetroom_music2.mat');
carpetStruct3 = load('./RoomMeasurements/carpetroom_music3.mat');
tileStructQ = load('./RoomMeasurements/tileroom_quiet.mat');
tileStruct0 = load('./RoomMeasurements/tileroom_music0.mat');
tileStruct1 = load('./RoomMeasurements/tileroom_music1.mat');
tileStruct2 = load('./RoomMeasurements/tileroom_music2.mat');
woodStructQ = load('./RoomMeasurements/woodfloor_medium_quiet.mat'); 
woodStruct0 = load('./RoomMeasurements/woodfloor_medium_music0.mat');
woodStruct1 = load('./RoomMeasurements/woodfloor_medium_music1.mat');
woodStruct2 = load('./RoomMeasurements/woodfloor_medium_music2.mat');
woodStruct3 = load('./RoomMeasurements/woodfloor_medium_music3.mat');

%remove delay
carpetDelay = 17000;
carpetLength = 320000;
carpetQX = carpetStructQ.x(1:(carpetLength - carpetDelay))';
carpetQY = carpetStructQ.y((carpetDelay +1):carpetLength);
carpet0X = carpetStruct0.x(1:(carpetLength - carpetDelay))';
carpet0Y = carpetStruct0.y((carpetDelay +1):carpetLength);
carpet1X = carpetStruct1.x(1:(carpetLength - carpetDelay))';
carpet1Y = carpetStruct1.y((carpetDelay +1):carpetLength);
carpet2X = carpetStruct2.x(1:(carpetLength - carpetDelay))';
carpet2Y = carpetStruct2.y((carpetDelay +1):carpetLength);
carpet3X = carpetStruct3.x(1:(carpetLength - carpetDelay))';
carpet3Y = carpetStruct3.y((carpetDelay +1):carpetLength);

tileDelay = 17000;
tileLength = 320000;
tileQX = tileStructQ.x(1:(tileLength - tileDelay))';
tileQY = tileStructQ.y((tileDelay +1):tileLength);
tile0X = tileStruct0.x(1:(tileLength - tileDelay))';
tile0Y = tileStruct0.y((tileDelay +1):tileLength);
tile1X = tileStruct1.x(1:(tileLength - tileDelay))';
tile1Y = tileStruct1.y((tileDelay +1):tileLength);
tile2X = tileStruct2.x(1:(tileLength - tileDelay))';
tile2Y = tileStruct2.y((tileDelay +1):tileLength);

woodDelay = 17000;
woodLength = 320000;
woodQX = woodStructQ.x(1:(woodLength - woodDelay))';
woodQY = woodStructQ.y((woodDelay +1):woodLength);
wood0X = woodStruct0.x(1:(woodLength - woodDelay))';
wood0Y = woodStruct0.y((woodDelay +1):woodLength);
wood1X = woodStruct1.x(1:(woodLength - woodDelay))';
wood1Y = woodStruct1.y((woodDelay +1):woodLength);
wood2X = woodStruct2.x(1:(woodLength - woodDelay))';
wood2Y = woodStruct2.y((woodDelay +1):woodLength);
wood3X = woodStruct3.x(1:(woodLength - woodDelay))';
wood3Y = woodStruct3.y((woodDelay +1):woodLength);


% %used to find where the delay starts
% % Do NOT remove ANY of the actual signal. just the delay
% myX = 1:1000:length(quietStruct.y);
% myY = quietStruct.y(1:1000:length(quietStruct.y));
% plot(myX, myY)

%Apply Adaptive Filter and plot learned RIRs
M_pt2 = 10000; %filter length. M<N
B_pt2 = 0.5; %0.5-1

%carpet room calculations
N_carpet = (carpetLength - carpetDelay);
[ w_carpetQ] = mynLMS(M_pt2, N_carpet, B_pt2, carpetQX, carpetQY);
[ w_carpet0] = mynLMS(M_pt2, N_carpet, B_pt2, carpet0X, carpet0Y);
[ w_carpet1] = mynLMS(M_pt2, N_carpet, B_pt2, carpet1X, carpet1Y);
[ w_carpet2] = mynLMS(M_pt2, N_carpet, B_pt2, carpet2X, carpet2Y);
[ w_carpet3] = mynLMS(M_pt2, N_carpet, B_pt2, carpet3X, carpet3Y);
minix = 1:length(w_carpetQ);
figure
subplot(2, 3, 1)
plot(minix, w_carpetQ)
title('Quiet');
xlabel('Samples')
ylabel('w')
subplot(2, 3, 2)
plot(minix, w_carpet0)
title('Music 0');
xlabel('Samples')
ylabel('w')
subplot(2, 3, 3)
plot(minix, w_carpet1)
title('Music 1')
xlabel('Samples')
ylabel('w')
subplot(2, 3, 4)
plot(minix, w_carpet2)
title('Music 2')
xlabel('Samples')
ylabel('w')
subplot(2, 3, 5)
plot(minix, w_carpet3)
title('Music 3')
xlabel('Samples')
ylabel('w')


%tile room calculations and plots
N_tile = (tileLength - tileDelay);
[w_tileQ] = mynLMS(M_pt2, N_tile, B_pt2, tileQX, tileQY);
[w_tile0] = mynLMS(M_pt2, N_tile, B_pt2, tile0X, tile0Y);
[w_tile1] = mynLMS(M_pt2, N_tile, B_pt2, tile1X, tile1Y);
[w_tile2] = mynLMS(M_pt2, N_tile, B_pt2, tile2X, tile2Y);
minix = 1:length(w_tileQ);
figure
subplot(2, 2, 1)
plot(minix, w_tileQ)
title('Quiet')
xlabel('Samples')
ylabel('w')
subplot(2, 2, 2)
plot(minix, w_tile0)
title('Music 0')
xlabel('Samples')
ylabel('w')
subplot(2, 2, 3)
plot(minix, w_tile1)
title('Music 1')
xlabel('Samples')
ylabel('w')
subplot(2, 2, 4)
plot(minix, w_tile2)
title('Music 2')
xlabel('Samples')
ylabel('w')

%wood room calculations and plots
N_wood = (woodLength - woodDelay);
[w_woodQ] = mynLMS(M_pt2, N_wood, B_pt2, woodQX, woodQY);
[w_wood0] = mynLMS(M_pt2, N_wood, B_pt2, wood0X, wood0Y);
[w_wood1] = mynLMS(M_pt2, N_wood, B_pt2, wood1X, wood1Y);
[w_wood2] = mynLMS(M_pt2, N_wood, B_pt2, wood2X, wood2Y);
[w_wood3] = mynLMS(M_pt2, N_wood, B_pt2, wood3X, wood3Y);
minix = 1:length(w_woodQ);
figure;
subplot(2, 3, 1)
plot(minix, w_woodQ)
title('Quiet')
xlabel('Samples')
ylabel('w')
subplot(2, 3, 2)
plot(minix, w_wood0)
title('Music 0')
xlabel('Samples')
ylabel('w')
subplot(2, 3, 3)
plot(minix, w_wood1)
title('Music 1')
xlabel('Samples')
ylabel('w')
subplot(2, 3, 4)
plot(minix, w_wood2)
title('Music 2')
xlabel('Samples')
ylabel('w')
subplot(2, 3, 5)
plot(minix, w_wood3)
title('Music 3')
xlabel('Samples')
ylabel('w')

%save RIRs in a structure
learnedRIR.carpet0 = w_carpet0;
learnedRIR.carpet1 = w_carpet1;
learnedRIR.carpet2 = w_carpet2;
learnedRIR.carpet3 = w_carpet3;
learnedRIR.carpetQ = w_carpetQ;
learnedRIR.tile0 = w_tile0;
learnedRIR.tile1 = w_tile1;
learnedRIR.tile2 = w_tile2;
learnedRIR.tileQ = w_tileQ;
learnedRIR.wood0 = w_wood0;
learnedRIR.wood1 = w_wood1;
learnedRIR.wood2 = w_wood2;
learnedRIR.wood3 = w_wood3;
learnedRIR.woodQ = w_woodQ;

save('learnedRIR_pt2', 'learnedRIR');


