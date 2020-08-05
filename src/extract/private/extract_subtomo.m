function stats = extract_subtomo(tomogram,pixelsize,motl,coords,subtomo_name,subtomo_digits,extract_size,boxsize,format,f)

%% extract_subtomo
% A function for extracting a subtomogram. If the subtomogram is not
% completely within the boundaries, the out of bound areas are filled with
% zeros.
%
% WW 08-2018

%% Check check

% Check inputs
if nargin == 9
    f = struct();
end

% Check for rescaling
if extract_size == boxsize
    rescale = false;
else
    rescale = true;
end

%% Initialize

% Initialize stats array
n_motls = numel(motl);
stats = zeros(n_motls,3);
stats(:,1) = [motl.subtomo_num];

% Subtomo formatspec
sfmtspec = ['%0',num2str(subtomo_digits),'d'];

% Expected subtomosize (bytes)
n_pix = (boxsize^3);
switch format
    case 'em'
        subtomo_size = 512 + (n_pix*4);   % Header + 32bits per voxel
        fmt = 'em';
    case 'mrc'
        subtomo_size = 1024 + (n_pix*4);  % Header + 32bits per voxel
        fmt = 'mrc';
    case 'mrc16'
        subtomo_size = 1024 + (n_pix*2);  % Header + 16bits per voxel
        fmt = 'mrc';
    case 'mrc8'
        subtomo_size = 1024 + n_pix;      % Header + 8bits per voxel
        fmt = 'mrc';
end


%% Extract subtomos

for i  = 1:n_motls
    
    % Initialize subtomogram
    subtomo = zeros(extract_size,extract_size,extract_size);
    
    % Extract subtomo
    ext_subtomo = tomogram(coords.es(1,i):coords.ee(1,i),coords.es(2,i):coords.ee(2,i),coords.es(3,i):coords.ee(3,i));
    ext_subtomo = double(ext_subtomo);
    
    % Normalize
    m = mean(ext_subtomo(:));
    s = std(ext_subtomo(:));
    ext_subtomo = (ext_subtomo-m)./s;
    
    % Paste in box
    subtomo(coords.ss(1,i):coords.se(1,i),coords.ss(2,i):coords.se(2,i),coords.ss(3,i):coords.se(3,i)) = ext_subtomo;
    
    % Rescale subtomo
    if rescale
        subtomo = rescale_subtomo(subtomo,boxsize,f);
    end
    
    % Format conversion
    switch format
        case {'em','mrc'}
            subtomo = single(subtomo);
        case 'mrc16'
            subtomo = sg_rescale_to_16bit(subtomo);
        case 'mrc8'
            subtomo = sg_rescale_to_8bit(subtomo);
    end
    
    % Recalculate stats
    stats(i,2) = mean(subtomo(:));
    stats(i,3) = std(single(subtomo(:)));
    
    % Write subtomo
    switch fmt
        case 'em'
            name = [subtomo_name,'_',num2str(motl(i).subtomo_num,sfmtspec),'.em'];
            sg_emwrite(name,subtomo);
        case 'mrc'
            name = [subtomo_name,'_',num2str(motl(i).subtomo_num,sfmtspec),'.mrc'];
            sg_mrcwrite(name,subtomo,[],'pixelsize',pixelsize);
    end
        
    
    
    % Check size
    d = dir(name);
    if d.bytes ~= subtomo_size
        error(['Error extracting subtomogram ',num2str(motl(i).subtomo_num),'!!! Size is NOT as expected!!!']);
    end
    
end

    
    








