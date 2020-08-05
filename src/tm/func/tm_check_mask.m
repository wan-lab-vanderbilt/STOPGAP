function o = tm_check_mask(p,o,s,idx)
%% tm_check_mask
% Check a template-matching mask to find tiles that are masked out. Because
% the volume is split into even boxes, this script will only detect
% XY-planes that are masked out.
%
% WW 03-2019

%% Check mask
disp([s.nn,'Tomogram mask detected...']);

% Parse Z-index name
idx_name = ['tomo',num2str(p(idx).tomo_num),'_bounds.csv'];


% Determine Z-indices
if o.procnum == 1
    disp([s.nn,'Reading in tomogram mask...']);
    
    % Read mask
    mask = sg_mrcread(p(idx).tomo_mask_name);
        
    % Get projections    
    proj = cell(3,1);
    proj{1} = squeeze(sum(sum(mask,2),3));
    proj{2} = squeeze(sum(sum(mask,1),3));
    proj{3} = squeeze(sum(sum(mask,2),1));
    clear mask
    
    % Determine boundaries
    o.bounds = zeros(3,3);    % Column vectors
    for i = 1:3
        o.bounds(1,i) = find(proj{i} > 0,1,'first');      % Start
        o.bounds(2,i) = find(proj{i} > 0,1,'last');       % End
        o.bounds(3,i) = o.bounds(2,i) - o.bounds(1,i) + 1;    % Width
    end
    
    
    
    % Write boundary
    dlmwrite([p(idx).rootdir,'/',o.tempdir,'/',idx_name,'.temp'],o.bounds);
    system(['mv ',p(idx).rootdir,'/',o.tempdir,idx_name,'.temp ',p(idx).rootdir,'/',o.tempdir,'/',idx_name]);
    
    disp([s.nn,'Boundaries of tomogram mask determined!!!']);
    
    
else
    disp([s.nn,'Waiting for boundaries of tomogram mask...']);
    
    % Wait for indices
    wait_for_it([p(idx).rootdir,'/',o.tempdir],idx_name,s.wait_time);
    
    % Read indices
    o.bounds = dlmread([p(idx).rootdir,'/',o.tempdir,'/',idx_name]);
    disp([s.nn,'Boundaries of tomogram mask read...']);
    
end


    