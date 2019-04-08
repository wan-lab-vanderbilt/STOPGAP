%% Numeric evalulation function
function x = numeval(x)

if (ischar(x.filecheck)); x.filecheck=eval(x.filecheck); end

% May not always exists
if isfield(x,'completed'); if (ischar(x.completed)); x.completed=logical(eval(x.completed)); end; end
if isfield(x,'iteration'); if (ischar(x.iteration)); x.iteration=eval(x.iteration); end; end
if isfield(x,'startidx'); if (ischar(x.startidx)); x.startidx=eval(x.startidx); end; end
if isfield(x,'iterations'); if (ischar(x.iterations)); x.iterations=eval(x.iterations); end; end;

if (ischar(x.tomorow)); x.tomorow=eval(x.tomorow); end
if (ischar(x.subtomozeros)); x.subtomozeros=eval(x.subtomozeros); end

if (ischar(x.angincr)); x.angincr=eval(x.angincr); end
if (ischar(x.angiter));x. angiter=eval(x.angiter); end
if (ischar(x.phi_angincr)); x.phi_angincr=eval(x.phi_angincr); end
if (ischar(x.phi_angiter)); x.phi_angiter=eval(x.phi_angiter); end

if (ischar(x.lp_rad)); x.lp_rad=eval(x.lp_rad); end
if (ischar(x.lp_sigma)); x.lp_sigma=eval(x.lp_sigma); end
if (ischar(x.hp_rad)); x.hp_rad=eval(x.hp_rad); end
if (ischar(x.hp_sigma)); x.hp_sigma=eval(x.hp_sigma); end

if (ischar(x.nfold)); x.nfold=eval(x.nfold); end
if (ischar(x.threshold)); x.threshold=eval(x.threshold); end
% if (ischar(x.iclass)); x.iclass=eval(x.iclass); end
if (ischar(x.fthresh)); x.fthresh=round(eval(x.fthresh)); end
if (ischar(x.writefilt)); x.writefilt=logical(eval(x.writefilt)); end

if (ischar(x.total_cores)); x.total_cores=eval(x.total_cores); end
if (ischar(x.n_cores_ali)); x.n_cores_ali=eval(x.n_cores_ali); end
if (ischar(x.n_cores_aver)); x.n_cores_aver=eval(x.n_cores_aver); end

end

