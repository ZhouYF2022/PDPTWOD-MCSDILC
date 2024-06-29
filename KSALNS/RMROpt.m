function [Solution,OrderSet] = RMROpt(Solution,Cnum,Parameter,Setting)
%RelationMatrix Removal
RMatrixNode = (1-Parameter.thetat)*Parameter.RM_Distance ...
            + (1-Parameter.thetat)*Parameter.RM_Location ...
            + 2*Parameter.thetat*Parameter.RMatrixEdge./Parameter.B;
[~,edgeindex] = sort(RMatrixNode(:));
[Orderi, Orderj] = ind2sub(size(RMatrixNode), edgeindex);
OrderSet = zeros(1,Parameter.PickOrder);
L = 0;
num = 1;
while L < Cnum
    Order1 = min(Orderi(num),Orderj(num));
    Order2 = max(Orderi(num),Orderj(num));
    if Order1 > Parameter.PickOrder
        Order1 = Order1 - Parameter.PickOrder;
    end
    if Order2 > Parameter.PickOrder
        Order2 = Order2 - Parameter.PickOrder;
    end
    if OrderSet(Order1)==0 && OrderSet(Order2)==0
        OrderSet([Order1 Order2]) = 1;
        L = L + 2;
    elseif OrderSet(Order1)==1 && OrderSet(Order2)==0
        OrderSet(Order2) = 1;
        L = L + 1;
    elseif OrderSet(Order1)==0 && OrderSet(Order2)==1
        OrderSet(Order1) = 1; 
        L = L + 1;
    end
    num = num + 1;
end
OrderSet = find(OrderSet>0);
OrderSetn = OrderSet + Parameter.PickOrder;
for i = 1:length(Solution)
    r = Solution(i).Routes;
    k = Solution(i).Kindex;
    if ~isempty(r)
        Newr = r(~ismember(r,[OrderSet OrderSetn]));
        if ~isequal(r,Newr)
            [Objs,Sik,SDis] = CalObjective(Newr,k,Parameter,Setting);
            Solution(i).Routes = Newr;
            Solution(i).Objs   = Objs;
            Solution(i).STime  = Sik;
            Solution(i).SDis   = SDis;
        end
    end
end
end

