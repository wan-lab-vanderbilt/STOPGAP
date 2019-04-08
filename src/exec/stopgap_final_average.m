function stopgap_final_average(p,o,idx)
%% stopgap_finall_average
% A function to generate a weighted average in parallel. The
% parallelization is performed in two steps: a parallel step where a
% number of cores generate partial averages, and a final step that averages
% the parallel averages. 
%
% WW 11-2017

%% Generate allmotl
global nn
disp([nn,'Starting final parallel averaging!!!']);
avg_modes = {'avg_singleref', 'avg_multiclass', 'avg_multiref'};

% Generate final motl based on mode
disp([nn,'Preparing final allmotl...']);
if any(strcmp(p(idx).subtomo_mode,avg_modes))    % For mode without alignment, use old allmotl
    disp([nn,'Using existing allmotl...']);
    
    % Parse allmotl
    allmotl = o.allmotl;
    
    % Iteration number
    iter = p(idx).iteration;
    
else    % Generate new partial allmotl following alignment
    disp([nn,'Concatenating new allmotl...']);
    
    % Iteration number
    iter = p(idx).iteration+1;
    
    % Read first parallel motl to determine size of third dimension
    motlname = [p(idx).allmotlname,'_',num2str(iter),'_1.em'];
    temp_motl = read_em(p(idx).rootdir,motlname);
    d3 = size(temp_motl,3);
    
    % Initialize new motl array
    allmotl = zeros(20,o.n_motls,d3);   % Old and new should have same number of motls
    allmotl(:,1:size(temp_motl,2),:) = temp_motl;
    
    % Add remaining motls
    c = size(temp_motl,2)+1;    % Counter for empty allmotl positions
    for i = 2:p(idx).n_cores_aver         
        % Read motl
        motlname = [p(idx).allmotlname,'_',num2str(iter),'_',num2str(i),'.em'];
        temp_motl = read_em(p(idx).rootdir,motlname);
        n_temp_motl = size(temp_motl,2);
        % Store motl
        allmotl(:,c:(c+n_temp_motl-1),:) = temp_motl;
        c = c+n_temp_motl;
    end
    
    % Write allmotl
    motl_name = [p(idx).allmotlname,'_',num2str(iter),'.em'];
    write_em(p(idx).rootdir,motl_name,allmotl);
    
end



%% Determine parameters for averaging

% Initialize some parameters depending on job type

