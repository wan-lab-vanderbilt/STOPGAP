function sg_motl_stopgap_to_av3(input_name,output_name,split_by_tomo)
%% sg_motl_stopgap_to_av3
% Convert a stopgap .star motivelist to a TOM/AV3 formatted motivelist. If
% no output name is given, the same name as input file is used.
%
% Additional option to write out split motivelists by tomogram. For split
% motivelist, the tomogram number is appended at the end.
%
% WW 03-2021

%% Check check

% Check for splitting
if nargin < 3
    split_by_tomo = false;
end

% Check for output filename.
if nargin == 1
    [path,name,~] = fileparts(input_name);
    if ~isempty(path)
        path = [path,'/'];
    end
    output_name = [path,name,'.em'];
end


%% Convert
disp(['Converting input STOPGAP motivelist: ',input_name]);

% Read old motl
star_motl = sg_motl_read2(input_name);
n_motls = numel(star_motl.motl_idx);

% Intiailize AV3 motl
av3_motl = zeros(20,n_motls);

% Fill fields
av3_motl(1,:) = star_motl.score;
av3_motl(4,:) = star_motl.subtomo_num;
av3_motl(5,:) = star_motl.tomo_num;
av3_motl(6,:) = star_motl.object;
av3_motl(7,:) = cellfun(@(x) double(x)-64, star_motl.halfset);
av3_motl(8,:) = star_motl.orig_x;
av3_motl(9,:) = star_motl.orig_y;
av3_motl(10,:) = star_motl.orig_z;
av3_motl(11,:) = star_motl.x_shift;
av3_motl(12,:) = star_motl.y_shift;
av3_motl(13,:) = star_motl.z_shift;
av3_motl(17,:) = star_motl.phi;
av3_motl(18,:) = star_motl.psi;
av3_motl(19,:) = star_motl.the;
av3_motl(20,:) = star_motl.class;

%% Write output


if ~split_by_tomo
    disp(['Writing out AV3 motivelist: ',output_name]);
    
    % Write single output
    sg_emwrite(output_name,av3_motl);
    
    
else
        
    % Find tomograms
    tomos = unique(av3_motl(5,:));
    n_tomos = numel(tomos);
    
    % Parse name
    [path,name,~] = fileparts(output_name);
    if ~isempty(path)
        path = [path,'/'];
    end
    output_root = [path,name];
    
    % Loop through each tomogram
    for i = 1:n_tomos
        
        % Assemble name
        split_name = [output_root,'_',num2str(tomos(i)),'.em'];
        
        % Determine tomo indices
        tomo_idx = av3_motl(5,:) == tomos(i);
        
        % Write split motl
        disp(['Writing out split AV3 motivelist for tomogram ',num2str(tomos(i)),': ',split_name]);
        sg_emwrite(split_name,av3_motl(:,tomo_idx));
        
    end
end


        



