function o = get_allmotl(p,o,idx)
%% get_allmotl
% A function to read in an allmotl, the number of motls, and classes.
%
% WW 11-2017

%% Read allmotl
global nn
disp([nn,'Reading allmotl...']);

% Read allmotl
aname = [p(idx).allmotlname,'_',num2str(p(idx).iteration),'.em'];
o.allmotl = read_em(p(idx).rootdir,aname);
o.n_motls = size(o.allmotl,2);

%% Get classes

switch p(idx).subtomo_mode
    case {'ali_singleref','avg_singleref'}   
        
        o.n_classes = 1;
        
    case {'ali_multiclass','avg_multiclass'}
        
        % Get classes
        if p(idx).iclass == 0
            classes = unique(o.allmotl(20,:));
        else
            classes = intersect(unique(o.allmotl(20,:)),p(idx).iclass);
        end
        o.n_classes = numel(classes);

        
    case {'ali_multiref','avg_multiref'}
        
        % Find top classes
        if p(idx).iclass == 0
            o.n_classes = size(o.allmotl,3);
        else
            classes = intersect(o.allmotl(20,1,:),p(idx).iclass); % Classes and indices along dim3
            o.n_classes = numel(classes);
        end

end
      
