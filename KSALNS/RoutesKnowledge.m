function Parameter = RoutesKnowledge(Solution,Objs,Parameter,Setting)
dmax = 0;
Lnum = 0;
OrderCost = 0;
for i = 1:length(Solution)
    r = Solution(i).Routes;
    if ~isempty(r)
        k = Solution(i).Kindex;
        if k <= Parameter.ODnum
            for j = 1:length(r)-1
                if j == 1
                    darc = Parameter.S2M(k,r(j));
                    Lnum = Lnum + 1;
                else
                    darc = Parameter.M2C(r(j-1),r(j));
                    Lnum = Lnum + 1;
                end
                if darc >= dmax
                    dmax = darc;
                end
                if r(j) <= Parameter.PickOrder
                    Newr = r(~ismember(r,[r(j) r(j)+Parameter.PickOrder]));
                    OrderCost = OrderCost + Solution(i).Objs - CalObjective(Newr,k,Parameter,Setting); 
                end
            end
        else
            for j = 1:length(r)+1
                if j == 1
                    darc = Parameter.RV_S2M(r(j));
                    Lnum = Lnum + 1;
                    if r(j) <= Parameter.PickOrder
                        Newr = r(~ismember(r,[r(j) r(j)+Parameter.PickOrder]));
                        OrderCost = OrderCost + Solution(i).Objs - CalObjective(Newr,k,Parameter,Setting); 
                    end
                elseif j == length(r)+1
                    darc = Parameter.RV_S2M(r(j-1));
                    Lnum = Lnum + 1;
                else
                    darc = Parameter.M2C(r(j-1),r(j));
                    Lnum = Lnum + 1;
                    if r(j) <= Parameter.PickOrder
                        Newr = r(~ismember(r,[r(j) r(j)+Parameter.PickOrder]));
                        OrderCost = OrderCost + Solution(i).Objs - CalObjective(Newr,k,Parameter,Setting); 
                    end
                end
                if darc >= dmax
                   dmax = darc;
                end
            end
        end
    end
end
Parameter.dmax = dmax; %The noise  is determined by the length of the longest arc (dmax) 

LCost = Objs / Lnum; 
OrderCost = OrderCost / Parameter.PickOrder;
Parameter.LCost = LCost;  %Average costs for arcs in GLS
Parameter.OrderCost = OrderCost;  %Average reduction costs for removal Order in GLS


end