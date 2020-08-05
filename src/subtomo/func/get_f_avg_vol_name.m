function vol_name = get_f_avg_vol_name(volume,reflist,halfset,mode,class,iteration)
%% get_f_avg_vol_name
% Parse a volume name for motivelist entry.
%
% WW 06-2019

%% Parse name

% Determine volume root
switch volume
    
    case {'ref','wfilt'}
        % Parse reference indices
        if strcmp(mode{2},'singleref') && (numel(reflist) == 1)
            ref_idx = 1;
        else
            ref_idx = [reflist.class] == class;
        end
        if strcmp(volume,'ref')
            name = reflist(ref_idx).ref_name;
        else
            name = ['wfilt_',reflist(ref_idx).ref_name];
        end
        
    otherwise
        name = volume;
end
        

% Assemble name
if isempty(halfset)
    h_str = [];
else
    h_str = [halfset,'_'];
end
switch mode{2}
    case 'singleref'
        vol_name = [name,'_',h_str,num2str(iteration)];
    otherwise
        vol_name = [name,'_',h_str,num2str(iteration),'_',num2str(class)];
end





