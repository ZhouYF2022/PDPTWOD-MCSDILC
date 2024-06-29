function  [Solution,Objs] = RandIOpt(Solution,OrderSet,FEIndex,Parameter,Setting)
%rank Insert k
Fik = AddCostFik(OrderSet,Solution,FEIndex,Parameter,Setting);
while ~isempty(OrderSet)
    L = length(OrderSet);
    InsertiIndex = randperm(L,1);
    Inserti = OrderSet(InsertiIndex);
    kIndexlist = find(Fik(InsertiIndex,:)~=Inf);
    if isempty(kIndexlist)
        RlistRV = Parameter.RV_ctypelist{Inserti};
        klistRV = setdiff(RlistRV,[Solution.Kindex]);
        Insertkindex = length(Solution) + 1;
        Insertk = klistRV(1);
    else
        Insertkindex = kIndexlist(randperm(length(kIndexlist),1));
        Insertk = Solution(Insertkindex).Kindex;
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