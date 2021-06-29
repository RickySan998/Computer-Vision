% to obtain the contours, input is the edge map
% For explanation on the logic behind the code, refer to the project report
% in Step 3 Part A
function [output] = boundaries(input)
    sz = size(input);
    nrow = sz(1);
    ncol = sz(2);
    
    output = zeros(nrow,ncol);
    output2 = minlengthcontour(input,10);
    
    figure(10)
    imshow(output2);
    title('Image after Applying Minimum Length Contour Removal');
    
    output2 = connectedcomponents(output2);
    
    
    % To only find contours for largest 2 'edges'. This is of course assuming there are only 2 objects in the image, and the 2 objects have the largest edge perimeter
    nlabels = max(max(output2));
    s = zeros(1,nlabels);
    
    for n = 1:nlabels
        bp = findbp(output2,n);
        s(n) = length(bp);
    end
    [s,idx] = sort(s,'descend');
    labellist = idx(1,1:2);
    %
     for n = labellist
         output = output + findcontour(output2,n);
     end
   
end

% To remove 'contours' that are below a user-specified minimum length
function [out2] = minlengthcontour(input,minlen)
    starty = 1;
    startx = 0;
    i = 1;
    j = 1;
    sz = size(input);
    nrow = sz(1);
    ncol = sz(2);
    out = zeros(nrow,ncol);
    
    % start loop for finding first point and applying contour tracking
    % repeat this loop to find multiple 'contours'
    
    while i<=nrow && j<=ncol
        j = startx+1;
        i = starty;
        if j>ncol
            j = 1;
            i = i + 1;
        end
    
        % Find start point
        visitedpoints = [];
        foundstart = false;
        while foundstart == false && i <=nrow && j <=ncol
            if input(i,j)==1 && out(i,j)==0
               foundstart = true;
               startx = j;
               starty = i;
               out(i,j) = 1;
               visitedpoints = cat(1,visitedpoints, [i,j]);
            else
                j = j + 1;
                if (j > ncol)
                   j = 1;
                   i = i + 1;
                end
            end
        end % Here starting point is found for the current 'contour'
        
        % Apply Contour Tracking
        if i<= nrow && j <=ncol
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
                if input(ni,nj) == 1 && out(ni,nj) == 0
                   i = ni;
                   j = nj;
                   visitedpoints = cat(1,visitedpoints, [i,j]);                                      
                   dir = startdir;
                   foundnext = true;
                else
                    startdir = mod(startdir+1,8);
                    count = count + 1;
                end
            end % Here, next boundary point is found

            out(i,j) = 1;

            if (i == starty && j == startx) || count > 8
               back2start = true;
            end
        end % Here, a single contour has been detected

        % Mark 'contour' that is below minimum length
        visitedpoints = unique(visitedpoints,'rows');
        if length(visitedpoints) < minlen
           for x = visitedpoints.'
              r = x(1);
              c = x(2);
              out(r,c) = 2;
           end
        end
    end
    
    % Remove all contours below minimum length
    for i = 1:nrow
       for j = 1:ncol
          if out(i,j) ~= 1
             out(i,j) = 0; 
          end
       end
    end
    out2 = out;
end

% function to return the next row and column based on contour tracking rule
% to make main loop neater
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

% Define lecture notes contour tracking function, detects only 1 contour
% for a given label from connected components labelling
function [out] = findcontour(input,label)
    i = 1;
    j = 1;
    sz = size(input);
    nrow = sz(1);
    ncol = sz(2);
    out = zeros(nrow,ncol);
    
    
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
              i = ni;
              j = nj;
              dir = startdir;
              foundnext = true;
           else
               startdir = mod(startdir+1,8);
               count = count + 1;
           end
        end % Here, next boundary pixel is found
        
        out(i,j) = 1;
        
        if (i==starty && j == startx) || count > 8
           back2start = true; 
        end
    end % Found a single boundary
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
