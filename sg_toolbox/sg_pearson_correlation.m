function cc = sg_pearson_correlation(a,b)
%% sg_pearson_correlation
% A function to take two arrays, linearize them, and calculate the Pearson
% cross corelation.
%
% For calculating non-shifted CC values, this is about 7x faster than
% calculating the Fourier transforms and Fourier normalizations.
%
% WW 09-2016

%% Calculate cross correlation

% Linearize arrays
a = a(:);
b = b(:);

% Mean subtract
a = a-mean(a);
b = b-mean(b);

% Sum of squares
a_ss = sum(a.^2);
b_ss = sum(b.^2);

% Calculate CC
cc = sum(a.*b)/sqrt(a_ss*b_ss);





