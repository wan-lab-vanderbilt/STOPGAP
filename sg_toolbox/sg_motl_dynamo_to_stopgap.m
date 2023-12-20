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



%% Convert

% Read dynamo table
table = real(dlmread(input_name));
n_motls = size(table,1);

% Get motl fields 
motl_fields = sg_get_motl_fields;
n_fields = size(motl_fields,1);


% dynamo table indices
table_row = {'motl_idx',        1;...
             'tomo_num',        20;...
             'object',          21;...
             'subtomo_num',     1;...
             'halfset',         [];...
             'orig_x',          24;...
             'orig_y',          25;...
             'orig_z',          26;...
             'score',           10;...
             'x_shift',         4;...
             'y_shift',         5;...
             'z_shift',         6;...
             'phi',             9;...
             'psi',             7;...
             'the',             8;...
             'class',           22;...
             };

% Initalize struct array
motl = struct();

% Fill fields
for i = 1:n_fields
    switch motl_fields{i,3}
        case 'int'
            motl.(motl_fields{i,1}) = int32(table(:,table_row{i,2}));
        case 'float'
            motl.(motl_fields{i,1}) = single(table(:,table_row{i,2}));
        case 'str'
            motl.(motl_fields{i,1}) = repmat({'A'},n_motls,1);
    end
end

% Invert eulers
motl.phi = -motl.phi;
motl.psi = -motl.psi;
motl.the = -motl.the;

% Write output
sg_motl_write2(output_name,motl);


