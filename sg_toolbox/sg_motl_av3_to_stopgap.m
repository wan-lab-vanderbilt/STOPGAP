function sg_motl_av3_to_stopgap(input_name,output_name)
%% sg_motl_av3_to_stopgap
% Convert TOM/AV3 motivelist to stopgap motivelist.
%
% WW 07-2018

%% Check check


% Check output name
if nargin < 2
    if nargin == 1
        [path,name,~] = fileparts(input_name);
        if ~isempty(path)
            path = [path,'/'];
        end
        output_name = [path,name,'.star'];
    end
end


%% Convert

% Read AV3 motl
av3_motl = sg_emread(input_name);
n_motls = size(av3_motl,2);

% Get motl fields 
motl_fields = sg_get_motl_fields;
n_fields = size(motl_fields,1);


% AV3 Motl indices
motl_row = {'motl_idx',        4;...
            'tomo_num',        5;...
            'object',          6;...
            'subtomo_num',     4;...
            'halfset',         [];...
            'orig_x',          8;...
            'orig_y',          9;...
            'orig_z',          10;...
            'score',           1;...
            'x_shift',         11;...
            'y_shift',         12;...
            'z_shift',         13;...
            'phi',             17;...
            'psi',             18;...
            'the',             19;...
            'class',           20;...
            };

% Initalize struct array
motl = struct();

% Fill fields
for i = 1:n_fields
    switch motl_fields{i,3}
        case 'int'
            motl.(motl_fields{i,1}) = int32(av3_motl(:,motl_row{i,2}));
        case 'float'
            motl.(motl_fields{i,1}) = single(av3_motl(:,motl_row{i,2}));
        case 'str'
            motl.(motl_fields{i,1}) = repmat({'A'},n_motls,1);
    end
end

% Write output
sg_motl_write2(output_name,motl);


