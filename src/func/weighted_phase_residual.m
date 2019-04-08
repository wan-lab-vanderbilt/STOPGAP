function residual = weighted_phase_residual(target_phases,template_ft,amplitudes,boxsize,x,y,z,shift)
%% weighted_phase_residual
% A function for calculating weighted phase residuals. Inputs are
% target_phases, i.e. the phases of the target volume. The template_ft is
% the fourier transform of the template. amplitudes are the amplitudes to
% weight the residuals by. Boxsize is the size of the volumes. x,y,z are 
% gridpoints that give the distance from the zero frequency. shift is the 
% real-space cartesian shift. 
%
% It is not necessary to calculate phase residuals for full volumes, but
% only for regions of interest. As such, data can be arbitrarily organized,
% i.e. fftshifted or in a 1D vector, so long as all points are in the same
% order for all arrays. 
%
% WW 02-2018


%% Calculate phase shift

% Calcualte shift vectors
shift = shift./boxsize;

% Signal delay for shift
tau = (shift(1)*x) + (shift(2)*y) + (shift(3)*z);

% Calculate phase shift
phase_shift = exp(-2*pi*1i*tau);

%% Shift template and strip phases

% Shift template
shift_template = template_ft.*phase_shift;

% Template phases
temp_phases = angle(shift_template);


%% Calculate phase residual

% Raw in phase differences
d_phase = abs(target_phases - temp_phases);

% Weighted phase differences
w_phase = amplitudes.*d_phase;

% Weighted phase residual
residual = sum(w_phase(:))./sum(amplitudes(:));







