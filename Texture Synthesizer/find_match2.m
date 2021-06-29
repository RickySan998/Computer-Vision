function [locs,locs_err] = find_match2(sample,n_tofill,n_tofill_mask,win_size)
    max_ssd_range = 0.01;
    win_len = (win_size-1)/2;
    
    % extend the sample by (win_size-1)/2, and re-arrange to columns
    [r,c,D] = size(sample);
    sample = cat(1,zeros(win_len,c,D),sample,zeros(win_len,c,D));
    [r2,c2,D2] = size(sample);
    sample = cat(2,zeros(r2,win_len,D),sample,zeros(r2,win_len,D));
    
    % define gaussian mask
%     sigma = (win_size-1)/(2*3); % i.e. half of length of window covers 3 standard deviations
    sigma = win_size/6.4;
    Gaussian = fspecial('gaussian',[win_size win_size],sigma);
    % combine with the status of the neighborhood, so that when we compare
    % SSD, we place a weight of zero on pixels that are unknown (because we
    % only want to compare known pixels)
    weights = Gaussian .* n_tofill_mask;
    % normalize the weights, otherwise values from Gaussian mask is too
    % small
    weights = weights / sum(sum(weights));
    % re-arrange weights into a single row
    weights = weights(:)';
    
    % re-arrange to column form for faster SSD computation
    if D > 1
        % each window (as we slide the window downwards and right, i.e.
        % raster, becomes one column, where each column is stacking columns
        % inside a window. Hence, diff between each column with the sample
        % in column form, squared, is the squared difference. Multiplying this
        % with our row mask, results in a 1xn matrix of weighted SSD's,
        % where the ith element is the SSD between the ith window frame and
        % the pix-to-fill neighborhood. E.g. 1st element = SSD between 1st window frame
        % (around the top-left (1,1) of the sample pixel) and the to-fill
        % neighborhood, 2nd is window frame around (2,1) with to-fill, etc.
        sample_R = sample(:,:,1); sample_R = im2col(sample_R,[win_size win_size],'sliding');
        sample_G = sample(:,:,2); sample_G = im2col(sample_G,[win_size win_size],'sliding');
        sample_B = sample(:,:,3); sample_B = im2col(sample_B,[win_size win_size],'sliding');
        [rl,cl] = size(sample_R);
        n_tofill_R = n_tofill(:,:,1); n_tofill_R = repmat(n_tofill_R(:),[1 cl]);
        n_tofill_G = n_tofill(:,:,2); n_tofill_G = repmat(n_tofill_G(:),[1 cl]);
        n_tofill_B = n_tofill(:,:,3); n_tofill_B = repmat(n_tofill_B(:),[1 cl]);
        
        % compute the SSDs
        R_SSD = weights * ((n_tofill_R - sample_R).^2);
        G_SSD = weights * ((n_tofill_G - sample_G).^2);
        B_SSD = weights * ((n_tofill_B - sample_B).^2);
        SSD = R_SSD + G_SSD + B_SSD;
    else
        sample = im2col(sample,[win_size win_size],'sliding');
        [rl,cl] = size(sample);
        n_tofill = repmat(n_tofill(:),[1 cl]);
        SSD = weights * ((n_tofill - sample).^2);
    end

    % get best match locations
    min_ssd = min(SSD);
    match_loc = find(SSD <= min_ssd*(1+max_ssd_range));
    locs_err = SSD(match_loc);
    locs_err = locs_err';
    [rmatch,cmatch] = ind2sub([r c], match_loc);
    locs = cat(2,rmatch',cmatch');
end