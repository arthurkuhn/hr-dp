function [ result ] = hrvDetect(fileName, varargin )
%hrvDetect - Analyses an ECG signal to extract heart-rate information
% This function orchestrates the entire program execution.
%
% Process:
%   1. Loading
%   2. Pre-Processing
%   3. Kota detection
%   4. Post-Processing
%   5. Smoothing
%
%
% Inputs:
%    params struct
%
% Outputs:
%    result struct
%
% Please see exact struct definition in sample function or documentation.

if nargin ==1
   "Using default parameters : No filter, direct interpolation"
end

options = {
    {'n_sample_start' 1 'Sample number where analysis will start (default: 1)'} ...
    {'n_sample_end' NaN 'Sample number where the analysis will end (default: end)'} ...
    {'ensemble_filter_threshold' NaN 'Ensemble Filter Correlation Threshold'} ...
    {'ensemble_filter_window' 200 'Ensemble filter window in samples'} ... %TODO: Make in ms
    {'mad_filter_threshold' NaN 'Mad Filter Threshold'} ...
    {'missed_beats_tolerance_percent' NaN 'Tolerance in beat-to-beat variation'} ...
    {'median_filter_window' NaN 'Median Filter Window Size'} ...
    {'interpolation_method' 'spline' 'Interpolation Method (spline or direct)'} ...
    {'smoothing_spline_coef' 0.5 'Smoothing Spline Coefficient (invalid when direct is specified as the interpolation_method'} ...
    {'directory' '' 'Directory where the file is located (if not on path)'}
    };
if nargin == 0
    arg_help('fig_mod',options);
    return
end
arg_parse (options, varargin);

% Load Sig
[ sig, fs ] = loadFromFile( directory, fileName );

if(isnan(n_sample_end))
   sig = sig(n_sample_start:end);
else
   sig = sig(n_sample_start:n_sample_end);
end

% Pre-processing
[ sig, detrended ] = preprocessingNew(sig, fs);

% Kota
[ R_locs ] = kota(sig, detrended, fs);

if(~isnan(ensemble_filter_threshold))
    errors = ensembleNonCorrelatedDetector( detrended, R_locs, ensemble_filter_threshold, ensemble_filter_window );
else
    errors = zeros(1,length(R_locs));
end


% Make the interval array with the valid beats
interval = diff(R_locs);
noisy = zeros(1,length(interval));
for i = 1:length(R_locs)-1
    % Since here interval(i) = R_locs(i+1)-R_locs(i)
    if(errors(i) == 1)
        if(i > 1)
            noisy(i-1) = 1;
            noisy(i) = 1;
        else
            noisy(i) = 1;
        end
    end
end

% Check for missed beat signs

if(~isnan(missed_beats_tolerance_percent))
    missedBeatErrors = missedBeatDetector( interval, missed_beats_tolerance_percent );
else 
    missedBeatErrors = zeros(1, length(interval));
end

% Use the non-destructive median filter:
if(~isnan(mad_filter_threshold))
    outliers = medFilter( interval, mad_filter_threshold );
else 
    outliers = zeros(1, length(interval));
end

totalNoisyIntervals = noisy | missedBeatErrors | outliers;

noisyIntervals = logical(totalNoisyIntervals);

intervalLocs = R_locs(1:end-1);
time = 0:(1/fs):((length(detrended)-1)/fs);
switch (interpolation_method)
      case 'spline'
          [f,gof,~] = fit(transpose(time(intervalLocs(~noisyIntervals))),transpose(interval(~noisyIntervals)),'smoothingspline','SmoothingParam',smoothing_spline_coef);
          smoothSignal = f(time(intervalLocs(~noisyIntervals)));
          r_squarred = gof.rsquare;
      case 'direct'
          smoothSignal = interval(~noisyIntervals);
          r_squarred = 0;
end
if(~isnan(median_filter_window))
    smoothSignal = medfilt1(smoothSignal,median_filter_window);
end

tachogram = smoothSignal;
% Make in BPM
smoothSignal = 60*fs./(smoothSignal);
percentNoisy = sum(noisyIntervals) / ( length(R_locs)-1 ) * 100;
switch (interpolation_method)
    case 'spline'
        [f,~,~] = fit(transpose(time(intervalLocs(~noisyIntervals))),smoothSignal,'smoothingspline','SmoothingParam',smoothing_spline_coef);
        heartRate = f(time);
    case 'direct'
        heartRate = interp1(transpose(time(intervalLocs(~noisyIntervals))),smoothSignal,time,'linear');
        r_squarred = 0;
end

result = {};
result.fs = fs;
result.tachogram = tachogram;
result.R_locs = intervalLocs(~noisyIntervals);
result.heartRate = heartRate;
result.noisyIntervals = intervalLocs(noisyIntervals);
result.interpolatedFlag = [0];
result.evaluation = struct('totalNumBeats', length(R_locs),'percentInvalid', percentNoisy,'splineRSquare', r_squarred, 'numRemovedEnsemble', sum(noisy), 'numRemovedMAD', sum(outliers), 'missedBeatsNum', missedBeatErrors);

end