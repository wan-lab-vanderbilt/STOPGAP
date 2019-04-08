function stopgap_extract_subtomograms(tomo_folder, tomo_digits, tomo_row, subtomoname, subtomo_digits, allmotlfilename, subtomosize, statsname, checkjobdir, procnum)
%% stopgap_extract_subtomograms
% A function for extracting subtomograms from tomogams in parallel. 
%
% Parallelization is accomplished by checkjob files that indicate when a
% tomogram extraction is started or completed. If a tomogram is started, it
% will move on to the next one. 
%
% This script also writes out the statistics for each subtomogram from
% tom_dev. There are writen out as the subtomo_stats_tomonum.csv files in 
% their respective subtomogram averaging folders. 
%
% Columns of the statistics arrays are as follows:
% Subtomo Num, Mean, Max, Min, Standard Deviation, Variance
%
% WW 07-2017


%% Evaluate numeric inputs
disp(['Intializing node ',procnum,' for subtomogram extraction!']);

if (ischar(tomo_digits)); tomo_digits=eval(tomo_digits); end
if (ischar(tomo_row)); tomo_row=eval(tomo_row); end
if (ischar(subtomo_digits)); subtomo_digits=eval(subtomo_digits); end
if (ischar(subtomosize)); subtomosize=eval(subtomosize); end
if (ischar(procnum)); procnum=eval(procnum); end


%% Initialize

% Read in allmotl
try
    allmotl = tom_emread(allmotlfilename); allmotl = allmotl.Value;
catch
    error(['Achtung! Error reading ',allmotlfilename]);
end


% Determine tomogram numbers
tomos = unique(allmotl(tomo_row,:));
n_tomos = size(tomos,2);


% Check that stat directory exists
[spath, ~, ~] = fileparts(statsname);
if ~exist(spath,'dir')
    mkdir(spath);
end

% Checkjob filenames
checkstartname = [checkjobdir,'/start/tomo_'];
checkdonename = [checkjobdir,'/done/tomo_'];


%% Write out subtomograms

% Loop through each tomo in the allmotl
for i = procnum:n_tomos
    
    % Tomogram string
    tomo_str = sprintf(['%0',num2str(tomo_digits),'d'],tomos(i));
    
    % Check if it's not already being processed
    if ~exist([checkstartname,tomo_str],'file')
        disp(['Node ',num2str(procnum),' starting on tomogram: ',tomo_str]);

        
        % Create start file
        system(['touch ',checkjobdir,'/start/tomo_',tomo_str]);        
        
        
        % Parse motls
        temp_motl = allmotl(:, allmotl(tomo_row,:)==tomos(i));

        
        % Read in the tomogram
        tomo_name = [tomo_folder,'/',tomo_str,'.rec'];
        disp(['Reading tomogram: ',tomo_name]);
        try
            vol = tom_mrcread(tomo_name);
        catch
            error(['Achtung! Error reading tomogram: ',tomo_name]);
        end

        % Extract the subtomograms for each tomogram
        disp('Extracting subtomograms!!');        
        stats = will_batch_extract_subtomos_noread_stats2(subtomosize,vol.Value,temp_motl,subtomoname,subtomo_digits);
        
        
        % Write out stats
        csvwrite([statsname,tomo_str,'.csv'],stats);
        
        % Cleanup
        clear vol
        disp(['Tomogram: ',tomo_str,' extracted!!']);
        system(['touch ',checkdonename,tomo_str]);

        
    end
    
end
