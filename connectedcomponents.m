function [out,eqvarray] = connectedcomponents(input)
    sz = size(input);
    nrow = sz(1);
    ncol = sz(2);
    curlabel = 1;
    out = zeros(nrow,ncol);
    eqvarray = [];
    for i = 1:nrow
       for j = 1:ncol
          if input(i,j) > 0
             n = zeros(1,4);
             n(1) = out(i-1,j-1);
             n(2) = out(i-1,j);
             n(3) = out(i-1,j+1);
             n(4) = out(i,j-1);
             k = n(n~=0); % take out labels of neighbors that are non-zero
             minim = min(k);
             if all(~n) == true % check if all 4 neighbors are not labelled i.e. 0, hence check on n
                 out(i,j) = curlabel;
                 eqvarray = cat(1,eqvarray,zeros(1,curlabel-1));
                 eqvarray = cat(2,eqvarray,zeros(curlabel,1));
                 curlabel = curlabel + 1;                 
             else
                 if all(k==minim) % check if all non-zero labels are eqv, hence check k
                    out(i,j) = minim;
                 else
                     out(i,j) = minim;
                     for x = k
                        eqvarray(minim,x) = 1;
                        eqvarray(x,minim) = 1;
                     end
                 end
             end
          end
       end
    end % Here, already labelled based on component connectivity, but not yet relabelled by equivalence
    
    
    % First need to modify the equivalence array such that all equivalences
    % are reflected
    eqvarray = modifyeqv(eqvarray);
    
    % Relabel by equivalence
    for i = 1:length(eqvarray)
       targetlabel = find(eqvarray(i,:),1);
       if i ~= targetlabel
          targets = find(out==i);
          for x = reshape(targets,[1 length(targets)])
             %r = 1 + mod(x-1,nrow);
             %c = ceil(x/nrow);
             [r,c] = ind2sub(sz,x);
             out(r,c) = targetlabel;
          end
       end
    end
%     dim = size(eqvarray);
%     re = dim(1);
%     ce = dim(2);
%     for i = re:-1:1
%        for j = ce:-1:i+1
%            if eqvarray(i,j) == 1
%                 targets = find(out==j); %find linear index of pixels to relabel
%                 for x = reshape(targets,[1 length(targets)])
%                     r = 1 + mod(x-1,nrow);
%                     c = ceil(x/nrow);
%                     out(r,c) = i;
%                 end
%            end                     
%        end
%     end
%     
%   % Minimise label, i.e. order from 1,2,3,etc..
    rlabel = 0;
    k = unique(out);
    k = reshape(k,[1 length(k)]);
    for i = k
        if (i~=0) && (i ~=rlabel)
            targets = find(out==i);
            for x = reshape(targets,[1 length(targets)])
               r = 1 + mod(x-1,nrow);
               c = ceil(x/nrow);
               out(r,c) = rlabel;
            end
        end
        rlabel = rlabel + 1;
    end
end

function [result] = modifyeqv(arr)
    sz = size(arr);
    nrow = sz(1);
    ncol = sz(2);
    same = false;
    while same == false
       temp = arr;
       for i = 1:nrow
          temp(i,:) = arr(i,:);
          for j = 1:ncol
             if arr(i,j) == 1
                temp(i,:) = temp(i,:) | arr(j,:); 
             end
          end
       end
       if (isequal(arr,temp)) == true
           same = true;
       else
           arr = temp;
       end
    end
    result = arr;
end