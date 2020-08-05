%% sg_motl_batch_tube
% A function to batch generate motivelists for a set of tubes. 
%
% The input folder should contain a subfolder for each tomogram; each
% folder should be named after the tomogram number. Within each folder
% there should be a set of .cmm file containing tube centers, as picked
% from chimera's volume tracer. Each .cmm file should be named
% [root_name]_[tomo_num]_[obj_number].cmm. Radii can be supplied as a 
% single value or using a three column text file with columns tomo number,
% tube number and radius.
% 
% Points can also be thresholded with respect to tomogram boundaries.
%
% WW 07-2018

%% Inputs

% Input folder
metadata_folder = '/fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/2017/2017-12-15_gasv/subtomo2/metadata/';

% Center root name
tracer_root = 'clicker';
tracer_type = 'txt';    % txt or cmm

% Reconstruction list
rlist_name = 'recons_list.txt';

% Distances
l_dist = 2.5;    % Distance along tube axis
c_dist = 1.5;    % Distance around tube axis

% Radii 
rad = 76;

% Tomogram dir
tomo_dir = '/fs/pool/pool-plitzko/will_wan/2017/2017-12-15_gasv/tomos/bin8_white_ctffind/';
digits = 2;
padding = 10;    % Size of the edge boundary for thresholding; any centers within the boundary are removed.

% Output name
output_name = 'allmotl_1.star';


%% Initialize

% Read reconstructin list
rlist = dlmread(rlist_name);
n_tomos = numel(rlist);


% Initialize cell array
motl_cell = cell(n_tomos,1);

% % Check radii
% if ischar(rad)
%     % Read list
%     rad_array = dlmread(rad);
% elseif isnumeric(rad)
%     % Assign constant radius
%     rad_array = ones(n_tr,3).*rad;
%     % Parse tomo and tube numbers
%     for i = 1:n_tr        
%         [~,tr_name,~] = fileparts(tr_dir(i).name);
%         tr_parts = strsplit(tr_name,'_');
%         rad_array(i,1) = str2double(tr_parts{2});
%         rad_array(i,2) = str2double(tr_parts{3});
%     end
% end
      
% Parse numeric format for tomogram names
nfmt = ['%0',num2str(digits),'i'];


%% Generate motls for each tube

for i = 1:n_tomos
    
    % Determine number of tracer files
    tr_dir = dir([metadata_folder,'/',num2str(rlist(i),['%0',num2str(digits),'i']),'/',tracer_root,'_*.',tracer_type]);
    
    % Read tracer
    switch tracer_type
        case 'txt'
            tr = dlmread([metadata_folder,'/',num2str(rlist(i),['%0',num2str(digits),'i']),'/',tr_dir.name]);
            tr_idx = unique(tr(:,1));
            n_tr = numel(tr_idx);
        case 'cmm'
            tr = sg_cmm_read([metadata_folder,'/',tracer_root,'_',num2str(rad_array(j,1)),'_',num2str(rad_array(j,2)),'.cmm']);
    end
    
    tomo_cell = cell(n_tr,1);
    
    for j = 1:n_tr
        

        % Parse points
        switch tracer_type
            case 'txt'
                p_idx = tr(:,1) == tr_idx(j);
                points = tr(p_idx,2:4);
        end

        % Get surface positions
        [positions,eulers] = sg_motl_generate_tube_function(points',l_dist,c_dist,rad);
        n_pos = size(positions,2);

        % Parse positions
        x = round(positions(1,:));
        y = round(positions(2,:));
        z = round(positions(3,:));
        x_shift = positions(1,:) - x;
        y_shift = positions(2,:) - y;
        z_shift = positions(3,:) - z;

        % Generate motivelist
        temp_motl = sg_initialize_motl(n_pos);
        temp_motl = sg_motl_fill_field(temp_motl,'tomo_num',rlist(i));
        temp_motl = sg_motl_fill_field(temp_motl,'object',tr_idx(j));
        temp_motl = sg_motl_fill_field(temp_motl,'orig_x',x);
        temp_motl = sg_motl_fill_field(temp_motl,'orig_y',y);
        temp_motl = sg_motl_fill_field(temp_motl,'orig_z',z);
        temp_motl = sg_motl_fill_field(temp_motl,'x_shift',x_shift);
        temp_motl = sg_motl_fill_field(temp_motl,'y_shift',y_shift);
        temp_motl = sg_motl_fill_field(temp_motl,'z_shift',z_shift);
        temp_motl = sg_motl_fill_field(temp_motl,'phi',eulers(1,:));
        temp_motl = sg_motl_fill_field(temp_motl,'psi',eulers(2,:));
        temp_motl = sg_motl_fill_field(temp_motl,'the',eulers(3,:));

        % Threshold list
        tomo_name = [tomo_dir,'/',num2str(rad_array(j,1),nfmt),'.rec'];
        temp_motl = sg_motl_check_tomo_edges(tomo_name,temp_motl,padding);

        % Store motl
        tomo_cell{j} = temp_motl;
    end
    
    motl_cell{i} = cat(1,tomo_cell{:});
end

%% Generate complete motl

% Concatenate full motl
motl = cat(1,motl_cell{:});
n_motl = numel(motl);

% Fill subtomo number      
motl = sg_motl_fill_field(motl,'subtomo_num',1:n_motl);
motl = sg_motl_fill_field(motl,'halfset','A');
motl = sg_motl_fill_field(motl,'score',0);
motl = sg_motl_fill_field(motl,'class',1);

% Write output
sg_motl_write(output_name,motl);








