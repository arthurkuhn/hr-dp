% Step 1:
% Set the correct path and file names here
files = {'a5c37ce1d999','a2f1ba57e8af','a02b15a1254c'};

% Step 2:
% Update the test values here
testValues = 0.1:0.1:1;

for i = 1:length(files)
    for t = 1:length(testValues)
        options = getOptionsForTest(t, testValues);
        [ result ] = hrvDetect(char(files(i)), options );
        fileName = strcat(files(i),'-testValue-', num2str(testValues(t)),'.ibi');
        ibi = result.ibi;
        csvwrite(char(fileName),ibi);
    end
end


% Step 3:
% Simply change the value of the option you want to vary to
% testValues(testNum).
% Eg: options = [options, 'ensemble_filter_threshold', testValues(testNum)];
function options = getOptionsForTest(testNum, testValues)
    options = {};
    options = [options, 'ensemble_filter_threshold', testValues(testNum)];
    options = [options, 'mad_filter_threshold', 5];
    options = [options, 'missed_beats_tolerance_percent', 20];
    options = [options, 'median_filter_window', 3];
    options = [options, 'interpolation_method', 'linear'];
    options = [options, 'smoothing_spline_coef', 0.5]; % used if interpolation method is spline
    options = [options, 'eval_type', 'full']; % required for plotting
end