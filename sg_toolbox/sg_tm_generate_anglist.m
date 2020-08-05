%% sg_tm_generate_anglist
% A function to generate an angle list for STOPGAP Template Matching. The
% main input option is angular search increment. For non-C1 symmetry, the 
% search ranges are restricted to find only the asymmetric unit.
%
% Currently, only C and D symmetries are supported.
%
% WW 01-2019

%% Inputs

% Angular search increment
angincr = 6;

% Symmetry
sym = 'C1';

% Output name
output_name = 'anglist_6deg_c1.csv';


%% Calcualte symmetry restrictions

% Theta range
if strcmpi(sym(1),'d')
    the_max = 90;
else
    the_max = 180;
end

% Phi range
if any(strcmpi(sym(1),{'c','d'}));
    if str2double(sym(2:end)) == 0
        phi_max = 0;
    else
        n_fold = str2double(sym(2:end));
        phi_max = 360/n_fold;
    end
else
    phi_max = 360;
end



%% Theta angles

% Theta steps
temp_steps = the_max/angincr;
the_array = linspace(0,the_max,round(temp_steps)+1);
n_steps = numel(the_array);

% Calculate arclength
arc = 2*pi*(angincr/360);
 
%% Psi angles
 
% Array to store phi angles
psi_array = cell(n_steps,1);
psi_array{1} = [0;0];
if the_array(end) == 180
    psi_array{end} = [0;180];
end
    

% Generate phi angles
idx = find((the_array > 0) & (the_array < 180));
c = 1;
for i = idx

    % Radius of circle
    r = sind(the_array(i));
    
    % Circumference
    c = 2*pi*r;
    
    % Number of psi steps
    n_psi_steps = ceil(c/arc);
    
    
    % Psi angles
    psi_angles = 0:360/n_psi_steps:360;
    psi_step = psi_angles(2);
    if mod(c,2)
        psi_angles = psi_angles + psi_step/2;
    end
    c = c+1;
    psi_array{i} = cat(1,psi_angles(1:end-1),repmat(the_array(i),[1,numel(psi_angles)-1]));
    
end


%% Phi angles

% Calculate phi angles
temp_steps = phi_max/angincr;
phi_array = linspace(0,phi_max,round(temp_steps)+1);
phi_array = phi_array(1:end-1); % Final angle is redundant
if isempty(phi_array)
    phi_array = 0;
end
n_phi = numel(phi_array);


%% Generate angle list

% Concatenate cone array
cone_array = cat(2,psi_array{:});
n_cones = size(cone_array,2);    

% Generate Euler triplets
n_angles = n_cones*n_phi;
anglist = cat(1,reshape(repmat(phi_array,[n_cones,1]),[1,n_angles]),repmat(cone_array,[1,n_phi]));

% Write output
csvwrite(output_name,anglist');

% Display ino
disp(['Angle list generated with ',num2str(angincr),' degrees angular increment and ',sym,' symmetry...']);
disp(['Angle list contains ',num2str(n_angles),' search angles!']);















