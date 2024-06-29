function [Solution,Objs] = OPIOpt(Solution,OrderSet,FEIndex,Parameter,Setting)
%Order priority insert
[Fik,Tik] = AddTimeTik(OrderSet,Solution,FEIndex,Parameter,Setting);
while ~isempty(OrderSet)
    L = length(OrderSet);
    maxTimeVlue = -inf;
    for i = 1:L
        [NewAddObjs,kindex] = min(Fik(i,:));
        k = Solution(kindex).Kindex;
        if NewAddObjs == Inf % 增加新的车辆
            RlistRV = Parameter.RV_ctypelist{OrderSet(i)};
            klistRV = setdiff(RlistRV,[Solution.Kindex]);
            k = klistRV(1);
            kindex = length(Solution) + 1;
            r = [];
            [~,~,~,STime] = Insert2R_FEIndex(OrderSet(i),r,k,FEIndex,Parameter,Setting);
            TimeValue = Parameter.Bi(OrderSet(i) + Parameter.PickOrder) - STime(end);
        else
            TimeValue = Tik(i,kindex);  %TimeValue
        end
        if TimeValue > maxTimeVlue
            maxTimeVlue = TimeValue;
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
        [Fik,Tik] = UpdateTimeTik(InsertiIndex,Insertkindex,Fik,Tik,OrderSet,Solution,FEIndex,Parameter,Setting);
    end
end
Objs = sum([Solution.Objs]);
end

function [Fik,Tik] = AddTimeTik(OrderSet,Solution,FEIndex,Parameter,Setting)
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
        [AddCost,NewR,~,T_L] = Insert2R_FEIndex(Order1,r,k,FEIndex,Parameter,Setting);        
        Fik(i,kindex) = AddCost;
        if AddCost ~= Inf
            tin = T_L(NewR==Order1+Parameter.PickOrder);
            Tik(i,kindex) = Parameter.Bi(Order1+Parameter.PickOrder) - tin + T_L(end) - tin;
        end
    end
end

end


function [Fik,Tik] = UpdateTimeTik(InsertIndex,Insertkindex,Fik,Tik,OrderSet,Solution,FEIndex,Parameter,Setting)
Fik(InsertIndex,:) = [];
Tik(InsertIndex,:) = [];
[inum,knum] = size(Fik);
r   = Solution(Insertkindex).Routes;
k   = Solution(Insertkindex).Kindex;
if Insertkindex > knum
    Fik = [Fik Inf(inum,1)];
    for i = 1:inum
        Order1 = OrderSet(i);
        Rlist = Parameter.ctypelist{Order1};
        if ismember(k,Rlist)
            [AddCost,NewR,~,T_L] = Insert2R_FEIndex(Order1,r,k,FEIndex,Parameter,Setting);
            Fik(i,Insertkindex) = AddCost;
            if AddCost~=Inf
                tin = T_L(NewR==Order1+Parameter.PickOrder);
                Tik(i,Insertkindex) = Parameter.Bi(Order1+Parameter.PickOrder) - tin + T_L(end) - tin;
            end
        end
    end
else
    for i = 1:inum
        Order1 = OrderSet(i);
        Rlist = Parameter.ctypelist{Order1};
        if ismember(k,Rlist)
            [AddCost,NewR,~,T_L] = Insert2R_FEIndex(Order1,r,k,FEIndex,Parameter,Setting);
            Fik(i,Insertkindex) = AddCost;
            if AddCost~=Inf
                tin = T_L(NewR==Order1+Parameter.PickOrder);
                Tik(i,Insertkindex) = Parameter.Bi(Order1+Parameter.PickOrder) - tin + T_L(end) - tin;
            end
        end
    end
end


end