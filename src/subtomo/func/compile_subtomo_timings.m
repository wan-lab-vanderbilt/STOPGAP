function compile_subtomo_timings(p,o,idx,mode)
%% compile_subtomo_timings
% Read and sum timing files from a given iteration.
%
% WW 09-2018

%% Compile core timings

% Concatenate and read timing files
split_names = [p(idx).rootdir,'/',o.tempdir,'/timer_',mode,'_',num2str(p(idx).iteration),'_*'];
cat_name = [p(idx).rootdir,'/',o.tempdir,'/timer_',mode,'_',num2str(p(idx).iteration)];
system(['cat ',split_names,' > ',cat_name]);
timings = dlmread(cat_name);

% Sum timings and convert to hours
cpu_hours = sum(timings)/3600;

% Generate timing line
star_name = [p(idx).rootdir,'/',o.metadir,'/subtomo_timings.star'];
timing_struct = struct('iteration',p(idx).iteration,...
                 'subtomo_mode',p(idx).subtomo_mode,...
                 'subtomo_step',mode,...
                 'motl_name',p(idx).motl_name,...
                 'ref_name',p(idx).ref_name,...
                 'cpu_hours',cpu_hours);
             
% Append file
if exist(star_name,'file')
    old_timings = read_subtomo_timings(star_name);
    timing_struct = cat(1,old_timings,timing_struct);
end

% Write output
stopgap_star_write(timing_struct, star_name, 'stopgap_subtomo_timings', [], 4, 2);

%% Compile subtomo alignment timings

if strcmp(mode,'ali')
   
%     % Initialize timing array
%     time_array = zeros(o.n_ali_motls,10,'single');
% 
%     % Compile array
%     for i = 1:o.n_cores
%        time_array = time_array + csvread([p(idx).rootdir,o.tempdir,'ali_timings_',num2str(p(idx).iteration+1),'_',num2str(i),'.csv']); 
%     end

    % Check for subset processing
    subset = false;
    if sg_check_param(p(idx),'subset')
        if p(idx).subset < 100
            subset = true;
        end
    end
    
    % Initialize timing array
    if subset
        time_array = zeros(o.n_rand_motls,10,'single');
    else
        time_array = zeros(o.n_motls,10,'single');
    end
    
    % Compile array
    c = 1;  % Counter
    % Get list of .csv files
    d = dir([p(idx).rootdir,o.tempdir,'ali_timings_',num2str(p(idx).iteration+1),'_*.csv']);
    for i = 1:numel(d)
        % Check for empty file
        if d(i).bytes ~= 0
        % Read in time file
%         temp_time = csvread([p(idx).rootdir,o.tempdir,'ali_timings_',num2str(p(idx).iteration+1),'_',num2str(i),'.csv']);
        temp_time = csvread([d(i).folder,'/',d(i).name]);
        % Number of motls
        n_motls = size(temp_time,1);
        % Store times
        time_array(c:(c+n_motls-1),:) = temp_time;
        % Increment counter
        c = c + n_motls;
        end
    end
    
    % Sort array by procnum, packet ID, motl_num
    time_array = sortrows(time_array,[1,4,5]);
    
    % Write output
    csvwrite([p(idx).rootdir,'/',o.metadir,'/ali_timings_',num2str(p(idx).iteration+1),'.csv'],time_array);
    
    
end




end

