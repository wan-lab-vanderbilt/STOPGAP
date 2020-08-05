function ctf = sg_ctf(df, pshiftdeg, famp, cs, evk, f)
%% sg_ctf
% Calculate a CTF curve.
%
% WW 07-2018

%% Unit conversions
df=df*1.0e4;                % Convert defocus from microns to Angstroms.
cs=cs*1.0e7;            %  Convert sperical aberation term from mm to Angstroms
pshift=pshiftdeg*pi/180;    % Convert phase shift to radians.


%% Calculate electron wavelength

% Precise method
h = 6.62606957e-34;
c = 299792458;
erest = 511000;
v = evk*1000;
echarge = 1.602e-19;
lambda = (c*h)/sqrt(((2*erest*v)+(v^2))*(echarge^2))*(10^10);

%% Calculate weighting factors
w = (1-(famp^2))^0.5;

%% CTF calculation
v = ((pi.*lambda.*(f.^2)).*(df - 0.5.*(lambda^2).*(f.^2).*cs))+pshift;
ctf = (w*sin(v)) + (famp*cos(v));    