switch p(idx).subtomo_mode
    case {'ali_singleref','avg_singleref'}
        disp([nn,'Performing single-reference averaging...']);
        
        % Determine subtomograms to averaging into a single reference
        if p(idx).iclass == 0
            total_motls = sum(allmotl(1,:) >= p(idx).threshold);
        else
            n_iclass = numel(p(idx).iclass);
            class_idx = logical(sum(repmat(allmotl(20,:),[n_iclass,1]) == repmat(p(idx).iclass',[1,o.n_motls]),1));
            thresh_idx = allmotl(1,:) >= p(idx).threshold;
            total_motls = sum(class_idx & thresh_idx);
        end     
        
        avg_class = 1; % Class to be averaged

    case {'ali_multiclass','avg_multiclass'}
        disp([nn,'Performing multiclass averaging...']);
        
        % Get classes
        if p(idx).iclass == 0
            classes = unique(allmotl(20,:));
        else
            classes = intersect(unique(allmotl(20,:)),p(idx).iclass);
        end
        n_classes = numel(classes);
        
        % Index of motls to average (dim1 = classes/refs, dim2 = motls in each class)
        class_idx = repmat(allmotl(20,:),[n_classes,1]) == repmat(classes',[1,o.n_motls]);
        thresh_idx = repmat((allmotl(1,:) >= p(idx).threshold),[n_classes,1]);
        total_motls = sum((class_idx&thresh_idx),2);
        
        avg_class = classes(o.procnum); % Class to be averaged

    case {'ali_multiref','avg_multiref'}
        disp([nn,'Performing multireference averaging...']);
        
        % Find top classes
        if p(idx).iclass == 0
            classes = squeeze(allmotl(20,1,:));
        else
            [classes, class_idx] = intersect(allmotl(20,1,:),p(idx).iclass); % Classes and indices along dim3
            allmotl = allmotl(:,:,class_idx);       % Remove non-included classes
        end        
        n_classes = numel(classes);
        
        % Get class indices
        top_cc = max(allmotl(1,:,:),[],3);  % Get top scores
        class_idx = (allmotl(1,:,:) == repmat(top_cc,[1,1,n_classes]));
        top_idx = permute(class_idx,[3,2,1]); % Indices for all class
        
        % Index of motls to average (dim1 = classes/refs, dim2 = motls in each class)
        total_motls = sum(top_idx,2); % Indices for iclass
        
        avg_class = classes(o.procnum); % Class to be averaged
        
        % Allmotl of only top classes
        top_motl = sortrows(reshape(allmotl(repmat(class_idx,[20,1,1])),[20,o.n_motls])',4)';
        top_name = [p(idx).allmotlname,'-topclasses_',num2str(iter),'.em'];
        write_em(p(idx).rootdir,top_name,top_motl);

end
    


%% Initialize volume parameters

% Calculate low pass filter, this filter takes out the last few high frequency pixels    
lowpass = ifftshift(tom_sphere([o.boxsize,o.boxsize,o.boxsize],(floor(o.boxsize/2)-3)));   % Without this, there are edge effects in final volume


% Initialize struct arrays
v = struct();   % For volumes

% Parse fields
[n, v_fields] = parse_refname_volumes(p,idx,'f_aver');

% Initialize for powerspectrum/amplitude calculation
if isfield(p(idx),'psfilename') || isfield(p(idx),'ampfilename')
    
    % Powerspectrum
    if ~strcmp(p(idx).psfilename,'none')        
        % Initialize powerspectrum volume
        v.ps = zeros(o.boxsize,o.boxsize,o.boxsize);
        % Check that binary wedge is calculated
        if ~any(strcmp(v_fields(1,:),'bin_wedge'))
            v_fields = cat(2,v_fields,{'bin_wedge';'bin_filt';'skip'});
            [ref_path,~,~] = fileparts(n.ref);
            n.bin_wedge = [ref_path,'/bin-wedge'];
        end
    end
    
    % Amplitude
    if ~strcmp(p(idx).ampfilename,'none')        
        % Initialize amplitude volume
        v.amp = zeros(o.boxsize,o.boxsize,o.boxsize);
        % Load psmask
        v.psmask = read_em(p(idx).rootdir,p(idx).psmaskname);
    end

    
end

% Number of volumes
n_vol = size(v_fields,2);
uvol = unique(v_fields);

% Initialize volumes
for i = 1:numel(uvol);
    v.(uvol{i}) = zeros(o.boxsize,o.boxsize,o.boxsize);
end


%% Finish summing volumes
% Loop through subtomograms
for i = 1:p(idx).n_cores_aver

   % Write volumes
    switch p(idx).subtomo_mode

        case {'ali_singleref','avg_singleref'}

            % Sum volumes
            for j = 1:n_vol
                name = [n.(v_fields{1,j}),'_',num2str(iter),'_',num2str(i),'.em'];
                v.(v_fields{1,j}) = v.(v_fields{1,j}) + read_em(p(idx).rootdir,name);                
            end
            
            % Sum powerspectra
            if isfield(v,'ps')
                name = [p(idx).psfilename,'_',num2str(iter),'_',num2str(i),'.em'];
                v.ps = v.ps + read_em(p(idx).rootdir,name);
            end


        otherwise

            % Summed subtomograms
            for j = 1:n_vol
                name = [n.(v_fields{1,j}),'_',num2str(iter),'-',num2str(avg_class),'_',num2str(i),'.em'];
                if exist(name,'file')
                    v.(v_fields{1,j}) = v.(v_fields{1,j}) + read_em(p(idx).rootdir,name);
                end
            end
            
            % Sum powerspectra
            if isfield(v,'ps')
                name = [p(idx).psfilename,'_',num2str(iter),'-',num2str(avg_class),'_',num2str(i),'.em'];
                if exist(name,'file')
                    v.ps = v.ps + read_em(p(idx).rootdir,name);
                end
            end

    end % End reading switch


end % End sum loop

% Divide sums to get averages
for j = 1:n_vol
    v.(v_fields{1,j}) = v.(v_fields{1,j})./total_motls(o.procnum);
end
if isfield(v,'ps')
    v.ps = v.ps./total_motls(o.procnum);
end

% Fourier transform reference
ft_ref = fftn(v.ref);

% Prepare filters
switch p(idx).fthresh
    case 100    % No filtering; set filters to ones
        
        for i = 2:n_vol            
            v.(v_fields{2,i}) = ones(o.boxsize,o.boxsize,o.boxsize);
        end

    otherwise
        
        for i = 2:n_vol
            % Threshold filter
            if p(idx).fthresh > 0                    
                [~,edges] = histcounts(v.(v_fields{1,i}),100);                    
                f_idx = v.(v_fields{1,i}) >= edges(p(idx).fthresh+1);
            else
                f_idx = v.(v_fields{1,i}) > 0;   % Prevent divide by zeros
            end
            
            % Generate filter
            v.(v_fields{2,i})(f_idx) = 1./v.(v_fields{1,i})(f_idx);
            v.(v_fields{2,i}) = ifftshift(v.(v_fields{2,i})).*lowpass;
            
        end
        
end % End prepare weighting filter

% Reweight references
for i = 2:n_vol
    if ~strcmp(v_fields{3,i},'skip')
        v.(v_fields{3,i}) = real(ifftn(ft_ref.*v.(v_fields{2,i})));
    end
end

% Reweight powerspectrum
if isfield(v,'ps')
    v.ps = v.ps.*fftshift(v.bin_filt);
end

% Calculate amplitude 
if isfield(v,'amp')
    if isfield(v,'filt_ref')
        v.amp = abs(fftshift(fftn(v.filt_ref.*v.psmask)));
    else
        v.amp = abs(fftshift(fftn(v.wei_ref.*v.psmask)));
    end
end


%% Write volumes
switch p(idx).subtomo_mode

    case {'ali_singleref','avg_singleref'}

        % Write unweighted reference and weighting filters
        if p(idx).writefilt
            
            % Prepare unweighted reference
            v.ref = real(ifftn(ft_ref.*lowpass));
            n.ref = [n.ref,'-unfiltered'];
            
            % Write unweighted volumes
            for i  = 1:n_vol
                name = [n.(v_fields{1,i}),'_',num2str(iter),'.em'];
                write_em(p(idx).rootdir,name,v.(v_fields{1,i}));
            end

        end
        
        % Write weighted references
        for i  = 2:n_vol
            if ~strcmp(v_fields{3,i},'skip')
                name = [n.(v_fields{3,i}),'_',num2str(iter),'.em'];
                write_em(p(idx).rootdir,name,v.(v_fields{3,i}));
            end
        end
        
        % Write powerspectrum
        if isfield(v,'ps')
            name = [p(idx).psfilename,'_',num2str(iter),'.em'];
            write_em(p(idx).rootdir,name,v.ps);
        end
        
        % Write amplitude
        if isfield(v,'amp')
            name = [p(idx).ampfilename,'_',num2str(iter),'.em'];
            write_em(p(idx).rootdir,name,v.amp);
        end

    otherwise
        
        % Write unweighted reference and weighting filters
        if p(idx).writefilt
            
            % Prepare unweighted reference
            v.ref = real(ifftn(ft_ref.*lowpass));
            n.ref = [n.ref,'-unfiltered'];
            
            % Write unweighted volumes
            for i  = 1:n_vol
                name = [n.(v_fields{1,i}),'_',num2str(iter),'-',num2str(avg_class),'.em'];
                write_em(p(idx).rootdir,name,v.(v_fields{1,i}));
            end

        end
        
        % Write weighted references
        for i  = 2:n_vol
            if ~strcmp(v_fields{3,i},'skip')
                name = [n.(v_fields{3,i}),'_',num2str(iter),'-',num2str(avg_class),'.em'];
                write_em(p(idx).rootdir,name,v.(v_fields{3,i}));
            end
        end

        % Write powerspectrum
        if isfield(v,'ps')
            name = [p(idx).psfilename,'_',num2str(iter),'-',num2str(avg_class),'.em'];
            write_em(p(idx).rootdir,name,v.ps);
        end
        
        % Write amplitude
        if isfield(v,'amp')
            name = [p(idx).ampfilename,'_',num2str(iter),'-',num2str(avg_class),'.em'];
            write_em(p(idx).rootdir,name,v.amp);
        end
        
end % End writing switch

                   

% Write checkjob
system(['touch ',p(idx).rootdir,'/',p(idx).checkjobdir,'/stopgap-final-avg_',num2str(o.procnum)]);
disp([nn,'Final averaging complete!!11!1!eleven!!']);





