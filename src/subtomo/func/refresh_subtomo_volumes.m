function o = refresh_subtomo_volumes(p,s,o,idx)
%% refresh_subtomo_volumes
% Refresh volumes for subtomogram alignment/averaging.
%
% WW 06-2019

%% Refresh volumes

% Subtomogram volumes
% Parameter name, fieldname, volume directory, Fourier crop
subtomo_vols = {'ccmask_name',   'ccmask',   'maskdir', false;...
                'specmask_name', 'specmask', 'maskdir', false};
            
% Refresh volumes
o = refresh_volumes(p,o,s,idx,subtomo_vols);

