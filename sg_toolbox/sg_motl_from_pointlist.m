function motl = sg_motl_from_pointlist(pointlist,tomo_num,output_name)
%% sg_motl_from_pointlist
% Generate a motivelist from a list of points. The pointlist should have
% the format of row-array, with columns as X, Y, and Z coordinates.
%
% A tomo_num parameter can be given to write the tomogram numbers.
%
% If an output name is given, the motive list is written out. 
%
% WW 04-2019


%% Check check

if nargin == 1
    tomo_num = 1;
elseif isempty(tomo_num);
    tomo_num = 1;
end

if ischar(pointlist)
    pointlist = dlmread(pointlist);
end




%% Generate motivelist

% Number of motls
n_motls = size(pointlist,1);

% Initialize motivelist
motl = sg_initialize_motl(n_motls);

% Fix coordinates
orig_x = round(pointlist(:,1));
orig_y = round(pointlist(:,2));
orig_z = round(pointlist(:,3));
x_shift = pointlist(:,1) - orig_x;
y_shift = pointlist(:,2) - orig_y;
z_shift = pointlist(:,3) - orig_z;



% Fill fields
motl = sg_motl_fill_field(motl,'tomo_num',tomo_num);
motl = sg_motl_fill_field(motl,'object',1);
motl = sg_motl_fill_field(motl,'subtomo_num',(1:n_motls));
motl = sg_motl_fill_field(motl,'halfset','A');
motl = sg_motl_fill_field(motl,'orig_x',orig_x);
motl = sg_motl_fill_field(motl,'orig_y',orig_y);
motl = sg_motl_fill_field(motl,'orig_z',orig_z);
motl = sg_motl_fill_field(motl,'score',0);
motl = sg_motl_fill_field(motl,'x_shift',x_shift);
motl = sg_motl_fill_field(motl,'y_shift',y_shift);
motl = sg_motl_fill_field(motl,'z_shift',z_shift);
motl = sg_motl_fill_field(motl,'phi',0);
motl = sg_motl_fill_field(motl,'psi',0);
motl = sg_motl_fill_field(motl,'the',0);
motl = sg_motl_fill_field(motl,'class',1);


% Write output
if nargin == 3
    sg_motl_write(output_name,motl);
end






