function ST_Matrix = ST_Distance(N,SD_Matrix,Ai,Bi,SiTime)
% Space-Time distance 
TD_Matrix = zeros(N,N); 
for i = 1:N
    for j = 1:N
        if i==j
            continue
        else
            ETi = Ai(i); LTi = Bi(i);
            ETj = Ai(j); LTj = Bi(j); 
            Tij = SD_Matrix(i,j);
            Si  = SiTime(i);   
            a = ETi + Tij + Si;
            b = LTi + Tij + Si;
            if b < ETj
                TD_Matrix(i,j) = 1.8*(ETj-b);     %The punishment of waiting
            elseif a > LTj
                TD_Matrix(i,j) = 2*(a - LTj);     %The punishment of being late
            elseif (ETj < a) && (LTj > b)
                TD_Matrix(i,j) = Tij + Si;    
            else
                TD_Matrix(i,j) = 1.5*(Tij + Si);  %The punishment of deviation
            end 
        end
    end 
end

% Normolization
SD_Matrix = (SD_Matrix-repmat(min(SD_Matrix(:)),N,N))./(repmat(max(SD_Matrix(:)),N,N)-repmat(min(SD_Matrix(:)),N,N));
TD_Matrix = (TD_Matrix-repmat(min(TD_Matrix(:)),N,N))./(repmat(max(TD_Matrix(:)),N,N)-repmat(min(TD_Matrix(:)),N,N));
ST_Matrix = 0.5*SD_Matrix + 0.5*TD_Matrix;
end