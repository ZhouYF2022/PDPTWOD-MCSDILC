function [Solution,OrderSet] = OPROpt(Solution,Cnum,Parameter,Setting)
%Order priority removal
T_M   = zeros(2*Parameter.PickOrder,1);
for i = 1:length(Solution)
    r = Solution(i).Routes;
    k = Solution(i).Kindex;
    if ~isempty(r)
        T_L = CalObjT(r,k,Parameter);
        T_M(r,:) = T_L;
    end
end
Eij = Inf(Parameter.PickOrder);
for i = 1:Parameter.PickOrder
    Order1n = i + Parameter.PickOrder;
    for j = 1:Parameter.PickOrder
        if i ~= j
            Order2n = j + Parameter.PickOrder;
            if T_M(i) <= T_M(j) && T_M(Order1n) <= T_M(j)
                Eij(i,j) = (T_M(i)+ Parameter.M2C(i,Order1n) + Parameter.M2C(Order1n,j))/Parameter.Bi(j)...
                        + (T_M(Order1n) + Parameter.M2C(Order1n,j) + Parameter.M2C(j,Order2n))/Parameter.Bi(Order2n);
            elseif T_M(i) <= T_M(j) && T_M(j)< T_M(Order1n) && T_M(Order1n) <= T_M(j+Parameter.PickOrder)
                Eij(i,j) = (T_M(i)+ Parameter.M2C(i,j))/Parameter.Bi(j)...
                    +(T_M(Order1n) + Parameter.M2C(Order1n,Order2n))/Parameter.Bi(Order2n);
            elseif T_M(i) <= T_M(j) && T_M(Order1n) > T_M(Order2n)
                Eij(i,j) = (T_M(i)+ Parameter.M2C(i,j))/Parameter.Bi(j)...
                    +T_M(Order1n)/Parameter.Bi(Order2n);
            elseif T_M(i) > T_M(j) && T_M(Order1n) <= T_M(Order2n)
                Eij(i,j) = T_M(i)/Parameter.Bi(j)...
                    + (T_M(Order1n) + Parameter.M2C(Order1n,Order2n))/Parameter.Bi(Order2n);
            else
                Eij(i,j) = T_M(i)/Parameter.Bi(j) + T_M(Order1n)/Parameter.Bi(Order2n);
            end
        end
    end
end
%removal opt
OrderSet   = zeros(1,Cnum);
Dik = zeros(length([Solution.Routes])/2,2);
L1 = 1;
for i = 1:length(Solution)
    r = Solution(i).Routes;
    L2 = L1 + length(r)/2 - 1;
    Dik(L1:L2,:) = [r(r<=Parameter.PickOrder)' repmat(i,length(r)/2,1)];
    L1 = L2 + 1;
end
for i =1:Cnum
    if i==1
        deletC = randperm(Parameter.PickOrder,1);
        OrderSet(i) = deletC;
        index  = Dik(:,1)==deletC;
        deletk = Dik(index,2);
        %Update Solution
        r = Solution(deletk).Routes;
        k = Solution(deletk).Kindex;
        Newr = r(~ismember(r,[deletC deletC+Parameter.PickOrder]));
        [Objs,STime,SDis] = CalObjective(Newr,k,Parameter,Setting);
        Solution(deletk).Routes = Newr;
        Solution(deletk).Objs   = Objs;
        Solution(deletk).STime  = STime;
        Solution(deletk).SDis   = SDis;
        Dik(Dik(:,1)==deletC,:) = [];
    else
        RCSet = OrderSet(OrderSet>0);
        Ci = RCSet(randperm(length(RCSet),1));
        [~,index] = sort(Eij(Ci,Dik(:,1)));
        rank  = max([1,floor(rand^Setting.alpha*size(Dik,1))]);
        deletC = Dik(index(rank),1);
        deletk = Dik(index(rank),2);
        OrderSet(i) = deletC;
        %Update Solution
        r = Solution(deletk).Routes;
        k = Solution(deletk).Kindex;
        Newr = r(~ismember(r,[deletC deletC+Parameter.PickOrder]));
        [Objs,STime,SDis] = CalObjective(Newr,k,Parameter,Setting);
        Solution(deletk).Routes = Newr;
        Solution(deletk).Objs   = Objs;
        Solution(deletk).STime  = STime;
        Solution(deletk).SDis   = SDis;
        Dik(Dik(:,1)==deletC,:) = [];
    end
end
end

