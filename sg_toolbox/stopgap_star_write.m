function stopgap_star_write(struct_array, star_name, dataname, fieldprefix, precision, spacesize)
%% stopgap_star_write
% A function to take a struct array and write it out as a .star file. This
% assumes that each field of the struct array is the same datatype. This
% also only writes loop-type star files.
%
% v1: WW 11-2017
% v2: WW 01-2018 Updated to check all fields prior to determining field
% types. Also updated handling of numeric arrays. 
%
% WW 01-2018
% struct_array=motl;
% star_name = 'test.star';
% dataname = 'stopgap_motivelist';
% fieldprefix = '';
% precision = 4;
% spacesize = 2;

%% Check check!!!
if nargin >= 2
    if nargin < 6
        spacesize = 2;
    end
    if nargin < 5
        precision = 10;
    end
    if nargin < 4
        fieldprefix = [];
    end
    if nargin < 3
        dataname = [];
    end
else
    error('Achtung!!! Minimum number of inputs is 2!!!!1!');
end

%% Parse struct array

% Parse fields
fields = fieldnames(struct_array);
n_fields = size(fields,1);
n_elements = numel(struct_array);

% Determine types for each field
f_types = cell(n_fields,1);
for i = 1:n_fields
    % Check type and write formatSpec
    test = {struct_array.(fields{i})};
    if all(cellfun(@(x) islogical(x),test))
        
        % Logical formatting
        f_types{i} = '% 1i';
        
    elseif all(cellfun(@(x) ischar(x),test))
        
        % Set to maximum string length, padded on the right
        ml = max(cellfun('length',{struct_array.(fields{i})}));
        f_types{i} = [' %-',num2str(ml),'s'];
        
    elseif all(cellfun(@(x) isnumeric(x),test))
        
        % Test for integer
        if all(cellfun(@(x) floor(x)==x, {struct_array.(fields{i})}))

            % Largest number of digits
            md = max(cellfun(@(x) floor(log10(abs(x)+1))+1,{struct_array.(fields{i})}));
            f_types{i} = ['% ',num2str(md+1),'i'];

        else

            % Largest number of digits before the decimal point
            md = max(cellfun(@(x) floor(log10(abs(floor(x))+1))+1,{struct_array.(fields{i})}));
            f_types{i} = ['% ',num2str(md+precision+2),'.',num2str(precision),'f'];
        end
        
        
    else
        error(['ACHTUNG!!! ',fields{i},' has mixed types!!!']);        
    end
end


%% Write outputs


% Open file
fid = fopen(star_name,'w');

% Write data name
fprintf(fid,'\n%s\n\n',['data_',dataname]);

% Write field names
fprintf(fid,'%s\n','loop_');
for i = 1:n_fields
    fprintf(fid,'%s\n',['_',fieldprefix,fields{i}]);
end
fprintf(fid,'%s\n','');

% Write data
space = repmat(' ',[1,spacesize-1]);
for i = 1:n_elements
    
    for j = 1:n_fields-1
        fprintf(fid,f_types{j},struct_array(i).(fields{j}));
        fprintf(fid,'%s',space);
    end
    fprintf(fid,f_types{end},struct_array(i).(fields{end}));
    fprintf(fid,'%s\n','');
    
end

fclose(fid);
























    
