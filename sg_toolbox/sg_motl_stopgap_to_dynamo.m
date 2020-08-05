function sg_motl_stopgap_to_dynamo(input_name,wedgelist_name,output_name)
%% sg_motl_stopgap_to_dynamo
% Convert a stopgap .star motivelist to a DYNAMO formated table file.
%
% Angular conversions follow the convention after dynamo 0.8, as defined in
% dynamo__motl2table.m
%
% WW 02-2019

%% Check check

% Check for table name
if nargin < 3
    [path,name,~] = fileparts(input_name);
    if ~isempty(path)
        path = [path,'/'];
    end
    output_name = [path,name,'.tbl'];
end

% Check for wedgelist
if nargin < 2
    wedgelist_name = [];
end


%% Convert

% Read old motl
star_motl = sg_motl_read(input_name);
n_motls = numel(star_motl);

% Initialize table
table = zeros(n_motls,26);

% Fill table with motivelist parameters
table(:,1) = [star_motl.subtomo_num];       % Tag
table(:,2) = 1;                             % Aligned
table(:,3) = 1;                             % Averaged
table(:,4) = [star_motl.x_shift];           % dx     
table(:,5) = [star_motl.y_shift];           % dy
table(:,6) = [star_motl.z_shift];           % dz
table(:,7) = -[star_motl.psi];              % tdrot
table(:,8) = -[star_motl.the];              % tilt
table(:,9) = -[star_motl.phi];              % narot
table(:,10)= [star_motl.score];             % CC

table(:,20)= [star_motl.tomo_num];          % Tomo
table(:,21)= [star_motl.object];            % Region (Object in STOPGAP)
table(:,22)= [star_motl.class];             % Class

table(:,24)= [star_motl.orig_x];            % X in tomogram
table(:,25)= [star_motl.orig_y];            % Y in tomogram
table(:,26)= [star_motl.orig_z];            % Z in tomogram


%% Fill wedgelist parameters

if ~isempty(wedgelist_name)
    
    % Read wedgelist
    w = sg_wedgelist_read(wedgelist_name);
    
    % Parse tomograms
    tomos = unique([star_motl.tomo_num]);
    n_tomos = numel(tomos);
    
    for i = 1:n_tomos
        
        % Determine wedgelist index
        w_idx = find([w.tomo_num] == tomos(i));
        
        % Determine table indices
        t_idx = table(:,20) == tomos(i);
        
        % Assign min/max tilt
        table(t_idx,14) = min(w(w_idx).tilt_angle);
        table(t_idx,15) = max(w(w_idx).tilt_angle);
        
    end
end
        
    

%% Write output

dlmwrite(output_name,table,' ');







        