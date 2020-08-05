function sg_motl_dynamo_to_stopgap(input_name,output_name)
%% sg_motl_dynamo_to_stopgap
% Convert a stopgap .star motivelist to a DYNAMO formated table file.
%
% Angular conversions follow the convention after dynamo 0.8, as defined in
% dynamo__motl2table.m
%
% WW 02-2019

%% Check check

% Check for table name
if nargin < 2
    [path,name,~] = fileparts(input_name);
    if ~isempty(path)
        path = [path,'/'];
    end
    output_name = [path,name,'.star'];
end

%% Convert!!!

% Read table
table = real(dlmread(input_name));
n_motls = size(table,1);

% Initialize table
motl = sg_initialize_motl(n_motls);

% Fill table with motivelist parameters
motl = sg_motl_fill_field(motl,'subtomo_num',table(:,1));
motl = sg_motl_fill_field(motl,'halfset','A');
motl = sg_motl_fill_field(motl,'x_shift',table(:,4));
motl = sg_motl_fill_field(motl,'y_shift',table(:,5));
motl = sg_motl_fill_field(motl,'z_shift',table(:,6));
motl = sg_motl_fill_field(motl,'phi',-table(:,9));
motl = sg_motl_fill_field(motl,'psi',-table(:,7));
motl = sg_motl_fill_field(motl,'the',-table(:,8));
motl = sg_motl_fill_field(motl,'score',table(:,10));
motl = sg_motl_fill_field(motl,'tomo_num',table(:,20));
motl = sg_motl_fill_field(motl,'object',table(:,21));
motl = sg_motl_fill_field(motl,'class',table(:,22));
motl = sg_motl_fill_field(motl,'orig_x',table(:,24));
motl = sg_motl_fill_field(motl,'orig_y',table(:,25));
motl = sg_motl_fill_field(motl,'orig_z',table(:,26));

% Write output
sg_motl_write(output_name,motl);



