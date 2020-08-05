function compile_pca_timings(paramfilename,p,o,idx,mode)
%% compile_pca_timings
% Read and sum timing files from a given PCA step(idx).
%
% WW 09-2018

%% Compile timings

% Concatenate and read timing files
split_names = [p(idx).rootdir,'/',o.tempdir,'/timer_',mode,'_',num2str(p(idx).iteration),'_*'];
cat_name = [p(idx).rootdir,'/',o.tempdir,'/timer_',mode];
system(['cat ',split_names,' > ',cat_name]);
timings = dlmread(cat_name);

% Sum timings and convert to hours
cpu_hours = sum(timings)/3600;

% Generate timing line
star_name = [p(idx).rootdir,'/',o.metadir,'/pca_timings.star'];
timing_struct = struct('PCA_step',mode,...
                 'paramfilename',paramfilename,...
                 'param_idx', idx,...
                 'cpu_hours',cpu_hours);
             
% Append file
if exist(star_name,'file')
    old_timings = stopgap_star_read(star_name,true,[],'stopgap_pca_timings');
    timing_struct = cat(1,old_timings,timing_struct);
end

% Write output
stopgap_star_write(timing_struct, star_name, 'stopgap_pca_timings', [], 4, 2);


end

