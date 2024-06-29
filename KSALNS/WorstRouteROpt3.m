function  [Solution,OrderSet] = WorstRouteROpt3(Solution,Cnum,Parameter,Setting)
if length(Solution)>Parameter.ODnum
    RV_Routes = Solution(Parameter.ODnum+1:end).Routes;
    RV_OrderSet = RV_Routes(RV_Routes<=Parameter.PickOrder);
    num = length(RV_OrderSet);
    if num == Cnum
        for i = Parameter.ODnum+1:length(Solution)
            r = Solution(i).Routes;
            k = Solution(i).Kindex;
            Newr = r(~ismember(r,RV_Routes));
            if ~isequal(r,Newr)
                [Objs,Sik,SDis] = CalObjective(Newr,k,Parameter,Setting);
                Solution(i).Routes = Newr;
                Solution(i).Objs   = Objs;
                Solution(i).STime  = Sik;
                Solution(i).SDis   = SDis;
            end
        end
        OrderSet = RV_OrderSet;
    elseif num < Cnum
        for i = Parameter.ODnum+1:length(Solution)
            r = Solution(i).Routes;
            k = Solution(i).Kindex;
            Newr = r(~ismember(r,RV_Routes));
            if ~isequal(r,Newr)
                [Objs,Sik,SDis] = CalObjective(Newr,k,Parameter,Setting);
                Solution(i).Routes = Newr;
                Solution(i).Objs   = Objs;
                Solution(i).STime  = Sik;
                Solution(i).SDis   = SDis;
            end
        end
        [Solution,OD_OrderSet] = WorstROpt1(Solution,Cnum-num,Parameter,Setting);
        OrderSet = [OD_OrderSet RV_OrderSet];
    else
        OrderSet  = zeros(1,Cnum);
        for i = 1:Cnum
            DeCost = Reduction_Cost_RV(Solution,Parameter,Setting);
            [~,index] = sort(DeCost(:,3),'descend');
            rank  = max([1,floor(rand^Setting.alpha*size(DeCost,1))]);
            deletC = DeCost(index(rank),1);
            deletk = DeCost(index(rank),2);
            OrderSet(i) = deletC;
            r = Solution(deletk).Routes;
            k = Solution(deletk).Kindex;
            Newr = r(~ismember(r,[deletC deletC+Parameter.PickOrder]));
            [Objs,STime,SDis] = CalObjective(Newr,k,Parameter,Setting);
            Solution(deletk).Routes = Newr;
            Solution(deletk).Objs   = Objs;
            Solution(deletk).STime  = STime;
            Solution(deletk).SDis   = SDis;
        end
    end
else
    [Solution,OrderSet] = WorstROpt1(Solution,Cnum,Parameter,Setting);
end

end

function  DeCost = Reduction_Cost_RV(Solution,Parameter,Setting)
Routes = [Solution(Parameter.ODnum+1:end).Routes];
DeCost = zeros(length(Routes)/2,3);
L = 0;
for i = Parameter.ODnum+1:length(Solution)
    r = Solution(i).Routes;
    k = Solution(i).Kindex;
    Objs = Solution(i).Objs;
    Orderlist = r(r<=Parameter.PickOrder);
    for j = 1:length(Orderlist)
        deletC = Orderlist(j);
        Newr   = setdiff(r,[deletC deletC+Parameter.PickOrder],'stable');
        Cost_C =  Objs - CalObjective(Newr,k,Parameter,Setting);
        L = L + 1;
        DeCost(L,:) = [deletC i Cost_C];
    end
end
end