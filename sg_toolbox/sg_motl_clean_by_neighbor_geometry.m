%% sg_motl_clean_by_neigbor_geometry
% Clean a motivelist by local neighbor geometry. 
%
% The neighbor geometries are defined in a chimera .cmm file; it's best to
% define this file on a scale=1 neighbor plot. For each subtomogram, the 
% neighbor geometry is rotated and shifted into the subtomogram reference 
% frame, and the presence of each neighbor is detected. 
%
% Cleaning depends on a distance cutoff for a subtomogram to be considered 
% a neighbor, and the tolerance for missing neighbors. 
%
% WW 08-2018

%% Inputs

% File parameters
input_motl = 'allmotl_B_dclean2_4.star';            % Input motl name
output_motl = 'allmotl_B_dclean2_gclean_4.star';    % Output motl name
cmm_name = 'geometry_2points.cmm';                          % Geometry file
cmm_cen = 129;                                       % Center of geometry file
cmm_scale = 4;

% Cleaning parameters
dist_cut = 1;      % Distance tolerance for neighbor search
tolerance = 0;     % Number of missing neighbors that can be tolerated.


%% Initialize

% Read input motl
motl = sg_motl_read(input_motl);
n_motls = numel(motl);

% Read geometry
geometry = sg_cmm_read(cmm_name);
n_neighbors = numel(geometry);

% Parse motl positions
pos = zeros(3,n_motls);
pos(1,:) = [motl.orig_x] + [motl.x_shift];
pos(2,:) = [motl.orig_y] + [motl.y_shift];
pos(3,:) = [motl.orig_z] + [motl.z_shift];

% Parse neigbhor positions
if numel(cmm_cen)==1
    cmm_cen = ones(3,1).*cmm_cen;
end
npos = cat(1,[geometry.x],[geometry.y],[geometry.z]);
npos = npos - repmat(cmm_cen,[1,n_neighbors]);
npos = npos./4;

% Keep array
keep = false(n_motls,1);

% Number of matches for keeping
nmatch = n_neighbors - tolerance;

%% Perform geometric cleaning
disp('Starting geometric cleaning...');

t = tic;
c_step = n_motls/10;
c_disp = c_step;

for i = 1:n_motls
    
    % Rotate neighbor positions
    rmat = sg_euler2matrix(motl(i).phi,motl(i).psi,motl(i).the);
    r_npos = (rmat*npos) + repmat(pos(:,i),[1,n_neighbors]);
    
    % Calcualte neighbor matches
    matches = zeros(n_neighbors,1);
    for j = 1:n_neighbors
        dist = sg_pairwise_dist(r_npos(:,1),pos);
        matches(j) = any(dist <= dist_cut);
    end
    
    % Check for number of matches
    if sum(matches) >= nmatch
        keep(i) = true;
    end
    
    % Counter
    if i >= c_disp
        
        % Calculate time
        et = toc(t);
        tpm = et/i;
        rm = n_motls - i;
        rt = rm*tpm;
        
        if rt > 60
            rt = rt/60;
            tu = 'min';
        else
            tu = 'sec';
        end
        
        disp([num2str(i),' of ',num2str(n_motls),' processed... Remaining time ',num2str(rt,2),' ',tu,'...']);
        c_disp = c_disp + c_step;
    end
        
    
end

%% Write out new motl

% Generate new motl
new_motl = motl(keep);

% Write motl
sg_motl_write(output_motl,new_motl);    
disp([num2str(sum(keep)),' out of ',num2str(n_motls),' remaining...']);















