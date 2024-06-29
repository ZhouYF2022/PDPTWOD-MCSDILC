function  [Solution,Objs] = WeightIOpt(Solution,OrderSet,W,FEIndex,Parameter,Setting)
%Weight Insert
[Fik,Tik] = AddCostFikWeight(OrderSet,Solution,FEIndex,Parameter,Setting); %minAddCost
while ~isempty(OrderSet)
    L = length(OrderSet);
    minWeightCost = Inf;
    for i = 1:L
        [NewAddObjs,kindex] = min(Fik(i,:)); %minCost
        k = Solution(kindex).Kindex;
        if NewAddObjs == Inf % 增加新的车辆
            RlistRV = Parameter.RV_ctypelist{OrderSet(i)};
            klistRV = setdiff(RlistRV,[Solution.Kindex]);
            k = klistRV(1);
            NewWeightCost = Insert2R_FEIndex(OrderSet(i),[],k,FEIndex,Parameter,Setting);
            kindex = length(Solution) + 1;
        else
            kIndexlist = find(Fik(i,:)~=Inf);
            knum = length(kIndexlist);
            Regretlist = sort(Fik(i,kIndexlist)- min(Fik(i,kIndexlist)));
            RegretValue = sum(Regretlist(1:min(knum,2))); %RegretValue2  %maxRegret
            WeightCostlist = W(1)*Fik(i,kIndexlist) - W(2)*RegretValue + W(3)*Tik(i,kIndexlist);
            NewWeightCost = min(WeightCostlist);
        end
        if NewWeightCost < minWeightCost
            minWeightCost = NewWeightCost;
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
        [Fik,Tik] = UpdateFikWeight(InsertiIndex,Insertkindex,Fik,Tik,OrderSet,Solution,FEIndex,Parameter,Setting);
    end
end
Objs = sum([Solution.Objs]);
end

function [Fik,Tik] = AddCostFikWeight(OrderSet,Solution,FEIndex,Parameter,Setting)
Fik = inf(length(OrderSet),length(Solution));
Tik = inf(length(OrderSet),length(Solution));
kindexlist = [Solution.Kindex];
for i = 1:length(OrderSet)
    Order1 = OrderSet(i);
    Rlist = Parameter.ctypelist{Order1};
    klist = Rlist(ismember(Rlist,kindexlist));
    for j = 1:length(klist)
        kindex = find(kindexlist==klist(j));
        k = Solution(kindex).Kindex;
        r = Solution(kindex).Routes;
        [AddCost,~,~,STime,~] = Insert2R_FEIndex(Order1,r,k,FEIndex,Parameter,Setting);
        Fik(i,kindex) = AddCost;
        Tik(i,kindex) = STime(end);
    end
end
end

function [Fik,Tik] = UpdateFikWeight(InsertIndex,Insertkindex,Fik,Tik,OrderSet,Solution,FEIndex,Parameter,Setting)
Fik(InsertIndex,:) = [];
Tik(InsertIndex,:) = [];
[inum,knum] = size(Fik);
r   = Solution(Insertkindex).Routes;
k   = Solution(Insertkindex).Kindex;
if Insertkindex > knum
    Fik = [Fik Inf(inum,1)];
    Tik = [Tik Inf(inum,1)];
    for i = 1:inum
        Order1 = OrderSet(i);
        Rlist = Parameter.ctypelist{Order1};
        if ismember(k,Rlist)
            [AddCost,~,~,STime,~] = Insert2R_FEIndex(Order1,r,k,FEIndex,Parameter,Setting);
            Fik(i,Insertkindex) = AddCost;
            Tik(i,Insertkindex) = STime(end);
        end
    end
else
    for i = 1:inum
        Order1 = OrderSet(i);
        Rlist = Parameter.ctypelist{Order1};
        if ismember(k,Rlist)
            [AddCost,~,~,STime,~] = Insert2R_FEIndex(Order1,r,k,FEIndex,Parameter,Setting);
            Fik(i,Insertkindex) = AddCost;
            Tik(i,Insertkindex) = STime(end);
        end
    end
end


end