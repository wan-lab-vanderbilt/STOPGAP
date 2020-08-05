function o = read_random_seed(p,o,s,idx)
%% read_random_seed
% Read a random seed file from the raw directory. 
%
% WW 04-2019

%% Read seed

% Set seed name and path
seed_path = [p(idx).rootdir,'/',o.metadir,'/'];
seed_name = ['rseed_',num2str(o.seed_idx)];


if (o.procnum == 1) && ~exist([seed_path,seed_name],'file')
    disp([s.nn,'Generating random seed for iteration ',num2str(o.seed_idx),'!!!']);
    
    % Generate seed
    rng('shuffle');
    o.rseed = round(rand(1)*(2^32));
    
    % Write seed    
    fid =fopen([seed_path,seed_name,'_temp'],'w');
    fprintf(fid,'%s',num2str(o.rseed));
    fclose(fid);
    movefile([seed_path,seed_name,'_temp'],[seed_path,seed_name]);
    
else
    
    % Read seed
    wait_for_it(seed_path,seed_name,s.wait_time);
    o.rseed = dlmread([seed_path,seed_name]);

end


