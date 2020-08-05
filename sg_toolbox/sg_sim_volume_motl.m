%% sg_sim_volume_motl
% A function to generate a motivelist of particles randomly placed into a
% volume. This would be the first step to simulating a tomogram.
%
% This script is relatively simple, it requires the class number of an
% object with it's radius and relative stoichiometry. Objects are randomly
% placed and then checked for clashing, which is defined by radial overlap
% of two objects. If an object is overlapping, the position is regenerated
% until either no overlap occurs, or the maximum number of tries is
% reached. If the maximum number of tries is reached, the script is
% terminated.
%
% WW 07-2019

%% Inputs

% Volume parameters
vol_size = [928,928,232];

% Number of objects
n_obj = 1000;

% Object parameters (Class ID, radius, fractional stoichiometry)
obj_param = [1, 20, 0.5;
             2, 30, 0.5];

% Max tries
max_tries = 10000;

% Motivelist parameters
motl_name = 'test.star';
tomo_num = 1;



%% Initialize

% Check check
vol_size = reshape(vol_size,3,1);

% Number of object types
n_obj_type = size(obj_param,1);

% Generate class array
class_cell = cell(n_obj_type,1);
for i = 1:n_obj_type
    class_cell{i} = ones(ceil(n_obj*obj_param(i,3)),1).*obj_param(i,1);    % Rough class counts
end
temp_class = cat(1,class_cell{:});            % May have too many objects
r_idx = randperm(numel(temp_class));          % Randomize classes for even distribution
class = sort(temp_class(r_idx(1:n_obj)));     % Ensure proper number of objects


%% Generate motivelist

% Maximum tries flag
maxed_out = false;

% Initialize position array
pos = zeros(3,n_obj);

% Position coutner
p = 1;

% Loop through objects
for i = 1:n_obj
    
    % Parse info
    obj_idx = class(i) == obj_param(:,1);       % Object index
    rad = obj_param(obj_idx,2);                 % Radius
    
    
    
    % Generate position flag
    gen = true;
    t = 1;  % Try counter
    
    while gen
        
        % Generate random position
        temp_pos = rand(3,1).*vol_size;
        
        % Check min
        if any((temp_pos - rad) < 1)
            continue
        end
        
        % Check max
        if any((temp_pos+rad) > vol_size)
            continue
        end
        
        
        % Check distances
        if i > 1
            
            % Calculate distances
            dist = sg_pairwise_dist(temp_pos,pos(:,1:p-1));
            
            % Parse radial cutoff
            rad_cut = zeros(1,p-1);
            for j = 1:n_obj_type
                temp_idx = class(1:p-1) == obj_param(j,1);
                rad_cut(temp_idx) = obj_param(j,2);
            end
            rad_cut = rad_cut + rad;
            
            % Check for clash
            if any(dist < rad_cut)
                
                
                if t < max_tries
                    
                    % Try again
                    t = t+1;
                    continue
                else
                    
                    % End function
                    disp('Max tries reached...');
                    maxed_out = true;
                    break
                end
                
            else
                
                % No clashes, store position
                pos(:,i) = temp_pos;
                gen = false;
            end
            
        else
            
            % Store initial position
            pos(:,i) = temp_pos;
            gen = false;
            
        end
        
    end
    
    % Max tries
    if maxed_out
        disp(['Total number of points: ',num2str(p-1)]);
        break
    end
        
    
    % Increment counter
    p = p+1;
    
end
  
% Number of motivelist entries
n_motl = p-1;


%% Generate motivelist

% Initialize motivelist
motl = struct();

% Fill fields
motl.motl_idx = int32((1:n_motl)');
motl.tomo_num = ones(n_motl,1,'int32').*int32(tomo_num);
motl.object = ones(n_motl,1,'int32');
motl.subtomo_num = int32((1:n_motl)');
motl.halfset = repmat({'A'},n_motl,1);
motl.orig_x = round(pos(1,1:n_motl)');
motl.orig_y = round(pos(2,1:n_motl)');
motl.orig_z = round(pos(3,1:n_motl)');
motl.score = zeros(n_motl,1,'single');
motl.x_shift = (pos(1,1:n_motl)')-motl.orig_x;
motl.y_shift = (pos(2,1:n_motl)')-motl.orig_y;
motl.z_shift = (pos(3,1:n_motl)')-motl.orig_z;
motl.phi = rand(n_motl,1).*360;
motl.psi = rand(n_motl,1).*360;
motl.the = rand(n_motl,1).*180;
motl.class = int32(class(1:n_motl));

% Write motl
sg_motl_write2(motl_name,motl);











