function sg_emwrite(filename,data,data_type)
%% sg_emwrite
% Write out data as a .em file. If data_type is not provided, the default
% output data_type is 'single'.
%
% WW 08-2018

%% Check check

% Check data type
if nargin == 2
    
    d_idx = 5;
    dtype = 'single';
    
elseif nargin == 3
    switch data_type
        case {1,'char'}
            d_idx = 1;
            dtype = 'char';
        case {2,'int16','short'}
            d_idx = 2;
            dtype = 'int16';
        case {4,'int32','long'}
            d_idx = 4;
            dtype = 'int32';
        case {5,'float32','single'}
            d_idx = 5;
            dtype = 'single';
        case {8,'float64','double'}
            d_idx = 8;
            dtype = 'double';
        otherwise
            error('ACHTUNG!!! Unsupported data type!!!');           
    end
else      
    error('ACHTUNG!!! Incorrect number of inputs!!!')
end


% Open file
fid = fopen(filename,'w','ieee-le');
if fid == -1
    error(['ACHTUNG!!! Cannot open file: ',filename]);
end


%% Write header
            
% Write machine information
fwrite(fid,[6,0,0,d_idx],'int8');

% Write dimension formation
fwrite(fid,size(data,1),'int32');
fwrite(fid,size(data,2),'int32');
fwrite(fid,size(data,3),'int32');

% Fill header with zeros
for i = 1:496
    fwrite(fid,0,'char');
end

% Write data
fwrite(fid,data,dtype);

% Close file
fclose(fid);



