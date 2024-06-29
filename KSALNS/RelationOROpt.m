function  [Solution,OrderSet] = RelationOROpt(Solution,Cnum,Parameter,Setting)
%relation caculation
T_M   = zeros(2*Parameter.PickOrder,1);
for i = 1:length(Solution)
    r = Solution(i).Routes;
    if ~isempty(r)
        T_L = Solution(i).STime;
        T_M(r,:) = T_L;
    end
end
T_M2 = zeros(Parameter.PickOrder);
for i = 1:Parameter.PickOrder-1
   for j = i+1:Parameter.PickOrder
       if i~=j
           part2 = (abs(T_M(i)-T_M(j))+abs(T_M(i+Parameter.PickOrder)-T_M(j+Parameter.PickOrder)))/max(Parameter.TimeUp);
           T_M2(i,j) = part2;
       end
   end
end
T_M2 = T_M2 + T_M2';
Relation_M = Parameter.RM_Orders + T_M2;

%removal opt
OrderSet = zeros(1,Cnum);
Dik = zeros(length([Solution.Routes])/2,2);
L1 = 1;
for i = 1:length(Solution)
    r = Solution(i).Routes;
    L2 = L1 + length(r)/2 - 1;
    Dik(L1:L2,:) = [r(r<=Parameter.PickOrder)' repmat(i,length(r)/2,1)];
    L1 = L2 + 1;
end

for i =1:Cnum
    if i==1
        deletC = randperm(Parameter.PickOrder,1);
        OrderSet(i) = deletC;
        index  = Dik(:,1)==deletC;
        deletk = Dik(index,2);
        %Update Solution
        r = Solution(deletk).Routes;
        k = Solution(deletk).Kindex;
        Newr = r(~ismember(r,[deletC deletC+Parameter.PickOrder]));
        [Objs,STime,SDis] = CalObjective(Newr,k,Parameter,Setting);
        Solution(deletk).Routes = Newr;
        Solution(deletk).Objs   = Objs;
        Solution(deletk).STime  = STime;
        Solution(deletk).SDis   = SDis;
        Dik(Dik(:,1)==deletC,:) = [];
    else
        RCSet = OrderSet(OrderSet>0);
        Ci = RCSet(randperm(length(RCSet),1));
        [~,index] = sort(Relation_M(Ci,Dik(:,1)));
        rank  = max([1,floor(rand^Setting.alpha*size(Dik,1))]);
        deletC = Dik(index(rank),1);
        deletk = Dik(index(rank),2);
        OrderSet(i) = deletC;
        %Update Solution
        r = Solution(deletk).Routes;
        k = Solution(deletk).Kindex;
        Newr = r(~ismember(r,[deletC deletC+Parameter.PickOrder]));
        [Objs,STime,SDis] = CalObjective(Newr,k,Parameter,Setting);
        Solution(deletk).Routes = Newr;
        Solution(deletk).Objs   = Objs;
        Solution(deletk).STime  = STime;
        Solution(deletk).SDis   = SDis;
        Dik(Dik(:,1)==deletC,:) = [];
    end
end

end