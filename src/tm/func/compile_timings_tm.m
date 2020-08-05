function compile_timings_tm(p,o,idx,mode)
%% compile_timings_tm
% Read and sum timing files from a given iteration.
%
% WW 09-2018

%% Compile timings

% Concatenate and read timing files
split_names = [p(idx).rootdir,'/',o.tempdir,'/timer_',mode,'_',num2str(p(idx).tomo_num),'_*'];
cat_name = [p(idx).rootdir,'/',o.tempdir,'/timer_',mode,'_',num2str(p(idx).tomo_num)];
system(['cat ',split_names,' > ',cat_name]);
timings = dlmread(cat_name);

% Sum timings and convert to hours
cpu_hours = sum(timings)/3600;
time_per_core = mean(timings)/3600;
std_per_core = std(timings)/3600;


% Generate timing line
star_name = [p(idx).rootdir,'/',o.metadir,'/tm_timings.star'];
timing_struct = struct('tomo_num',p(idx).tomo_num,...
                       'tlist_name',p(idx).tlist_name,...                 
                       'tm_step',mode,...
                       'cpu_hours',cpu_hours,...
                       'time_per_core',time_per_core,...
                       'std_per_core',std_per_core);
             
% Append file
if exist(star_name,'file')
    old_timings = sg_read_tm_timing_star(star_name);
    timing_struct = cat(1,old_timings,timing_struct);
end

% Write output
stopgap_star_write(timing_struct, star_name, 'stopgap_tm_timings', [], 4, 2);




end

