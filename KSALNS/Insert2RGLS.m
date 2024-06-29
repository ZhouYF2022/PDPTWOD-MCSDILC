function [minAddCost,NewR,minObj,minSTime,minSDis] = Insert2RGLS(Order1,r,k,Parameter,Setting)
if isempty(r)
    NewR = [Order1 Order1+Parameter.PickOrder];
    [NewObjs,NewSTime,NewSDis] = CalObjective(NewR,k,Parameter,Setting);
    R_Q = cumsum(Parameter.MerCus_Demand(NewR));
    if all(R_Q<=Parameter.Cap(k),'all') && NewSDis <= Parameter.TimeUp(k)
        PenaltyValue1 = GlsPenaltyValue(NewR,k,Parameter,Setting);
        minAddCost = NewObjs + PenaltyValue1;
        minObj     = NewObjs;
        minSTime   = NewSTime;
        minSDis    = NewSDis;
    else
        minAddCost = Inf;
        minObj     = 0;
        minSTime   = 0;
        minSDis    = 0;
    end
else
    NewR = r;
    minAddCost = Inf;
    minObj    = 0;
    minSTime   = 0;
    minSDis    = 0;
    NewC = Parameter.Customers2Orders(r);
    NewC1 = unique(NewC,'stable');
    indexC1 = find(NewC==Parameter.Customers2Orders(Order1),1,'last');
    if isempty(indexC1)
        for j1 = 0:length(NewC1)
            if j1==0
                Pos1 = 0;
            else
                Pos1 = find(NewC==NewC1(j1),1,'last');
            end
            for j2 = j1:length(NewC1)
                if j2 == 0
                    Pos2 = 0;
                else
                    Pos2 = find(NewC==NewC1(j2),1,'last');
                end
                Newr = [r(1:Pos1),Order1,r(Pos1+1:Pos2),Order1+Parameter.PickOrder,r(Pos2+1:end)];
                [NewObj,NewSTime,NewSDis] = CalObjective(Newr,k,Parameter,Setting);
                R_Q = cumsum(Parameter.MerCus_Demand(Newr));
                if all(R_Q<=Parameter.Cap(k),'all') && NewSDis <= Parameter.TimeUp(k)
                    AddCost =  NewObj + GlsPenaltyValue(Newr,k,Parameter,Setting) - (CalObjective(r,k,Parameter,Setting) + GlsPenaltyValue(r,k,Parameter,Setting));
                    if AddCost < minAddCost
                        minAddCost = AddCost;
                        NewR = Newr;
                        minObj = NewObj;
                        minSTime = NewSTime;
                        minSDis  = NewSDis;
                    end
                end
            end
        end
    else
        indexC2 = find(NewC==Parameter.Customers2Orders(Order1)+Parameter.PickCustomer,1,'last');
        Newr = [r(1:indexC1),Order1,r(indexC1+1:indexC2),Order1+Parameter.PickOrder,r(indexC2+1:end)];
        R_Q = cumsum(Parameter.MerCus_Demand(Newr));
        if all(R_Q<=Parameter.Cap(k),'all')
            minAddCost =  GlsPenaltyValue(Newr,k,Parameter,Setting);
            NewR = Newr;
            [minObj,minSTime,minSDis] = CalObjective(NewR,k,Parameter,Setting);
        end
    end
end
end

function PenaltyValue = GlsPenaltyValue(r,k,Parameter,Setting)
PenaltyValue = 0;
ODnum = Parameter.ODnum;
if k<=ODnum
    for i = 1:length(r)-1
        if i == 1
            PenaltyValue = PenaltyValue + Setting.Kxi(2)*Parameter.pij(2*Parameter.PickOrder+k,r(i))*Parameter.LCost;
        else
            PenaltyValue = PenaltyValue + Setting.Kxi(2)*Parameter.pij(r(i-1),r(i))*Parameter.LCost;
        end
        if r(i) <= Parameter.PickOrder
            PenaltyValue = PenaltyValue + Setting.Kxi(2)*Parameter.pij2(r(i),k)*Parameter.OrderCost;
        end
    end
else
    for i = 1:length(r)+1
        if i == 1
            PenaltyValue = PenaltyValue + Setting.Kxi(2)*Parameter.pij(2*Parameter.PickOrder+ODnum+1,r(i))*Parameter.LCost;
            if r(i) <= Parameter.PickOrder
                PenaltyValue = PenaltyValue + Setting.Kxi(2)*Parameter.pij2(r(i),ODnum+1)*Parameter.OrderCost;
            end
        elseif i == length(r)+1
            PenaltyValue = PenaltyValue + Setting.Kxi(2)*Parameter.pij(r(i-1),2*Parameter.PickOrder+ODnum+1)*Parameter.LCost;
        else
            PenaltyValue = PenaltyValue + Setting.Kxi(2)*Parameter.pij(r(i-1),r(i))*Parameter.LCost;
            if r(i) <= Parameter.PickOrder
                PenaltyValue = PenaltyValue + Setting.Kxi(2)*Parameter.pij2(r(i),ODnum+1)*Parameter.OrderCost;
            end
        end
    end
end
end
