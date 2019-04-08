function cone_array = calculate_cone_angles(angincr, angiter, cone_search_type)
%% calculate_cone_angles
% A function to generate uniformly spaced psi and theta angles for
% performing a "cone search". The angincr determines the angular spacings;
% this directly translates into theta spacings and steps, with a greater 
% number of phi-steps for increasing theta.
%
% The search type can either be 'coarse' or 'complete', where coarse
% results in a search equivalent to DYNAMO's seach algorithm. Essentially,
% spacing around each theta-ring is equal to the spacing between the ring
% and the pole rather than the spacing between theta increments. The
% default search is complete.
%
% WW 11-2017

%% Check check!

if nargin == 2
    cone_search_type = 'complete';
end
    

% Check for 180 degree limit
if (angincr*angiter) > 180
    angiter = ceil(180/angincr);
    angincr = 180/angiter;
    disp(['Warning: maximum theta is over 180 degrees... angincr set to ',...
        num2str(angincr),' degrees!']);
end


%% Theta angles

% Theta steps
the_array = 0:angincr:(angincr*angiter);
if isempty(the_array)
    the_array = 0;
end
n_steps = numel(the_array);

% Calculate arclength
arc = 2*pi*(angincr/360);
 
%% Phi angles
 
% Array to store phi angles
psi_array = cell(n_steps,1);
psi_array{1} = [0;0];
if the_array(end) == 180
    psi_array{end} = [0;180];
end
    

% Generate phi angles
idx = find((the_array > 0) & (the_array < 180));
for i = idx

    % Radius of circle
    r = sind(the_array(i));
    
    % Circumference
    c = 2*pi*r;
    
    % Number of psi steps
    switch cone_search_type
        case 'coarse'
            n_psi_steps = ceil(c/(arc*(i-1)));
        case 'complete'
            n_psi_steps = ceil(c/arc);
    end
    
    % Psi angles
    psi_angles = 0:360/n_psi_steps:360;
    psi_array{i} = cat(1,psi_angles(1:end-1),repmat(the_array(i),[1,numel(psi_angles)-1]));
    
end

%% Concatenate cone array
cone_array = cat(2,psi_array{:});
    





