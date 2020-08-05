function sg_motl_stopgap_to_av3(input_name,output_name)
%% sg_motl_stopgap_to_av3
% Convert a stopgap .star motivelist to a TOM/AV3 formatted motivelist.
%
% WW 07-2018

%% Check check

if nargin == 1
    [path,name,~] = fileparts(input_name);
    if ~isempty(path)
        path = [path,'/'];
    end
    output_name = [path,name,'.em'];
end


%% Convert

% Read old motl
star_motl = sg_motl_read2(input_name);
n_motls = numel(star_motl.motl_idx);

% Intiailize AV3 motl
av3_motl = zeros(20,n_motls);

% Fill fields
av3_motl(1,:) = star_motl.score;
av3_motl(4,:) = star_motl.subtomo_num;
av3_motl(5,:) = star_motl.tomo_num;
av3_motl(6,:) = star_motl.object;
av3_motl(7,:) = cellfun(@(x) double(x)-64, star_motl.halfset);
av3_motl(8,:) = star_motl.orig_x;
av3_motl(9,:) = star_motl.orig_y;
av3_motl(10,:) = star_motl.orig_z;
av3_motl(11,:) = star_motl.x_shift;
av3_motl(12,:) = star_motl.y_shift;
av3_motl(13,:) = star_motl.z_shift;
av3_motl(17,:) = star_motl.phi;
av3_motl(18,:) = star_motl.psi;
av3_motl(19,:) = star_motl.the;
av3_motl(20,:) = star_motl.class;

% Write output
sg_emwrite(output_name,av3_motl);



