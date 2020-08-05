function header = sg_update_mrc_header(data,header,varargin)
%% sg_update_mrc_header
% A function to update the fields in an .mrc header given input data.
%
% If a header is given, this header is updated, otherwise a generic header
% is generated.
%
% Input can be given as name-value pairs.
%
% WW 06-2018

%% Parse name value pairs

% Check for pairs
if numel(varargin) == 1
    
    if ~isempty(varargin{1})
        error('ACHTUNG!!! Input parameters must be given as name-value paris!!!');
    end
    
elseif numel(varargin) > 1
    
    if mod(numel(varargin),2)
        error('ACHTUNG!!! Input parameters must be given as name-value paris!!!');
    end    
    
    % Parse pairs
    value_pairs = reshape(varargin,2,[])';
    n_pairs = size(value_pairs,1);

end

% Non-header inputs
non_header = {'pixelsize'};

%% Initalize default header

% Initialize header fields
header_fields = sg_default_mrc_header_fields;

% Check for input header
if isempty(header)
    
    % Generate default header
    header = sg_generate_mrc_header(header_fields);
    
else
    
    % Check fields
    header = orderfields(header,header_fields(:,1));
    
end

%% Parse pixelsize

% Check for input pixelsize
if exist('value_pairs','var')
    
    p_idx = strcmp(value_pairs(:,1),'pixelsize');
   if any(p_idx)
    
        switch numel(value_pairs{p_idx,2})
            case 1
                pixelsize = repmat(value_pairs{p_idx,2},[3,1]);
            case 2
                pixelsize = [value_pairs{p_idx,2}(:);1];
            case 3
                pixelsize = value_pairs{p_idx,2};
            otherwise
                error('ACHTUNG!!! Pixel size must be given with either 1, 2, or 3 dimensions!!!');
        end
       
    else

        % Attempt to parse pixelsize from old header
        pixelsize = [header.xlen/single(header.mx), header.ylen/single(header.my), header.zlen/single(header.mz)];
        nan_idx = isnan(pixelsize);
        pixelsize(nan_idx) = 1;
   
   end
end


%% Update header values from input pairs

if exist('value_pairs','var')
    
    for i = 1:n_pairs
        % Check that value pair is in header
        if ~any(strcmp(value_pairs{i,1},header_fields(:,1)))
            if ~any(strcmp(value_pairs{i,1},non_header))
                error(['ACHTUNG!!! Invalid input argument: ',value_pairs{i,1},'!!!']);
            end
        else
            header.(value_pairs{i,1}) = value_pairs{i,2};
        end
    end
end
            
            
    
%% Update data-related fields

% Dimensions
[x,y,z] = size(data);
header.nx = x;
header.ny = y;
header.nz = z;
header.mx = x;
header.my = y;
header.mz = z;


% Lengths
header.xlen = x*pixelsize(1);
header.ylen = y*pixelsize(2);
header.zlen = z*pixelsize(3);
                 
% Statistics
header.amin = min(data(:));
header.amax = max(data(:));
header.amean = mean(data(:));

% Mode
switch class(data)
    case 'int8'
        header.mode = 0;
    case 'int16'
        header.mode = 1;
    case {'single','double'}
        header.mode = 2;
    otherwise
        error('ACHTUNG!!! Input data has unsupported data type!!! Only "int8", "int16", and "float" suppported!!!');        
end









