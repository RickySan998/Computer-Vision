% to compute the features, input is the contours image
% Features computed are perimeter, area, compactness, centroid, minimum
% radial distance, maximum radial distance. 
% For logic behind the code, refer to the project report.
% Function also returns the coordinates for maximum and minimum radial
% distance.
function [P1, A1, C1, xbar1, ybar1, rmax1, rmin1,rowmax1,colmax1,rowmin1,colmin1, P2, A2, C2, xbar2, ybar2, rmax2, rmin2,rowmax2,colmax2,rowmin2,colmin2] = features(I3)
    % First, with the single line boundary image I3, we apply connected
    % component labelling to distinguish the 2 boundaries
    input = connectedcomponents(I3);
    nlabel = max(max(input));
    sz = size(input);
    nrow = sz(1);
    ncol = sz(2);
    s = zeros(1,nlabel);
    res = zeros(11,2); % stores all the results
    % For the rest of the code, since features are found for each object, we
    % iterate through each labels first to find the first 2 significant objects
    % this is because the connected component labelling is sensitive to noise.
    % To define size for the purpose of this analysis, use number of points for
    % a specific label. Then we pick the 2 labels with highest size
    for n = 1:nlabel
        bp = findbp(input,n);
        s(n) = length(bp);
    end
    [s,idx] = sort(s,'descend');
    labellist = idx(1,1:2);
    
    % Iterate through the 2 most significant labels
    objcount = 1;
    for n = labellist
        maxrad = 0;
        minrad = 2*(nrow+ncol); %radial distance wil not exceed sum of length of rows and cols
        % Find bounding frame coordinates. This will speed up region filling
        % since we only take a a portion of the original image containing
        % the single boundary to fill in
        bp = findbp(input,n);
        minr = min(bp(:,1));
        maxr = max(bp(:,1));
        minc = min(bp(:,2));
        maxc = max(bp(:,2));
        
        % take only that portion to fill
        inputfill = input;
        temp = input(minr:maxr,minc:maxc);
        temp = fillin(temp,n);
        inputfill(minr:maxr,minc:maxc) = temp;
        
        % obtain the region coordinates
        rp = findbp(inputfill,n);
        
        % Find perimeter, by contour tracking the boundary. Use input,
        % which is only boundary
        perimeter = findperimeter(input,n);
        
        % Area can be found by counting number of region coordinates
        % including the boundary
        area = length(rp);
        
        % Find centroids. xbar is sum of all column coordinates divided by
        % number of points. ybar is sum of all row coordinates divided by
        % number of points.
        xbar = sum(rp(:,2))/length(rp);
        ybar = sum(rp(:,1))/length(rp);
        ybar_cen = nrow - ybar; % origin is assumed to be bottom left
        
        % Find compactness
        com = (perimeter^2)/(4*pi*area);
        
        % Find maximum and minimum radial distance. 
        for i = 1:length(bp)
            r = bp(i,1);
            c = bp(i,2);
            dist = sqrt((r-ybar)^2 + (c-xbar)^2);
            if dist >= maxrad
               maxrad = dist; 
               row_max_rad = r;
               col_max_rad = c;
            end
            if dist <= minrad
               minrad = dist;
               row_min_rad = r;
               col_min_rad = c;
            end
        end
        % Store results to the container
        res(:,objcount) = [perimeter area com xbar ybar_cen maxrad minrad row_max_rad col_max_rad row_min_rad col_min_rad]; 
        objcount = objcount + 1;
    end
   
    % Assign to output variables
    P1 = res(1,1);
    A1 = res(2,1);
    C1 = res(3,1);
    xbar1 = res(4,1);
    ybar1 = res(5,1);
    rmax1 = res(6,1);
    rmin1 = res(7,1);
    rowmax1 = res(8,1);
    colmax1 = res(9,1);
    rowmin1 = res(10,1);
    colmin1 = res(11,1);
    P2 = res(1,2);
    A2 = res(2,2);
    C2 = res(3,2);
    xbar2 = res(4,2);
    ybar2 = res(5,2);
    rmax2 = res(6,2);
    rmin2 = res(7,2);   
    rowmax2 = res(8,2);
    colmax2 = res(9,2);
    rowmin2 = res(10,2);
    colmin2 = res(11,2);


end

function [boundarypoints] = findbp(input,label)
    boundarypoints = [];
    sz = size(input);
    nrow = sz(1);
    ncol = sz(2);
    for i = 1:nrow
       for j = 1:ncol
          if(input(i,j)==label)
             boundarypoints = cat(1,boundarypoints,[i j]); 
          end
       end
    end
end

function perimeter = findperimeter(input,label)
    i = 1;
    j = 1;
    sz = size(input);
    nrow = sz(1);
    ncol = sz(2);
    out = zeros(nrow,ncol);
    perimeter = 0;
    
    % Find start point
    foundstart = false;
    while foundstart == false && i <=nrow && j <=ncol
        if input(i,j) == label
            foundstart = true;
            startx = j;
            starty = i;
            out(i,j) = 1;
        else
            j = j + 1;
            if j>ncol
                j = 1;
                i = i + 1;
            end
        end
    end % Here starting point is found
    
    % Apply Contour Tracking
    if i<=nrow && j <=ncol
       dir = 1;
       back2start = false;
       i = starty;
       j = startx;
    else
        back2start = true;
    end
    while back2start == false
        foundnext = false;
        count = 0;
        startdir = mod(dir-2,8);
        while foundnext == false && count <= 8
           [ni,nj] = lookahead(i,j,startdir);
           if input(ni,nj) == label
              dist = sqrt((i-ni)^2 + (j-nj)^2);
              perimeter = perimeter + dist;
              i = ni;
              j = nj;
              dir = startdir;
              foundnext = true;
           else
               startdir = mod(startdir+1,8);
               count = count + 1;
           end
        end % Here, next boundary pixel is found

        if (i==starty && j == startx) || count > 8
           back2start = true; 
        end
    end % Found a single boundary
end

function [nextrow, nextcol] = lookahead(currow,curcol,direction)
    if direction == 0
        nextrow = currow - 1;
        nextcol = curcol + 1;
    elseif direction == 1
        nextrow = currow;
        nextcol = curcol + 1;
    elseif direction == 2
        nextrow = currow + 1;
        nextcol = curcol + 1;
    elseif direction == 3
        nextrow = currow + 1;
        nextcol = curcol;
    elseif direction == 4
        nextrow = currow + 1;
        nextcol = curcol - 1;
    elseif direction == 5
        nextrow = currow;
        nextcol = curcol - 1;
    elseif direction == 6
        nextrow = currow - 1;
        nextcol = curcol - 1;
    elseif direction == 7
        nextrow = currow - 1;
        nextcol = curcol;
    end
end

