function cmm = sg_cmm_read(cmmname)
%% sg_cmm_read
% A function for reading in chimera .cmm files. 
%
% WW 08-2018

%% Read file

% Read in cmm file
fid = fopen(cmmname);
rawcmm = textscan(fid, '%s', 'Delimiter', '\n'); rawcmm = rawcmm{1};
fclose(fid);
n_lines = size(rawcmm,1);

% % Fid number of marker sets
% set_name_idx = find(~cellfun('isempty',strfind(cmm{1},'<marker_set name=')));
% set_end_idx = find(~cellfun('isempty',strfind(cmm{1},'</marker_set>')));
% n_sets = numel(set_name_idx);


%% Initialize empty .cmm file

% Field names
cmm_fields = {'marker_set_name','marker_id','x','y','z','r','g','b','radius'};

% Initalize struct array
cmm = struct();
n_fields = numel(cmm_fields);
for i = 1:n_fields
    cmm(n_fields).(cmm_fields{i}) = [];
end
cmm = cmm';


%% Loop through and fill fields

% Running marker set name
msn = '';

% Starting line types
s_line = {'<marker_set name','<marker id','</marker_set>'};

% Marker line format
marker_format = '<marker id="%f" x="%f" y="%f" z="%f" r="%f" g="%f" b="%f" radius="%f"/>';

% Loop through lines
c = 1;  % Struct array counter
for i = 1:n_lines
    
    % Check line type
    line_check = zeros(3,1);
    for j = 1:3
        line_check(j) = strncmpi(s_line{j},rawcmm{i},numel(s_line{j}));
    end
    line_idx = find(line_check);
    if isempty(line_idx)
        continue
    end
        
    
    
    % Operate according to line type
    switch line_idx
        case 1
            msn = rawcmm{i}(19:end-2);
            
        case 2
            m_data = sscanf(rawcmm{i},marker_format);
            cmm(c).marker_set_name = msn;
            cmm(c).marker_id = m_data(1);
            cmm(c).x = m_data(2);
            cmm(c).y = m_data(3);
            cmm(c).z = m_data(4);
            cmm(c).r = m_data(5);
            cmm(c).g = m_data(6);
            cmm(c).b = m_data(7);
            cmm(c).radius = m_data(8);
            c = c+1;
    end                
    
end

% Crop .cmm
cmm = cmm(1:c-1);

