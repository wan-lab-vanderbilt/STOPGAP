function sg_mrc_rescale_to_16bit(input_name,output_name)
%% sg_mrc_rescale_to_16bit
% A function to rescale a .mrc file to 16bit integer.
%
% WW 11-2018

%% Initialize input file

% Check computer type
[~,~,endian] = computer;
switch endian
    case 'L'
        sysfor='ieee-le';
    case 'B'
        sysfor='ieee-be';
end

% Open file
fid_in = fopen(input_name,'r',sysfor);

% Read header
[fid_in,header] = sg_fread_mrcheader(fid_in);


% Skip extended header
fseek(fid_in,(1024+header.next),'bof');%go to end end of extended Header


%% Initalize output file

% Open file
fid_out = fopen(output_name,'w');
if fid_out == -1
    error(['ACHTUNG!!! Error opening file: ',input_name,'!!!']);
end

% Write header
fid_out = sg_fwrite_mrcheader(fid_out,header);


%% Convert data
nx = double(header.nx); % Conversion required for larger files.
ny = double(header.ny);
nz = double(header.nz);
n_pixels = nx*ny*nz;

data_sum = 0;


% Read in voxel
switch header.mode
    case 0
        read_mode = 'int8=>int8';
    case 1
        read_mode = 'int16=>int16';
    case 2
        read_mode = 'single=>single';
end

% Read, convert, and write voxels in 100 steps
steps = floor(linspace(1,n_pixels,101));

for i = 1:100
    % Read size
    read_size = steps(i+1)-steps(i);
    
    % Read data
    data = fread(fid_in,read_size,read_mode);
    
    % Rescale data
    res_data = round(((data - header.amin).*(65536/header.amax)))-32768;
    data_sum = data_sum + sum(res_data);
    
    
    % Write out voxel
    fwrite(fid_out,res_data,'int16');
    
end


%% Rewrite header

% Go to beginning of file
fseek(fid_out,0,'bof');

% Update header
header.mode = 1;
header.amax = 32767;
header.amin = -32768;
header.amean = data_sum./n_pixels;

% Rewrite header
fid_out = sg_fwrite_mrcheader(fid_out,header);


% Close files
fclose(fid_in);
fclose(fid_out);




