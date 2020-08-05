function bpf_refresh = check_bpf_change(p,idx)
%% check_bpf_change
% Check if bandpass fitler settings have changed. If they have, it needs to
% be refreshed. 
%
% WW 06-2019

%% Check check

% Set refresh
bpf_refresh = false;

% Check for first iteration
if idx == 1
    bpf_refresh = true;
    return
end

if p(idx).lp_rad ~= p(idx-1).lp_rad
    bpf_refresh = true;
elseif p(idx).hp_rad ~= p(idx-1).hp_rad
    bpf_refresh = true;
elseif isfield(p,'lp_sigma')
    if p(idx).lp_sigma ~= p(idx-1).lp_sigma
        bpf_refresh = true;
    end
elseif isfield(p,'hp_sigma')
    if p(idx).hp_sigma ~= p(idx-1).hp_sigma
        bpf_refresh = true;
    end   
end

    

