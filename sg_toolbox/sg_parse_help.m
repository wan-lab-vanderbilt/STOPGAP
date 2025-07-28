function sg_parse_help(input_function)
%% sg_parse_help
% Parse the help text block from a function and save it as plain-text. The
% output file takes the name of the input_function with the file extension
% '.help'.
%
% Inputs:
% input_function: name of input function (str)
%
%%%%%
% WW 06-2024

%% Initialize

% Get self path
[self_path,~,~] = fileparts(which('sg_parse_help'));

% Get path of function
[func_path,func_name,func_ext] = fileparts(which(input_function));

% Open function file
fid = fopen([func_path,'/',func_name,func_ext],'r');

% Determine number of lines in file
n_lines = 0;
tline = fgetl(fid);
while ischar(tline)
  tline = fgetl(fid);
  n_lines = n_lines+1;
end
frewind(fid);       % Go back to start of text file


% Initialize cell array
text_cell = cell(n_lines,1);

% Output name
output_name = [self_path,'/help/',func_name,'.help'];


%% Parse text

for i = 1:n_lines
    
    % Read line
    temp_line = fgetl(fid);
    
    % Check for comment
    if startsWith(temp_line,'%')
        
        % Check for end of comment block
        if startsWith(temp_line,'%%%%%')
            % Exit loop
            break
        end
       
        % Clear whitespace
        temp_line = strtrim(temp_line(2:end));
        
%         % Check for empty line (assume newline)
%         if isempty(temp_line)
%             temp_line = newline;
%         end
        
        % Store line
        text_cell{i} = temp_line;
        
    end
end

% Close text file
fclose(fid);

% Store number of comment lines
comment_end = i-1;

%% Print text to file

% Open output file
out_fid = fopen(output_name,'w');

% Print lines
for i = 1:comment_end
    fprintf(out_fid,'%s\n',text_cell{i});
end

fclose(out_fid);

