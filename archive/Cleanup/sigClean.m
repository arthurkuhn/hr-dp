function [ cleanInterval, removedIndexes ] = sigClean( interval, fs )
%SIGCLEAN Cleans the signal as much as possible
%   Returns the cleaned up heart rate as well as the dirty indexes


allowedDeviation = 0.10; % 10%
index = 0;
for i = 2:(length(interval)-2)
    % double of 2 adjacent hardbeats: missed peak
    length(interval)
    sumPrevNext = interval(i-1) + interval(i+1);
    deviation = allowedDeviation * sumPrevNext;
    if(interval(i) > (sumPrevNext - deviation) && interval(i) < (sumPrevNext + deviation))
        interval(i) = sumPrevNext;
        index = index + 1;
        removedIndexes(index) = i;
    end
end

tooLow = interval < fs*2;
for i = 1:length(tooLow)
    index = index + 1;
    removedIndexes(index) = tooLow(i);
end

tooHigh = interval > 1/4*fs;
for i = 1:length(tooHigh)
    index = index + 1;
    removedIndexes(index) = tooHigh(i);
end

% % Remove extreme values:
% interval = interval(interval < fs*2); %BPM < 30
% interval = interval(interval > 1/4*fs); %BPM > 240

cleanInterval = interval;
cleanInterval(removedIndexes) = [];

end
