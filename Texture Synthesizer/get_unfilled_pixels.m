function [locs] = get_unfilled_pixels(fill_stat,win_size)
    % returns the locations of all candidates, sorted in descending known
    % neighbors count
    % for efficiency, we need only to search pixels that has at least 1
    % known neighbor within the window. Hence, we can apply image dilation
    % with a square element of side length = win_size. That way, if the
    % pixel has a filled neighbor within cardinal distance of
    % (win_size-1)/2, it will be 1 after dilation
%     structure_element = strel('square',win_size);

    % intuition is that unknown pixels closer to regions of known pixels
    % will definitely have more known neighbors in the window region, than
    % those further away. Furthermore, we take smaller dilation size
    % because we want to update known neighbor information as often as possible
    structure_element = strel('square',3);
    temp = imdilate(fill_stat,structure_element);
    
    % differentiate between pixels that are filled during dilation (i.e.
    % unfilled candidates) and pixels that are already filled pre-dilation
    % (i.e. known pixels)
    
    % this way, known pixel has a value of 1, unknown but candidates has a
    % value of 2, unfilled and non-candidates are 0. We need to keep the
    % known pixel information to compute the number of known neighbors
    % later
    new_stat = 2*temp - fill_stat;
    [rp,cp] = find(new_stat == 2);
    indexes = cat(2,rp,cp);
    % for each of these candidates, count the number of known neighbors
    % then sort them based on the known neighbors
    sz = size(indexes);
    h = sz(1);
    N_neighbors = zeros(h,1);
    for i = 1 : h
       neighbors = get_neighbors(new_stat,indexes(i,:),win_size);
       N_neighbors(i,1) = sum(sum(neighbors == 1));
    end
    [t,pos] = sort(N_neighbors,1,'descend');
    locs = indexes(pos,:);
end