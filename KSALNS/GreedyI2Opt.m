function  [Solution,Objs] = GreedyI2Opt(Solution,OrderSet,FEIndex,Parameter,Setting)
%Greedy Insert
Fik = AddCostFik(OrderSet,Solution,FEIndex,Parameter,Setting);
while ~isempty(OrderSet)
    L = length(OrderSet);
    minAddNewObjs = Inf;
    for i = 1:L
        [NewAddObjs,kindex] = min(Fik(i,:));
        k = Solution(kindex).Kindex;
        if NewAddObjs == Inf % 增加新的车辆
            RlistRV = Parameter.RV_ctypelist{OrderSet(i)};
            klistRV = setdiff(RlistRV,[Solution.Kindex]);
            k = klistRV(1);
            r = [];
            NewAddObjs = Insert2R_FEIndex(OrderSet(i),r,k,FEIndex,Parameter,Setting);
            kindex = length(Solution) + 1;
        end
        if NewAddObjs < minAddNewObjs
            minAddNewObjs = NewAddObjs;
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