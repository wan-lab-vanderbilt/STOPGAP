function complete_subtomo_align(rootdir,paramfilename,p,o,s,idx)
%% complete_subtomo_align
% A function for completing a round of subtomogram alignment. First the
% script waits for all subtomograms to be aligned. It then generates a new
% motivelist and writes a completion file to move all cores to the next
% step. 
%
% WW 07-2018

%% Wait for alignment to finish
    
% Wait until align completion
wait_for_them([p(idx).rootdir,'/',o.commdir],'sg_ali',o.n_cores,s.wait_time);


%% Generate new motl, update param, write completion
disp([s.nn,'Subtomogram alignment complete...']);


% Generate complete motl
assemble_new_motl(p,o,s,idx);

% Compile time
compile_subtomo_timings(p,o,idx,'ali');

% Update param file
disp([s.nn,'Updating parameter file...']);
[p,idx] = update_subtomo_param(s ,rootdir, paramfilename, p(idx).iteration, p(idx).subtomo_mode, 'ali');

% Write completion file
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'sg_p_avg_*']);                 % Prevents overrun at next step...
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'sg_f_avg_*']);                 % Prevents overrun at next step...
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/complete_stopgap_p_avg']);    % Prevents overrun at next step...
system(['touch ',p(idx).rootdir,'/',o.commdir,'/complete_stopgap_ali']);
disp([s.nn,'Subtomogram alignment complete!!!']);

