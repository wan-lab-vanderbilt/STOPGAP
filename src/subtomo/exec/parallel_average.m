function parallel_average(p,o,s,idx)
%% parallel_average
% A function to generate a weighted average in parallel. The
% parallelization is performed in two steps: a parallel step where a
% number of cores generate partial averages, and a final step that averages
% the parallel averages. 
%
% WW 05-2018


%% Determine parameters and intialize volumes for averaging
mode = strsplit(p(idx).subtomo_mode,'_');

% Check for spectral mask
if sg_check_param(o,'specmask')
    % Check supersampling
    if o.avg_ss > 1
        o.specmask = sg_rescale_volume_realspace(o.specmask,o.avg_ss);
    end
end

% Initialize filters
f = initialize_subtomo_filters(p,o,s,idx,'avg');


% Parse threshold
if sg_check_param(p(idx),'score_thresh')
    score_thresh = p(idx).score_thresh;
else
    score_thresh = 0;
end


%% Sum volumes

% Number of particles to average
n_part = o.p_avg_end - o.p_avg_start + 1;


% Loop throught classes
for c = 1:o.n_classes
    
    % Initialize counter
    pc = struct();
    pc = progress_counter(pc,'init',n_part,s.counter_pct);
    
    % Current class
    class = o.classes(c);
    
    % Initialize volumes
    v = initialize_p_avg_volumes(p,o,s,idx,mode,class);
    
    
    % Loop throught particles
    for i = o.p_avg_start:o.p_avg_end


        % Parse out motls for a single subtomogram
        if o.partavg
            motl_idx = o.allmotl.motl_idx == o.rand_motl(i);
        else
            motl_idx = o.allmotl.motl_idx == o.motl_idx(i);
        end
        motl = parse_motl(o.allmotl,motl_idx);


        % Determine motl to average
        [top_score,avg_idx] = max(motl.score);
        
        
        % Check class
        switch mode{2}
            case 'singleref'
                class_check = true;
            otherwise
                class_check = motl.class(avg_idx) == class;
        end
        
        if class_check        % Nest the loops for the process counter            

            
            % Average based on scoring threshold
            if top_score >= score_thresh

                
                
                %%%%% Prepare subtomogram %%%%%
                
                % Read subtomogram
                subtomo_num = motl.subtomo_num(1);
                subtomo_name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(subtomo_num),s.vol_ext];
                try
                    subtomo = read_vol(s,p(idx).rootdir,subtomo_name);
                catch
                    error([s.nn,'ACHTUNG!!! Error reading file ',subtomo_name,'!!!']);
                end
                subtomo = sg_fourier_rescale_volume(subtomo,o.avg_ss);  % Upscale volume

                
                % Refresh filters
                f = refresh_subtomo_filters(p,o,s,f,idx,motl,'avg');


                % Parse parameters
                x = motl.x_shift(avg_idx)*o.avg_ss;
                y = motl.y_shift(avg_idx)*o.avg_ss;
                z = motl.z_shift(avg_idx)*o.avg_ss;
                phi = motl.phi(avg_idx);
                psi = motl.psi(avg_idx);
                the = motl.the(avg_idx);

                
                % Filter and normalize
                subtomo = real(ifftn(fftn(subtomo).*ifftshift(f.pfilt)));  % Filter subtomo
                subtomo = (subtomo - mean(subtomo(:)))./std(subtomo(:));


                % Rotate subtomogram
                subtomo = sg_rotate_vol(sg_shift_vol(subtomo,[-x,-y,-z]),[-psi,-phi,-the],[],'cubic');

                
                
                
                
                %%%%% Sum  volumes %%%%%
                
                % Parse halfset        
                if strcmp(o.halfset_mode,'single')
                    halfset = o.rand_halfset{[o.rand_halfset{:,1}]==motl.motl_idx(avg_idx),2};
                else
                    halfset = motl.halfset{1};
                end

                % Sum subtomogram
                vol_name = get_p_avg_vol_name('ref',o.reflist,halfset,mode,motl.class(avg_idx));
                v.(vol_name) = v.(vol_name) + subtomo;


                % Calculate and sum ps
                if sg_check_param(p(idx),'ps_name')
                    temp_ps = abs(fftn(subtomo.*o.specmask));
                    vol_name = get_p_avg_vol_name('ps',o.reflist,halfset,mode,motl.class(avg_idx));
                    v.(vol_name) = v.(vol_name) + temp_ps;            
                end
                clear subtomo temp_ps


                % Rotate and sum weighting filter
                vol_name = get_p_avg_vol_name('wfilt',o.reflist,halfset,mode,motl.class(avg_idx));
                v.(vol_name) = v.(vol_name) + sg_rotate_vol(f.rfilt,[-psi,-phi,-the],[],'cubic');




            end
        end

        % Increment completion counter
        [pc,rt_str] = progress_counter(pc,'count',n_part,s.counter_pct);
        if ~isempty(rt_str)
            disp([s.nn,'Job progress: ',num2str(pc.c),' out of ',num2str(n_part),[' averaged for class ',num2str(class),'... '],rt_str]);
        end
        
    end     % End loop through all motls
    
    % Write out volumes
    disp([s.nn,'Averaging of class ',num2str(o.classes(c)),' complete!!! Writing outputs...']);
    for i = 1:numel(v.all_names)        
        
        % Output name
        output_name = [o.tempdir,'/',v.all_names{i},'_',num2str(o.procnum),s.vol_ext];
        write_vol(s,o,p(idx).rootdir,output_name,v.(v.all_names{i}));

    end
    
end

        
%% Write outputs


% Write completion
system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_p_avg_',num2str(o.procnum)]);
disp([s.nn,'Parallel averaging completed!!!1!']);



end




