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

% Read old motl
av3_motl = sg_emread(input_name);
n_motls = size(av3_motl,2);

% Intiailize .star motl
star_motl = sg_initialize_motl(n_motls);


% Fill fields
field_row = {'motl_idx',        4;...
             'score',           1;...
             'subtomo_num',     4;...
             'tomo_num',        5;...
             'object',          6;...
             'orig_x',          8;...
             'orig_y',          9;...
             'orig_z',          10;...
             'x_shift',         11;...
             'y_shift',         12;...
             'z_shift',         13;...
             'phi',             17;...
             'psi',             18;...
             'the',             19;...
             'class',           20;...
             };

for i = 1:size(field_row,1)
    temp_cell = num2cell(av3_motl(field_row{i,2},:));
    [star_motl.(field_row{i,1})] = temp_cell{:};
end

% Fill halfset
star_motl = sg_motl_fill_field(star_motl,'halfset','A');

% Write output
sg_motl_write(output_name,star_motl);
