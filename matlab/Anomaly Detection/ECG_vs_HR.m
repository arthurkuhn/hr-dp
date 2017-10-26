%% Noise Anomaly Detection %%

close all;
clear all;
load("G002ecg.mat")
load("A1ecg.mat")
load("a2f1ecg.mat")
load("a5c3ecg.mat")

fs = 1000;
orig_sig = G002ecg;
orig_sig = orig_sig.*1000; %to see variations

filt = BP(); % Band pass from 16 to 26 Hz
filt_sig = filter(filt, orig_sig); % new signal

time = 0:(1/fs):((length(filt_sig)-1)/fs); %time in seconds
window = 1*fs; % # of secs
%threshold = 0.09;

[array_ecg,noisy_sig_ecg, s] = std_dev(filt_sig, 0.09, window);
[qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(orig_sig,1000,0);
period = diff(qrs_i_raw);
period(length(period)+1) = 0;
period = period./fs; %period in seconds
[array_pt,noisy_sig_pt,spt] = std_dev(period, 0.04, 8);
[qrs_amp_raw,qrs_i_raw]=kotaFunction2(orig_sig,1000,0);


% array_pt = qrs_i_raw(array_pt);

% full = zeros(1, length(filt_sig)); %initialize
% full(qrs_i_raw) = period;
% for i = 2:length(full)
%     if full(i) == 0
%         full(i) = full(i-1);
%     end
% end

%BPM = 1*60./period;

%in secs
array_ecg = array_ecg./fs;
% qrs_i_raw = qrs_i_raw./fs;
% 
% n_sig_pt = [];
% for i = 1:length(array_pt)
%     n_sig_pt(i) = full(array_pt(i));
% end

%array_pt = array_pt/fs;

figure;
ax1 = subplot(3,1,1);
plot(time, orig_sig);
title('A1ecg (original signal)');
xlabel('Time (s)');

ax2 = subplot(3,1,2);
plot(time, filt_sig);
title('filtered signal (BP 16-26Hz)');
xlabel('Time (s)');

ax3 = subplot(3,1,3);
plot(time, filt_sig);
hold on
scatter(array_ecg,noisy_sig_ecg,1,'r');
title('noise detection (std dev > 0.145)');
xlabel('Time (s)');

linkaxes([ax1, ax2, ax3], 'x')

figure;
subplot(2,1,1);
plot(1:length(period), period);
%title('HR');
ylabel('RR interval (s)');

subplot(2,1,2);
plot(1:length(period), period);
hold on
%plot(array_pt, noisy_sig_pt, 'rv');
scatter(array_pt, noisy_sig_pt,15, 'r');
%title('noisy HR');
ylabel('RR interval (s)');

figure
subplot(2,1,1);
plot(1:length(period), period);
title('RR period');
subplot(2,1,2);
plot(1:length(period), spt)
title('standard deviation of HR');
