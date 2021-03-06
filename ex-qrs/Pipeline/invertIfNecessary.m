function [ res ] = invertIfNecessary( rawEcg, fs, windowInSeconds )
%invertIfNecessary - Decides whether or not to invert the ECG signal
%   Based on the analysis of a signal segment, we decide whether or
%   not to invert the original signal.
%
%   Input:
%       rawEcg: raw ECG signal
%       fs: sampling frequency
%       windowInSeconds: Window of time on which we run the analysis
%   Outputs:
%       res: the final signal (equal to rawEcg or -rawEcg)
%
%   Example:
%       [ res ] = invertIfNecessary( ecgSig, 1000, 600 )

rawEcgSample = rawEcg(1:windowInSeconds*fs);
windowSize = 200;

% Normal Signal
[ sig, detrended ] = preprocessingNew(rawEcgSample, fs);
[ R_locs ] = kota(sig, detrended, fs);
[ peakVal, meanVal, stdVal ] = getEnsembleInfo(detrended, R_locs, windowSize);


% Inverted Signal
invEcg = - rawEcgSample;
[ sig, detrended ] = preprocessingNew(invEcg, fs);
[ R_locs ] = kota(sig, detrended, fs);
[ invPeakVal, invMeanVal, invStdVal ] = getEnsembleInfo(detrended, R_locs, windowSize);


heightNormal = abs(peakVal - meanVal) / stdVal;
heightInv = abs(invPeakVal - invMeanVal) / invStdVal;

if(heightNormal > heightInv)
    res = rawEcg;
    return;
else
    res = -rawEcg;
    return;
end

    function [ ensemble_peak, ensemble_mean, ensemble_std ] = getEnsembleInfo(detrended_sig, R_locs, windowSize)
        avg = zeros(1,(2*windowSize+1));
        left = R_locs-windowSize;
        right = R_locs+windowSize;
        totalLength = length(R_locs);
        
        parfor i=1:length(R_locs)
            if(R_locs(i) < windowSize + 1)
                continue;
            elseif(R_locs(i) > totalLength-windowSize)
                continue;
            end
            complex = detrended_sig(left(i):right(i));
            avg = avg + complex;
        end
        ensemble_peak = max(avg);
        ensemble_mean = mean(avg);
        ensemble_std = std(avg);
    end

end

