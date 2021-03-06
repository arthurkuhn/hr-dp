function [ sig, fs ] = loadFromFile( filePath, fileName )
%loadFromFile -  Loads the ECG signal from the full APEX recording file
%   Input:
%       filePath can be absolute or relative to working directory
%   Outputs:
%       sig is the raw ECG signal
%       fs is the sampling 
%
%   Example:
%       [sig, fs] = loadFromFile('a2ecg');
%
%   Process:
%   1. The signal is first formatted in a row vector.
%   2. The first minute of the signal is processed using our full 
%      pipeline. If necessary, the signal is reversed (see invertIfNeeded).
%

load(fullfile(filePath,fileName));

if(contains(fileName, '.mat'))
    fileName = fileName(1:end-4);
end
    
data = eval(fileName);

if(string(data.channels(1)) ~= 'ECG')
    print "Unexpected data format";
    return;
end
% Get the first channel (ecg)
sig = data.data(:,1);
if(~isrow(sig))
    sig = sig.';
end

fs = data.Fs;
windowInSeconds = 60;
%sig = invertIfNecessary( sig, fs, windowInSeconds);




end

