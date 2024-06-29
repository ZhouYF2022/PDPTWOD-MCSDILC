function Eij = Order_Priority(Parameter)
%% Space_time distance
ST_Matrix = Parameter.ST_Matrix;

%% Order Priority
Eij = Inf(Parameter.PickOrder,Parameter.PickOrder);
PickNum = Parameter.PickOrder;
for i = 1:PickNum
    for j = 1:PickNum
        if i == j
            continue
        else
            Eij1 = ST_Matrix(i,i+PickNum) + ST_Matrix(i+PickNum,j) + ST_Matrix(j,j+PickNum);
            Eij2 = ST_Matrix(i,j) + ST_Matrix(j,i+PickNum) + ST_Matrix(i+PickNum,j+PickNum);
            Eij3 = ST_Matrix(i,j) + ST_Matrix(j,j+PickNum) + ST_Matrix(j+PickNum,i+PickNum);
            Eij(i,j) = min([Eij1,Eij2,Eij3]);
        end
    end
end

end