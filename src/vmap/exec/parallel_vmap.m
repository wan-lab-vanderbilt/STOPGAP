function parallel_vmap(p,o,s,idx)
%%
% Parallel processing of variance maps from a given input reference and
% it's constitutent subtomograms. 
%
% WW 05-2019

%% Intialize volumes for averaging

% Initialize filters
f = initialize_subtomo_filters(p,o,s,idx,'avg');

% Parse threshold
if sg_check_param(p(idx),'score_thresh')
    score_thresh = p(idx).score_thresh;
else
    score_thresh = 0;
end

%% Calculate variances

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
    v = initialize_vmap_volumes(o);

    for i = o.p_avg_start:o.p_avg_end

        % Parse motl
        motl_idx = [o.allmotl.motl_idx] == o.motl_idx(i);
        motl = parse_motl(o.allmotl,motl_idx);


        % Determine motl to average
        [top_score,avg_idx] = max(motl.score);

        
        % Check class
        switch p(idx).vmap_mode
            case 'singleref'
                class_check = true;
            otherwise
                class_check = motl.class(avg_idx) == class;
        end
        
         % Check class
        if class_check         % Nest the loops for the process counter            

            
            % Average based on scoring threshold
            if top_score >= score_thresh

                
                %%%%% Initialize %%%%%
                
                % Parse parameters
                x = motl.x_shift;
                y = motl.y_shift;
                z = motl.z_shift;
                phi = motl.phi;
                psi = motl.psi;
                the = motl.the;


                % Refresh filters
                f = refresh_subtomo_filters(p,o,s,f,idx,motl,'avg');
                

                % Read subtomogram
                subtomo_num = motl.subtomo_num(1);
                subtomo_name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(subtomo_num),s.vol_ext];
                try
                    subtomo = read_vol(s,p(idx).rootdir,subtomo_name);
                catch
                    error([s.nn,'ACHTUNG!!! Error reading file ',subtomo_name,'!!!']);
                end

                
                
                %%%%% Prepare subtomo %%%%%
                
                % Rotate volumes
                subtomo = sg_rotate_vol(sg_shift_vol(subtomo,[-x,-y,-z]),[-psi,-phi,-the],[],'cubic');
                r_pfilt = sg_rotate_vol(f.pfilt,[-psi,-phi,-the],[],'cubic');
                r_rfilt = sg_rotate_vol(f.rfilt,[-psi,-phi,-the],[],'cubic');


                % Filter subtomo
                subtomo = real(ifftn(fftn(subtomo).*ifftshift(r_pfilt).*o.bpf));
                
                % Normalize under mask
                subtomo(o.m_idx) = (subtomo(o.m_idx) - mean(subtomo(o.m_idx).*o.m_val))./std(subtomo(o.m_idx).*o.m_val);
                
                % Split amplitudes and phase
                subtomo = fftn(subtomo);
                s_amp = abs(subtomo);
                s_phase = exp(1i.*angle(subtomo));
                clear subtomo r_pfilt
                
                
                %%%%% Prepare reference
                
                % Filter reference
                ref = real(ifftn(o.ref{c}.*ifftshift(r_rfilt).*o.bpf));
 
                % Normalize under mask
                ref(o.m_idx) = (ref(o.m_idx) - mean(ref(o.m_idx).*o.m_val))./std(ref(o.m_idx).*o.m_val);
                
                % Parse phases
                ref = exp(1i.*angle(fftn(ref)));
                
                
                %%%%% Calculate phase difference %%%%%
                
                % Calculate phase difference
                d_phase = ref - s_phase;
                
                % Sum squared difference
                v.vmap = v.vmap + (real(ifftn(s_amp.*d_phase)).^2);
                

                % Add Fourier weight
                v.wei = v.wei + r_rfilt;  % Non-binary weights blur the map

                
                clear r_rfilt s_amp s_phase d_phase
                
            end
        end
        
        % Increment completion counter
        [pc,rt_str] = progress_counter(pc,'count',n_part,s.counter_pct);
        if ~isempty(rt_str)
            disp([s.nn,'Job progress: ',num2str(pc.c),' out of ',num2str(n_part),[' averaged for class ',num2str(class),'... '],rt_str]);
        end

    end
    
    % Write out volumes
    disp([s.nn,'Averaging of class ',num2str(o.classes(c)),' complete!!! Writing outputs...']);       
          
        % Output names
        switch p(idx).vmap_mode
            case 'singleref'
                vmap_name = [o.tempdir,'/vmap_',num2str(o.procnum),s.vol_ext];
                wei_name = [o.tempdir,'/wei_',num2str(o.procnum),s.vol_ext];
            otherwise
                vmap_name = [o.tempdir,'/vmap_',num2str(class),'_',num2str(o.procnum),s.vol_ext];
                 wei_name = [o.tempdir,'/wei_',num2str(class),'_',num2str(o.procnum),s.vol_ext];
        end
        
        % Write volumes
        write_vol(s,o,p(idx).rootdir,vmap_name,v.vmap);
        write_vol(s,o,p(idx).rootdir,wei_name,v.wei);

end
    

        
    
%% Write checkjob

% Write completion
system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_p_vmap_',num2str(o.procnum)]);













