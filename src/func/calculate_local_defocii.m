function defocii = calculate_local_defocii(p,o,f,idx,motl)
%% calculate_local_defocii
% A function to calculate local defocii value for a given particle. In
% order to calculate this, the wedgelist must contain the tomogram's
% dimensions. The defocus offset is calculated using the particle position
% and it's distance from the tilt-axis (assumed to be on the central 
% Y-axis) and it's distance from the central focal plane (defined as the
% center of mass in Z, i.e. the mean Z value of the allmotl).
%
% WW 01-2018

%% Initialize

% Wedgelist index
w = f.wedge_idx;

% If there are not enough parameters, return mean defocii
if ~isfield(o.wedgelist,'tomo_dims')
    defocii = o.wedgelist(w).defocii;
    return
end

% Shifted position
pos = motl(8:10,1,1) + motl(11:13,1,1);

% Number of tilts
n_tilts = numel(o.wedgelist(w).wedge_angles);

% Calcuate center of Y and Z dimensions
cenX = floor(o.wedgelist(w).tomo_dims(1)/2)+1;
cenZ = mean((o.allmotl(10,:)+o.allmotl(13,:)),2);

% Offset positions in tomogram
x = (pos(1)-cenX).*p(idx).pixelsize;
z = (pos(3)-cenZ).*p(idx).pixelsize;

%% Calcualte defocii

% Average defocii
if size(o.wedgelist(w).defocii,2) == 3
    defocii = mean(o.wedgelist(w).defocii(1:2,:),1);
elseif size(o.wedgelist(w).defocii,2) == 1
    defocii = o.wedgelist(w).defocii;
else
    error('ACHTUNG!!! Invalid number of defocii columns!!!');
end

% Calculate offsets
offsets = zeros(n_tilts,1);

for i = 1:n_tilts
    
    % Calculate rotation matrix
    a = o.wedgelist(w).wedge_angles(i);
    r = [cosd(a), -sind(a); sind(a), cosd(a)];
    
    % Rotate coords
    r_coords = r*[x;z];
    
    % Store offset
    offsets(i) = r_coords(2);
        
end

% Calculate offset defocii
defocii = defocii - (offsets./10000); % Negative Z is increasing underfocus



