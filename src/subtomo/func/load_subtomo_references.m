function o = load_subtomo_references(p,o,s,idx)
%% load_subtomo_references
% Load references for subtomogram averaging.
%
% WW 06-2019

%% Parse reference list

% Parse mode
mode = strsplit(p(idx).subtomo_mode,'_');

% Parse reference classes
reflist_classes = reshape([o.reflist.class],[],1);

% Check reflist against motivelist
n_ref = numel(o.reflist);
switch mode{2}
    
    case 'singleref'
        if n_ref > 1
            if ~any(reflist_classes == 1)
                error([s.nn,'ACHTUNG!!! Singleref mode requires a reference with class = 1 !!!']);
            end
        end
        
    otherwise
        
        % Check for missing classes
        diff = setdiff(o.classes,reflist_classes);    % Extraneous classes are allowed
        if ~isempty(diff)
            error([s.nn,'ACHTUNG!!! reflist is missing classes: ',num2str(reshape(diff,1,[])),'!!!']);
        end
end


% Parse reference indices
switch mode{2}
    case 'singleref'
        if n_ref == 1
            ref_idx = 1;
        else
            ref_idx = reflist_classes == 1;
        end
    otherwise
        ref_idx = zeros(o.n_classes,1);
        for i = 1:o.n_classes
            ref_idx(i) = find(reflist_classes == o.classes(i));
        end
end

%% Load references

% Parse initialization size
if sg_check_param(o,'fcrop')
    init_size = o.full_boxsize;
else
    init_size = o.boxsize;
end

% Initialize reference struct
o.ref = struct('A',repmat({zeros(init_size,'single')},o.n_classes,1),'A_name',repmat({[]},o.n_classes,1),'B',repmat({zeros(init_size,'single')},o.n_classes,1),'B_name',repmat({[]},o.n_classes,1));
        
% Load A and B references
for h = 1:2
    
    % Load based on mode
    switch mode{2}
        case 'singleref'
            
            % Store reference name
            o.ref(1).([char(64+h),'_name']) = [o.reflist(ref_idx).ref_name,'_',char(64+h)];
            
            % Check for refinement index
            if numel(mode)==3
                ref_name = [o.refdir,'/',o.reflist(ref_idx).ref_name,'_',char(64+h),'_',mode{3},s.vol_ext];
            else
                ref_name = [o.refdir,'/',o.reflist(ref_idx).ref_name,'_',char(64+h),'_',num2str(p(idx).iteration),s.vol_ext];
            end
            
            % Read reference
            o.ref(1).(char(64+h)) = read_vol(s,p(idx).rootdir,ref_name);

            % Fourier crop
            if o.fcrop
                o.ref(1).(char(64+h)) = fourier_crop_volume(o.ref(1).(char(64+h)),o.f_idx);
            end

            % Apply symmetry
            if sg_check_param(p(idx),'symmetry')
                o.ref(1).(char(64+h)) = sg_symmetrize_volume(o.ref(1).(char(64+h)),o.reflist(ref_idx).symmetry);
            end
            


            
        otherwise

            % Loop through classes
            for i = 1:o.n_classes     
                
                % Store reference name
                o.ref(i).([char(64+h),'_name']) = [o.reflist(ref_idx(i)).ref_name,'_',char(64+h),'_',num2str(o.classes(i))];
                
                % Check for refinement index
                if numel(mode)==3
                    ref_name = [o.refdir,'/',o.reflist(ref_idx(i)).ref_name,'_',char(64+h),'_',mode{3},'_',num2str(o.classes(i)),s.vol_ext];
                else
                    ref_name = [o.refdir,'/',o.reflist(ref_idx(i)).ref_name,'_',char(64+h),'_',num2str(p(idx).iteration),'_',num2str(o.classes(i)),s.vol_ext];
                end
                
                % Read reference
                o.ref(i).(char(64+h)) = read_vol(s,p(idx).rootdir,ref_name);
                
                % Fourier crop
                if o.fcrop
                    o.ref(i).(char(64+h)) = fourier_crop_volume(o.ref(i).(char(64+h)),o.f_idx);
                end
                
                % Apply symmetry
                if sg_check_param(p(idx),'symmetry')
                    o.ref(i).(char(64+h)) = sg_symmetrize_volume(o.ref(i).(char(64+h)),o.reflist(ref_idx(i)).symmetry);
                end
                

            end

    end
end
    


%% Load masks

o = load_subtomo_masks(p,o,s,idx,mode);


%% Apply FOM

for i = 1:o.n_classes
    
    % Calculate mask-corrected fsc
    corr_fsc = calculate_fsc(o.ref(i).A,o.ref(i).B,o.mask{i},'C1',s.fsc_fourier_cutoff,s.fsc_n_repeats);    % Volumes are already symmetrized
    
    % Calculate Figure-Of-Merit
    Cref = real(sqrt((2.*abs(corr_fsc))./(1+abs(corr_fsc))));
    Cref_filt = ifftshift(tom_sph2cart(repmat(Cref',[1, (o.boxsize(1)*2), (o.boxsize(1))])));
     
%     % Interpolate filter
%     f_1d = (0:floor(o.boxsize(1)/2)-1)./floor(o.boxsize(1)/2);
%     F = griddedInterpolant(f_1d,Cref,'cubic','none');
%     temp_freq = sg_frequencyarray(o.ref(i).A,0.5);
%     Cref_filt = ifftshift(reshape(F(temp_freq(:)),o.boxsize));
%     clear f_1d F temp_freq Cref
    
    % Apply filter
    for j = 1:2
        o.ref(i).(char(64+j)) = real(ifftn(fftn(o.ref(i).(char(64+j))).*Cref_filt));
    end
    
end
    




%% Check halfset mode

if strcmp(o.halfset_mode,'single') || sg_check_param(p(idx),'ignore_halfsets')
    for i = 1:o.n_classes
        temp_ref = (o.ref(i).A + o.ref(i).B)./2;
        for j = 1:2
            o.ref(i).(char(64+j)) = temp_ref;
        end
        clear temp_ref
    end
end


%% Appply laplacian

if sg_check_param(p(idx),'apply_laplacian')
    for i = 1:o.n_classes
        for j = 1:2
            o.ref(i).(char(64+j)) = del2(o.ref(i).(char(64+j)));
        end
    end
end










