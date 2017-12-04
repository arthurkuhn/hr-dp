%% Kotal & Al %%

% V3 Instead of looking for peaks on the orig_sig, we look for them in the
% detrended signal. We keep a minimum peak height in the slips to be
% negative to keep FPs low.


close all;
clear all;

load("a5c3ecg.mat") % visible bradycardia
load("G002ecg.mat") % Heavy bias, brady -> 5 missed beats
load("A1ecg.mat") % Faint
load("a2f1ecg.mat") % Some Missed beats -> Tweak
load("G011ecg.mat")
load("G013ecg.mat")

fs = 1000;
sigs= cell(1,6);
sigs{1} = transpose(a5c3ecg);
sigs{2} = transpose(G002ecg);
sigs{3} = -transpose(A1ecg);
sigs{4} = transpose(a2f1ecg);
sigs{5} = transpose(G011ecg);
sigs{6} = -transpose(G013ecg);
errors = cell(1,6);

for i = 1:6
    disp("Sig:");
    disp(i);
    
    sig = sigs{i};
    sig = sig(1:50000);
    orig_sig = sig;
    time = 0:(1/fs):((length(sig)-1)/fs);
    
    % every second of the ECG signal was normalized by the standard deviation of the signal in that second.
    numSecs = floor(length(sig) / fs);
    sigFullSecs = sig(1:numSecs*fs);
    sigSplit = reshape(sigFullSecs, fs, numSecs);
    newsig = sigSplit;
    
    parfor j = 1:numSecs
        currSec = sigSplit(:,j);
        M = mean(currSec);
        S = std(currSec);
        normalizedSec = arrayfun(@(a) (a - M)/ S, currSec);
        newsig(:,j) = normalizedSec;
    end
    sigExtend = reshape(newsig,[],1);
    sig(1:length(sigExtend)) = sigExtend;
    
    % ECG was detrended using a 120-ms smoothing filter with a zero-phase distortion.
    sig(isnan(sig)) = 0;
    
    detrended = sig;
    
    pretraining = sig;
    
    error = zeros(20,30);
    [ intervalRef ] = kotaTweakHelper( sig, 16, 26, fs );
    numBeats = length(intervalRef);
    %sig = preprocessing(sig, fs);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    flows = zeros(1,100);
    fhighs = zeros(1,100);
    index = 1;
    for fl = 10:20
        for fh = 20:30
            flows(index) = fl;
            fhighs(index) = fh;
            index = index + 1;
        end
    end
    
    error = zeros(1,122);
    parfor index = 1:121
        fl = flows(index);
        fh = fhighs(index);
        [ interval ] = kotaTweakHelper( sig, fl, fh, fs );
        medFiltered = medfilt1(interval,5);
        diff = abs(interval - medFiltered);
        error(index) = sum(diff);
    end
    errorReshaped = reshape(error,[11,11]);
    
    errors{i} = errorReshaped./numBeats;
    save("errors.mat","errors");
end

cumulativeError = zeros(11,11);
for i = 1:6
    cumulativeError = cumulativeError + errors{i};
end

[X,Y] = meshgrid(20:30,10:20);
Z = cumulativeError;
totalMean = mean(mean(Z));
Z(Z>(totalMean)) = totalMean;
Z(Z==0) = NaN;
Z(Z==totalMean) = NaN;
figure;
surf(X, Y, Z);
ylabel("Low-Frequency Cut-Off");
xlabel("High-Frequency Cut-Off");
title("Estimated error depending on chosen frequency cutoffs");
