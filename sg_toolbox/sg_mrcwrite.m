function sg_mrcwrite(mrc_name,data,header,varargin)
%% sg_mrcwrite
% A function to write a .mrc file. If no header is provided, a generic one
% will be generated. Name-value pairs can be given to write specific header
% parameters; pixelsize can also be provided.
%
% Extended headers are not supported and will be removed.
%
% WW 06-2018

%% Check check

% Check for empty header
if nargin < 2
    error('ACHTUNG!!! Not enough input arguments!!!');
elseif nargin == 2
    header = sg_generate_mrc_header;
elseif isempty(header)
    header = sg_generate_mrc_header;
end
        

%% Write mrc

% Open file
fid = fopen(mrc_name,'w');
if fid == -1
    error(['ACHTUNG!!! Error opening file: ',mrc_name,'!!!']);
end

% Update header
options = cat(1,varargin(:),{'next';0});
header = sg_update_mrc_header(data,header,options{:});

% Write header
fid = sg_fwrite_mrcheader(fid,header);

% Write data
data = data(:);
switch header.mode
    case 0
        fwrite(fid,data,'int8');
    case 1
        fwrite(fid,data,'int16');
    case 2
        fwrite(fid,data,'single');
end


fclose(fid);

