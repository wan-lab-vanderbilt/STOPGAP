function vol_name = get_p_avg_vol_name(volume,reflist,halfset,mode,class)
%% get_p_avg_vol_name
% Parse a volume name for motivelist entry.
%
% WW 06-2019

%% Parse name

% Determine volume root
switch volume
    case 'ref'
        % Parse reference indices
        if strcmp(mode{2},'singleref') && (numel(reflist) == 1)
            ref_idx = 1;
        else
            ref_idx = [reflist.class] == class;
        end
        name = reflist(ref_idx).ref_name;
    case 'wfilt'
        name = 'wfilt';
    case 'ps'
        name = 'ps';
end
        

% Assemble name
switch mode{2}
    case 'singleref'
        vol_name = [name,'_',halfset];
    otherwise
        vol_name = [name,'_',halfset,'_',num2str(class)];
end





