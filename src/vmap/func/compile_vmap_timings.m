function compile_vmap_timings(p,o,idx,mode)
%% compile_vmap_timings
% Read and sum timing files from a given iteration.
%
% WW 05-2019

%% Compile timings

% Concatenate and read timing files
split_names = [p(idx).rootdir,'/',o.tempdir,'/timer_',mode,'_',num2str(p(idx).iteration),'_*'];
cat_name = [p(idx).rootdir,'/',o.tempdir,'/timer_',mode,'_',num2str(p(idx).iteration)];
system(['cat ',split_names,' > ',cat_name]);
timings = dlmread(cat_name);

% Sum timings and convert to hours
cpu_hours = sum(timings)/3600;

% Generate timing line
star_name = [p(idx).rootdir,'/',o.metadir,'/vmap_timings.star'];
timing_struct = struct('iteration',p(idx).iteration,...
                 'motl_name',p(idx).motl_name,...
                 'ref_name',p(idx).ref_name,...
                 'vmap_mode',p(idx).vmap_mode,...
                 'step',mode,...
                 'cpu_hours',cpu_hours);
             
% Append file
if exist(star_name,'file')
    old_timings = sg_read_vmap_timing_star(star_name);
    timing_struct = cat(1,old_timings,timing_struct);
end

% Write output
stopgap_star_write(timing_struct, star_name, 'stopgap_vmap_timings', [], 4, 2);


end

