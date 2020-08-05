function cube_mask = sg_cube_mask(boxsize,sigma)
%% sg_cube_mask
% Generate a cubic edge mask with gaussian dropoff. This can be useful for
% minimizing edge artifcats when calculating Fourier transforms.
%
% WW 10-2018


%% Check check

if numel(boxsize) == 1
    boxsize = ones(3,1).*boxsize;
end

if numel(sigma) == 1
    sigma = ones(3,1).*sigma;
end


%% Calculate linear mask

% Linear mask array
lin_mask = cell(3,1);

% Loop through each dimension
for i = 1:3
    % Center of box
    cen = floor(boxsize(i)/2)+1;

    % Linear distance
    lin_dist = abs((1:boxsize(i))-cen)';

    % Passthrough indices
    radius = cen-floor(sigma(i)*1.8);
    sigma_idx = lin_dist > radius;

    % Linear mask
    lin_mask{i} = ones(boxsize(i),1);
    lin_mask{i}(sigma_idx) = exp(-((lin_dist(sigma_idx)-radius)/sigma(i)).^2);
    lin_mask{i}(lin_mask{i} < exp(-2)) = 0;
end


%% Generate cubic filter

% X-mask
cube_mask = repmat(lin_mask{1},[1,boxsize(2),boxsize(3)]);

% Y-mask
cube_mask = cube_mask.*repmat(reshape(lin_mask{2},1,[]),[boxsize(1),1,boxsize(3)]);

% Z-mask
cube_mask = cube_mask.*repmat(reshape(lin_mask{3},1,1,[]),[boxsize(1),boxsize(2),1]);


