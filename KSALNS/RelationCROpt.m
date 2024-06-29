function  [Solution,OrderSet] = RelationCROpt(Solution,Cnum,Parameter,Setting)
%relation caculation
T_M   = zeros(Parameter.PickCustomer);
for i = 1:length(Solution)
    r = Solution(i).Routes;
    k = Solution(i).Kindex;
    if ~isempty(r)
        Order = r(r<=Parameter.PickOrder);
        NewC = Parameter.Customers2Orders(Order);
        for j1 = 1:length(NewC)
            u = NewC(j1);
            uindex = NewC(1:j1-1)== u;
            if all(uindex==0)
                for j2 = j1+1:length(NewC)
                    v = NewC(j2);
                    vindex = NewC(1:j2-1)== v;
                    if all(vindex==0)
                        T_M(u,v) = T_M(u,v) + 1;
                        T_M(v,u) = T_M(v,u) + 1;
                    end
                end
            end
        end
    end
end
Relation_M = Parameter.RM_Customers - T_M/max(max(T_M(:)));

%removal opt
OrderSet = zeros(1,Parameter.PickOrder);
Cindex   = zeros(1,Parameter.PickCustomer);
Dik = zeros(length([Solution.Routes])/2,2);
L1 = 1;
for i = 1:length(Solution)
    r = Solution(i).Routes;
    L2 = L1 + length(r)/2 - 1;
    Dik(L1:L2,:) = [r(r<=Parameter.PickOrder)' repmat(i,length(r)/2,1)];
    L1 = L2 + 1;
end

L = 0;
while L < Cnum
    if L==0
        deletC = randperm(Parameter.PickCustomer,1);
        deletOrder = find(Parameter.Customers2Orders==deletC)';
        OrderSet(deletOrder) = 1;
        Cindex(deletC) = 1;
        for i = 1:length(Solution)
            r = Solution(i).Routes;
            k = Solution(i).Kindex;
            Newr = r(~ismember(r,[deletOrder deletOrder+Parameter.PickOrder]));
            if ~isequal(r,Newr)
                [Objs,Sik,SDis] = CalObjective(Newr,k,Parameter,Setting);
                Solution(i).Routes = Newr;
                Solution(i).Objs   = Objs;
                Solution(i).STime  = Sik;
                Solution(i).SDis   = SDis;
            end
        end
        L = L + length(deletOrder);   
    else
        Cset = find(Cindex>0);
        Ci = Cset(randperm(length(Cset),1));
        Picklist = find(Cindex==0);
        [~,index] = sort(Relation_M(Ci,Picklist));
        Picklist = Picklist(index);
        rank  = max(1,floor(rand^Setting.alpha*length(Picklist)));
        deletC = Picklist(rank);
        Cindex(deletC) = 1;
        deletOrder = find(Parameter.Customers2Orders==deletC)';
        OrderSet(deletOrder) = 1;
        %Update Routes
        for i = 1:length(Solution)
            r = Solution(i).Routes;
            k = Solution(i).Kindex;
            Newr = r(~ismember(r,[deletOrder deletOrder+Parameter.PickOrder]));
            if ~isequal(r,Newr)
                [Objs,Sik,SDis] = CalObjective(Newr,k,Parameter,Setting);
                Solution(i).Routes = Newr;
                Solution(i).Objs   = Objs;
                Solution(i).STime  = Sik;
                Solution(i).SDis   = SDis;
            end
        end
        L = L + length(deletOrder);
    end
end
OrderSet = find(OrderSet>0);
end