function  [Solution,Objs] = RegretkIOpt(Solution,OrderSet,FEIndex,Parameter,Setting)
%Regret k Insert
Fik = AddCostFik(OrderSet,Solution,FEIndex,Parameter,Setting);
while ~isempty(OrderSet)
    maxRegretValue = -1;
    for i = 1:length(OrderSet)
        [NewAddObjs,kindex] = min(Fik(i,:));
        k = Solution(kindex).Kindex;
        if NewAddObjs == Inf
            RlistRV = Parameter.RV_ctypelist{OrderSet(i)};
            klistRV = setdiff(RlistRV,[Solution.Kindex]);
            k = klistRV(1);
            kindex = length(Solution) + 1;
            RegretValue = 0;
        else
            kIndexlist = find(Fik(i,:)~=Inf);
            Regretlist = sort(Fik(i,kIndexlist)- min(Fik(i,kIndexlist)));
            RegretValue = sum(Regretlist); %RegretValuek
        end
        if RegretValue > maxRegretValue
            maxRegretValue = RegretValue;
            InsertiIndex = i;
            Inserti = OrderSet(i);
            Insertkindex = kindex;
            Insertk  = k;
        end
    end
    if Insertkindex > length(Solution)
        r = [];
        [~,Routes,Objs,STime,SDis] = Insert2R_FEIndex(Inserti,r,Insertk,FEIndex,Parameter,Setting);
    else
        r = Solution(Insertkindex).Routes;
        [~,Routes,Objs,STime,SDis] = Insert2R_FEIndex(Inserti,r,Insertk,FEIndex,Parameter,Setting);
    end
    Solution(Insertkindex).Kindex = Insertk;
    Solution(Insertkindex).Routes = Routes;
    Solution(Insertkindex).Objs   = Objs;
    Solution(Insertkindex).STime  = STime;
    Solution(Insertkindex).SDis   = SDis;
    
    %Update OrderSet
    OrderSet(OrderSet==Inserti) = [];
    %Update Fik
    if ~isempty(OrderSet)
        Fik = UpdateFik(InsertiIndex,Insertkindex,Fik,OrderSet,Solution,FEIndex,Parameter,Setting);
    end
end
Objs = sum([Solution.Objs]);
end
