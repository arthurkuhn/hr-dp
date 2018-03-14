function Hd = LP-2ORD-LeastSquares-FPass16 - Fstop25
%LP-2ORD-LEASTSQUARES-FPASS16 - FSTOP25 Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.2 and the Signal Processing Toolbox 7.4.
% Generated on: 08-Oct-2017 12:38:23

% FIR least-squares Lowpass filter designed using the FIRLS function.

% All frequency values are in Hz.
Fs = 1000;  % Sampling Frequency

N     = 2;   % Order
Fpass = 16;  % Passband Frequency
Fstop = 25;  % Stopband Frequency
Wpass = 1;   % Passband Weight
Wstop = 1;   % Stopband Weight

% Calculate the coefficients using the FIRLS function.
b  = firls(N, [0 Fpass Fstop Fs/2]/(Fs/2), [1 1 0 0], [Wpass Wstop]);
Hd = dfilt.dffir(b);

% [EOF]