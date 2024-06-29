function  [Solution,OrderSet] = WorstROpt2(Solution,Cnum,Parameter,Setting)
OrderSet   = zeros(1,Cnum);
for i = 1:Cnum
    DeCost = Reduction_Cost(Solution,Parameter,Setting);
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


function  DeCost = Reduction_Cost(Solution,Parameter,Setting)
Routes = [Solution.Routes];
DeCost = zeros(length(Routes)/2,3);
L = 0;
for i = 1:length(Solution)
    r = Solution(i).Routes;
    k = Solution(i).Kindex;
    Dis = Solution(i).SDis;
    Orderlist = r(r<=Parameter.PickOrder);
    for j = 1:length(Orderlist)
        deletC = Orderlist(j);
        Newr   = setdiff(r,[deletC deletC+Parameter.PickOrder],'stable');
        [~,~,NewDis] = CalObjective(Newr,k,Parameter,Setting);
        Dis_C =  Dis - NewDis;
        L = L + 1;
        DeCost(L,:) = [deletC i Dis_C];
    end
end
end