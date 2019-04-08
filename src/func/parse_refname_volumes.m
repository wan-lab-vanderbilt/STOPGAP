function [n, v_fields] = parse_refname_volumes(p,idx,mode)
%% parse_refname_volumes
% A function to parse the parameters and assign output reference names and
% volume fields. 
%
% Modes are 'p_aver', 'f_aver', and 'cleanup'. Rows as as follows:
% For p_aver: source field in f, destination field in v
% For f_aver: summed field in v, averaged field in v, filtered vols in v. 
%
% WW 01-2018

%% Initialize

% Name struct
n = struct();

% Volume fields 
v_fields = {'subtomo';'ref';'ref';'ref'};
v_filt = {'rfilt';'filt_wedge';'filt_filt';'filt_ref'};
v_bin = {'bin_wedge';'bin_wedge';'bin_filt';'wei_ref'};


%% Parse names and feilds

% Check fields
if isfield(p(idx),'refilename')
    refilename = true;
else
    refilename = false;
end
if isfield(p(idx),'weighted_refilename')
    if ~strcmp(p(idx).weighted_refilename,'none')
        weirefname = true;
    else
        weirefname = false;
    end
else
    weirefname = false;
end
if isfield(p(idx),'filtered_refilename')
    if ~strcmp(p(idx).filtered_refilename,'none')
        filtrefname = true;
    else
        filtrefname = false;
    end
else
    filtrefname = false;
end
if isfield(p(idx),'avg_reffiltername')
    if ~strcmp(p(idx).avg_reffiltername,'none')
        avg_filt = true;
    else
        avg_filt = false;
    end
else
    avg_filt = false;
end



% If refilename is set, assign it to either weighted_ref or filtered_ref
if refilename
    
    % Set reference name
    n.ref = p(idx).refilename;
    
    % Parse path
    [ref_path,~,~] = fileparts(p(idx).refilename); 
    
    % Check for averaging ref-filter
    if avg_filt && ~filtrefname
        
        % Assign filtered wedge to name
        v_fields = cat(2,v_fields,v_filt);                   
        n.filt_wedge = [ref_path,'/filt-wedge'];
        n.filt_ref = p(idx).refilename;
        
    
    else

        % Assign binary wedge to name
        v_fields = cat(2,v_fields,v_bin);      
        n.bin_wedge = [ref_path,'/bin-wedge'];
        n.wei_ref = p(idx).refilename;
        
    end 
    
elseif weirefname
    
    % Set reference name
    n.ref = p(idx).weighted_refilename;
    
    % Parse path
    [ref_path,~,~] = fileparts(p(idx).weighted_refilename); 
    
    % Assign binary wedge to name
    v_fields = cat(2,v_fields,v_bin);      
    n.bin_wedge = [ref_path,'/bin-wedge'];
    n.wei_ref = p(idx).weighted_refilename;
    
end

if filtrefname
    
    if ~isfield(n,'ref')
        n.ref = p(idx).filtered_refilename;
    end
    
    % Parse path
    [ref_path,~,~] = fileparts(p(idx).filtered_refilename);
    
    % Assign filtered wedge to name
    v_fields = cat(2,v_fields,v_filt);                   
    n.filt_wedge = [ref_path,'/filt-wedge'];
    n.filt_ref = p(idx).filtered_refilename;
        
end

%% Format outputs for mode

switch mode
    case 'p_aver'
        v_fields = v_fields(1:2,:);
    case 'f_aver'
        v_fields = v_fields(2:4,:);
    case 'cleanup'
        v_fields = v_fields([2,4],2:end);
        v_fields = v_fields(:);
end














