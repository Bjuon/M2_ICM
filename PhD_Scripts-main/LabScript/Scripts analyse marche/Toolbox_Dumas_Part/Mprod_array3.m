function M3 = Mprod_array3 (M1,M2)

L1 = size (M1,1); % Number of line
C1 = size (M1,2); % Number of column
L2 = size (M2,1); % Number of line
C2 = size (M2,2); % Number of column
n = size (M1,3); % Number of frame

% Initilization
M3 = [];

if L1==1==C1==1 %(M1 is scalar)
        for i= 1:L2
            for j= 1:C2
                % element by element product (1*1*n)
                M3(i,j,:) = M1(1,1,:).*M2(i,j,:); 
            end
        end
elseif L2~=C1
    disp('M1 and M2 must be of compatible size')
else
    % transpose = permute ( , [2,1,3])
    M1t = permute (M1,[2,1,3]);
    for j=1:C2
        for i=1:L1
            % element by element product (1*1*n)
            M3(i,j,:) = dot (M1t(:,i,:), M2(:,j,:));
        end
    end
end