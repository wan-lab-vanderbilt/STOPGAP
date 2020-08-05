function o = vmap_load_references(p,o,s,idx)
%% vmap_load_references
% Load references for performing a variance map calculation.
%
% WW 05-2019

%% Load references

% Load references
switch p(idx).vmap_mode
    
    case 'singleref'
        
        % Initalize cell
        o.ref = cell(1,1);
        
        % Read references
        ref_A_name = [o.refdir,'/',p(idx).ref_name,'_A_',num2str(p(idx).iteration),s.vol_ext];
        o.ref{1} = read_vol(s,p(idx).rootdir,ref_A_name);
        ref_B_name = [o.refdir,'/',p(idx).ref_name,'_B_',num2str(p(idx).iteration),s.vol_ext];
        o.ref{1} = (o.ref{1} + read_vol(s,p(idx).rootdir,ref_B_name))./2;
        
        % Apply symmetry
        o.ref{1} = sg_symmetrize_volume(o.ref{1},p(idx).symmetry);
        
        % Store FT
        o.ref{1} = fftn(o.ref{1});
        
%         % Normalize under mask
%         o.ref{1}(o.m_idx) = (o.ref{1}(o.m_idx) - mean(o.ref{1}(o.m_idx).*o.m_val))./std(o.ref{1}(o.m_idx).*o.m_val);
%         
%         % Store phases
%         o.ref{1} = exp(1i.*angle(fftn(o.ref{1})));
        
        
    case 'multiclass'
        
        % Initalize cell
        o.ref = cell(o.n_classes,1);
        
        for i = 1:o.n_classes
            
            % Read references
            ref_A_name = [o.refdir,'/',p(idx).ref_name,'_A_',num2str(p(idx).iteration),'_',num2str(o.classes(i)),s.vol_ext];
            o.ref{i} = read_vol(s,p(idx).rootdir,ref_A_name);
            ref_B_name = [o.refdir,'/',p(idx).ref_name,'_B_',num2str(p(idx).iteration),'_',num2str(o.classes(i)),s.vol_ext];
            o.ref{i} = (o.ref{i} + read_vol(s,p(idx).rootdir,ref_B_name))./2;
            
            % Apply symmetry
            o.ref{i} = sg_symmetrize_volume(o.ref{i},p(idx).symmetry);
            
            % Store FT
            o.ref{i} = fftn(o.ref{i});
            
%             % Normalize under mask
%             o.ref{1}(o.m_idx) = (o.ref{i}(o.m_idx) - mean(o.ref{i}(o.m_idx).*o.m_val))./std(o.ref{i}(o.m_idx).*o.m_val);
%             
%             % Store phases
%             o.ref{i} = exp(1i.*angle(fftn(o.ref{i})));
            
        end
        
end



