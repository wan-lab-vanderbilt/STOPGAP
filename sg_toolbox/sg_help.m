function sg_help(input_function)
%% sg_help
% Print help file for given input function.
%
% Inputs:
% input_function: name of input function (str)
%
%%%%%
% WW 06-2024

%% Open input file

% Get self path
[self_path,~,~] = fileparts(which('sg_help'));

% Parse helpfile name
helpfile_name = [self_path,'/help/',input_function,'.help'];

% Open input file
if ~exist(helpfile_name,'file')
    error(['ACHTUNG!!! Help file for ',input_function,' does not exist!!!']);
end
fid = fopen(helpfile_name,'r');


%% Print help

% Print text file
tline = fgetl(fid);
while ischar(tline)
%   if ~ischar(tline)
%       break
%   end
  fprintf('%s\n',tline);
  tline = fgetl(fid);
end
fclose(fid);


% Check for extra helpfile
extra_help = ['help_',input_function];
if exist(extra_help,'file')
    evalin('base',extra_help);
end


