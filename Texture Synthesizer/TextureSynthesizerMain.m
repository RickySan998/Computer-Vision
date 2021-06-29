% load image and initialize constants
% Make sure that the image files are in the MATLAB path, or in the same
% directory/folder as this code. Also make sure that the supporting
% functions get_neighbors.m, find_match2.m, and get_unfilled_pixels.m are
% in the same directory.
I = imread('texture11.jpg'); % change the name to texturex.jpg, x could be from 1 to 11
I = im2double(I);
[r,c,D] = size(I);
win_size = 5; % adjust this to vary the window size when extracting the neighborhood. Must be an odd number
max_ssd = 0.1; % because im2double scales the image intensity to [0,1].


% create a blank image, of size nr x nc, and copy the image
% code below generalized for rgb and greyscale images
n = 2; % modify this to any integer, to create a larger synthesized result
template = zeros(n*r,n*c,D);
template(1:r,1:c,1:D) = I;
% also create a status array for filled and unfilled pixels, to later find
% the unfilled neighbors
[rt,ct,Dt] = size(template);
filled_stats = zeros(rt,ct);
filled_stats(1:r,1:c) = 1;

% initiate fill count 
fill_count = 0;
to_fill_count = (n*r)*(n*c) - r*c;

figure (1);
imshow(template);

% start filling
while fill_count < to_fill_count
    % get possible fill candidates
    to_fill_loc = get_unfilled_pixels(filled_stats,win_size);
    [h,l] = size(to_fill_loc);
    % fill all pixels in the list of candidates and keep track of the
    % progress. If none is filled in this round, we increase the maximum
    % allowed ssd.
    fill_progress = 0;
    sprintf('Found %d candidates to fill\n',h)
    for i = 1: h
        sprintf('Working on candidate %d\n',i)
        center = to_fill_loc(i,:); center_i = center(1); center_j = center(2);
%         sprintf("Finding match for location %d,%d\n",center_i,center_j)
        n_tofill = get_neighbors(template,center,win_size); % get neighborhood to match
        n_tofill_mask = get_neighbors(filled_stats,center,win_size); % get status of neighborhood,
        % i.e. whether or not a particular pixel is known
        [locs,locs_ssd] = find_match2(I,n_tofill,n_tofill_mask,win_size);
        
        % sample randomly from the list of matches location
        [h2,l2] = size(locs);
        idx = randi(h2);
        match_ssd = locs_ssd(idx,:); match_loc_i = locs(idx,1); match_loc_j = locs(idx,2);
        
        sprintf("Best match for this location is %d,%d with error %f\n",match_loc_i,match_loc_j,match_ssd)
        % if match error is less than allowed ssd, then this is our match
        if match_ssd <= max_ssd
            sprintf("Good match\n")
            template(center_i,center_j,:) = I(match_loc_i,match_loc_j,:);
            filled_stats(center_i,center_j) = 1;
            fill_count = fill_count + 1;
            fill_progress = fill_progress + 1;
        end
    end
    figure(1);
    sprintf("Filled %d/%d pixels\n",fill_count,to_fill_count)
    imshow(template);
    if fill_progress == 0
       max_ssd = max_ssd * 1.2; % increase allowed SSD if we do not fill anything from 1 round 
    end
end
