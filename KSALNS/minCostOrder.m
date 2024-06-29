function [minOrder1,mink,minCost,minSTime] = minCostOrder(OrderSet,Parameter)
for i = 1:length(OrderSet)
    Order1 = OrderSet(i);
    OD_Klist  = Parameter.OD_ctypelist{Order1}; %ODs first
    minCost   = Inf;
    minSTime  = Inf;
    mink      = Inf;
    minOrder1 = Inf;
    for kindex = 1:length(OD_Klist)
        k = OD_Klist(kindex);
        [Cost,STime] = CalObjective([Order1 Order1+Parameter.PickOrder],k,Parameter);
        if Cost < minCost && STime<=Parameter.TimeUp(k) && Parameter.MerCus_Demand(Order1)<=Parameter.Cap(k)
            minCost   = Cost;
            minSTime  = STime;
            mink      = k;
            minOrder1 = Order1;
        end
    end
    if minCost==Inf %RVs second
        RV_Klist = Parameter.RV_ctypelist{Order1};
        k = min(RV_Klist);
        [Cost,STime] = CalObjective([Order1 Order1+Parameter.PickOrder],k,Parameter);
        if Cost < minCost && STime<=Parameter.TimeUp(k) && Parameter.MerCus_Demand(Order1)<=Parameter.Cap(k)
            minCost   = Cost;
            minSTime  = STime;
            mink      = k;
            minOrder1 = Order1;
        end
    end
end

end