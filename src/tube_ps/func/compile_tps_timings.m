function compile_tps_timings(p,o,idx,mode)
%% compile_tps_timings
% Read and sum timing files from a given iteration.
%
% WW 10-2022

%% Compile core timings

% Concatenate and read timing files
split_names = [p(idx).rootdir,'/',o.tempdir,'/timer_',mode,'_',num2str(idx),'_*'];
cat_name = [p(idx).rootdir,'/',o.tempdir,'/timer_',mode,'_',num2str(idx)];
system(['cat ',split_names,' > ',cat_name]);
timings = dlmread(cat_name);

% Sum timings and convert to hours
cpu_hours = sum(timings)/3600;

% Generate timing line
star_name = [p(idx).rootdir,'/',o.metadir,'/tps_timings.star'];
timing_struct = struct('index',idx,...
                 'tps_step',mode,...
                 'motl_name',p(idx).motl_name,...
                 'ps_name',p(idx).ps_name,...
                 'cpu_hours',cpu_hours);
             
% Append file
if exist(star_name,'file')
    old_timings = read_tps_timings(star_name);
    timing_struct = cat(1,old_timings,timing_struct);
end

% Write output
stopgap_star_write(timing_struct, star_name, 'stopgap_tps_timings', [], 4, 2);


end

