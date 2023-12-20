function rect = sg_rectangle(dims,edges,sigma,center)
%% sg_rectangle
% Generate a binary rectangle with optional gaussian dropoff. 'dims'are the
% size of the volume, 'edges' is the size of the rectangle. If a single
% edge is given, a cube is assumed. 
%
% WW 11-2022

%% Check check

% Check dimensions
n_dims = numel(dims);
if n_dims == 1
    dims = [dims,dims,dims];
elseif n_dims ~= 3
    error('ACHTUNG!!! Invalid number of dimensions!!!');
end

% Check edges
n_edges = numel(edges);
if n_edges == 1
    edges = [edges,edges,edges];
elseif n_edges ~= 3
    error('ACHTUNG!!! Invalid number of edges!!!');
end

% Calculate centers
if nargin < 4
    center = floor(dims./2)+1;
end

% Check sigma
if (nargin == 2) || isempty(sigma)
    sigma = 0;
end
if numel(sigma) == 1
    sigma = ones(3,1).*sigma;
end

%% Calculate linear mask

% Linear mask array
lin_mask = cell(3,1);

% Loop through each dimension
for i = 1:3
    

    % Linear distance
    lin_dist = (1:dims(i))-center(i)';
    
    % Passthrough indices
    edge_cen = floor(edges(i)/2)+1;
    edge1 = edges(i) - edge_cen;
    edge2 = edge1 - edges(i) + 1;
    
    % Inialize linear mask
    lin_mask{i} = ones(dims(i),1);
    
    
    % Positive sigma
    p_sigma_idx = lin_dist > edge1;
    lin_mask{i}(p_sigma_idx) = exp(-((lin_dist(p_sigma_idx)-edge1)/sigma(i)).^2);
    
    % Negative sigma
    n_sigma_idx = lin_dist < edge2;
    lin_mask{i}(n_sigma_idx) = exp(-((abs(lin_dist(n_sigma_idx)-edge2))/sigma(i)).^2);
    
    
    % Threshold
    lin_mask{i}(lin_mask{i} < exp(-2)) = 0;
    
end


%% Generate cubic filter

% X-mask
rect = repmat(lin_mask{1},[1,dims(2),dims(3)]);

% Y-mask
rect = rect.*repmat(reshape(lin_mask{2},1,[]),[dims(1),1,dims(3)]);

% Z-mask
rect = rect.*repmat(reshape(lin_mask{3},1,1,[]),[dims(1),dims(2),1]);




