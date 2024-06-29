function Fik = AddCostFik(OrderSet,Solution,FEIndex,Parameter,Setting)
Fik = inf(length(OrderSet),length(Solution));
kindexlist = [Solution.Kindex];
for i = 1:length(OrderSet)
    Order1 = OrderSet(i);
    Rlist = Parameter.ctypelist{Order1};
    klist = Rlist(ismember(Rlist,kindexlist));
    for j = 1:length(klist)
        kindex = find(kindexlist==klist(j));
        k = Solution(kindex).Kindex;
        r = Solution(kindex).Routes;
        AddCost = Insert2R_FEIndex(Order1,r,k,FEIndex,Parameter,Setting);
        Fik(i,kindex) = AddCost;
    end
end

end