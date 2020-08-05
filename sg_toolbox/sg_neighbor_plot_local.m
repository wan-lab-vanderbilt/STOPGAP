%% sg_neighbor_plot_local
% A function for reading in motivelist and generating a neighbor plot for
% a motivelist. When calculating the neighbor plot, only inter-subunit
% distances within each object is considered.
%
% WW 08-2018

%% Inputs


% Input motl
motl_name = 'allmotl_combined_3.star';!

% Output root name
output_root = 'vp40_nplot.mrc';

% Plot parameters
boxsize = 400;
scaling = 0.2;



%% Initlaize

% Read motl
motl = sg_motl_read(motl_name);

% Generate object list
obj_table = sg_object_list(motl);
n_obj = size(obj_table,2);


% Center of plot
cen = floor(boxsize/2)+1;

% Distance cutoff
d_cut = floor((boxsize-1)/2);


%% Generate plots

% Initialize plot
nplot = zeros(boxsize,boxsize,boxsize);

for i = 1:n_obj       
    disp(['Processing object ',num2str(i),' of ',num2str(n_obj),'...']);
    
    % Parse object parameters
    obj_idx = ([motl.tomo_num]==obj_table(1,i)) & ([motl.object]==obj_table(2,i));
    n_pos = sum(obj_idx);
    pos = zeros(3,n_pos);
    pos(1,:) = [motl(obj_idx).orig_x] + [motl(obj_idx).x_shift];
    pos(2,:) = [motl(obj_idx).orig_y] + [motl(obj_idx).y_shift];
    pos(3,:) = [motl(obj_idx).orig_z] + [motl(obj_idx).z_shift];
    pos = pos.*scaling;
    phi = [motl(obj_idx).phi];
    psi = [motl(obj_idx).psi];
    the = [motl(obj_idx).the];
    
    % Determine neighbors for each position
    for j = 1:n_pos
        
        % Calculate Euclidean distances
        dist = sg_pairwise_dist(pos(:,j),pos);
        
        % Threshold by distance cutoff
        d_idx = dist <= d_cut;
        
        % Parse positions and shift to center
        temp_pos = pos(:,d_idx) - repmat(pos(:,j),[1,sum(d_idx)]);
        
        % Generate rotation matrix
        rmat = sg_euler2matrix(-psi(j),-phi(j),-the(j));
        
        % Rotate positions
        rpos = round(rmat*temp_pos)+cen;
        
        % Add positions to map
        for k = 1:size(rpos,2)
            nplot(rpos(1,k),rpos(2,k),rpos(3,k)) = nplot(rpos(1,k),rpos(2,k),rpos(3,k)) + 1;
        end
        
    end
    

end

% Normalize central peak
% nplot(cen,cen,cen) = 0;
% nplot(cen,cen,cen) = max(nplot(:));
nplot = nplot./nplot(cen,cen,cen);
nplot(cen,cen,cen) = 0;
nplot(cen,cen,cen) = max(nplot(:));

% Write output
sg_volume_write(output_root,nplot);
        
        
    
    
        
