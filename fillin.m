% Fill in an image given the label (i.e. the intensity level to fill) and
% the single line boundary image.
function [out] = fillin(input,label) %use label to check whether a coordinate is a boundary pixel coordinate
    detpix = [1 1]; %start filling from top left, perform reverse fill, i.e. fill outside boundary
    outpix = [1 1];
    same = false;
    sz = size(input);
    nrow = sz(1);
    ncol = sz(2);
    input = cleaninput(input,label);
    %extend image by 1 row top and bottom, as well as 1 col left and right,
    %to ensure that the whole outer region is connected, as well as top
    %most is always outisde the boundary
    A = zeros(nrow,1);
    input = cat(2,A,input,A);
    B = zeros(1,ncol+2);
    input = cat(1,B,input,B);
    temp = input;
    
    % update size after appending zeros
    nrow= nrow + 2;
    ncol = ncol + 2;
    
    
    
    while same == false 
        s = size(outpix);
        r = s(1);
        newpixels = [];
        for i = 1:r % find 4 neighbors of all the outermost pixels and append first for all outermost pixels
           nb = get4n(outpix(i,1),outpix(i,2));
           newpixels = cat(1,newpixels,nb);     
        end
        % remove repeating pixels
        newpixels = unique(newpixels,'rows');
        
        %remove out of bounds pixels
        idx = any(newpixels<=0,2); %removed pixels that are left or top out of bounds
        newpixels(idx,:) = [];
           
        % for right and bottom out of bounds, must filter row and column
        % coordinates seperately, because number of rows and columns are
        % not always same.
        
        % filter row coordinates
        ind = any(newpixels(:,1)>nrow,2);
        newpixels(ind,:) = [];
        
        % filter col coordinates
        ind = any(newpixels(:,2)>ncol,2);
        newpixels(ind,:) = [];
             
        % then, also filter out pixels that are on the boundary 
        for i = 1:length(newpixels)
           r = newpixels(i,1);
           c = newpixels(i,2);
           if input(r,c) == label
              newpixels(i,:) =  -10; % if detected coordinate is a boundary pixel, mark as invalid value
           end
        end
        
        % remove invalid values detected from above
        ind = any(newpixels==-10,2);
        newpixels(ind,:) = [];
        
        % finally, also remove pixels that are already detected previously,
        % this is to ensure that newpixels only contain outermost 4
        % neigbors from the previously detected pixels w/o repetition
        L = ismember(newpixels,detpix,'rows');
        newpixels(L,:) = [];
        
        
        % then append the new pixels to the list of pixels detected. The
        % newly detected pixels will also become the outermost pixels for
        % the next iteration
        detpix = cat(1,detpix,newpixels);
        detpix = unique(detpix,'rows');
        outpix = newpixels;
        if(isempty(newpixels)==true) % means no new pixels detected
           same = true; 
        end
        
    end %detect all pixels outside the boundary
    
    % then proceed to simply iterate through the list of detected points,
    % and fill 1's to temp. The result would be all 1 on outer region AND
    % the boundary itself. Then proceed to invert this temp, and add into
    % the original input. The result would be a filled region inside the
    % boundary + the boundary itself
    r = length(detpix);
    for i = 1:r
       row = detpix(i,1);
       col = detpix(i,2);
       temp(row,col) = label;
    end
    temp = label*(temp==0);
    out = temp + input;
    
    % remove additional rows and columns to restore original image size
    out(1,:) = [];
    out(:,1) = [];
    so = size(out);
    ro = so(1);
    co = so(2);
    out(ro,:) = [];
    out(:,co) = [];
    
end

function [neighbors] = get4n(r,c) %r = rows, c = columns 
    neighbors = [r+1 c; r-1 c; r c+1; r c-1];
end

function [out] = cleaninput(input,label)
    sz = size(input);
    nrow = sz(1);
    ncol = sz(2);
    for i = 1:nrow
       for j = 1:ncol
          if(input(i,j) ~= label)
             input(i,j)=0; 
          end
       end
    end
    out = input;
end