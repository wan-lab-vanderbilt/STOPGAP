function o = extract_initialize_tomolist(p,o,s,idx)
%% extract_initialize_tomolist
% A function to initialize a tomogram list for subtomogram extraction. If a
% tomogram list is supplied, it will be read in. If only a tomogram
% directory is provided, a tomolist will be generated.
%
% WW 04-2021

%% Generate tomolist

% Check for tomolist
if sg_check_param(p(idx),'tomolist_name')
    disp([s.cn,'Reading tomolist...']);
    
    % Read tomolist
    tomolist_name = [o.rootdir,'/',o.listdir,p(idx).tomolist_name];
    o.tomolist = read_extract_tomolist(tomolist_name);
    
else
    disp([s.cn,'Generating tomolist...']);
    
    % Initialize tomolist
    o.tomolist = struct();
    o.tomolist.tomo_num = o.tomo_num;
    o.tomolist.tomo_name = cell(o.n_tomos,1);
    
    % Fill tomolist
    for i = 1:o.n_tomos
        o.tomolist.tomo_name{i} = [p(idx).tomodir,'/',s.tomo_num(o.tomo_num(i)),'.',s.tomo_ext];
    end
end



