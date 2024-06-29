function  [Solution,Orderset] = WorstRouteROpt2(Solution,Cnum,Parameter,Setting)
IndexList  = zeros(1,length(Solution));
for i = 1:length(Solution)
    r = Solution(i).Routes;
    if ~isempty(r)
       IndexList(i) = Solution(i).SDis/length(r); 
    end
end
[~,rlist] = sort(IndexList,'descend');
rank  = max(1,floor(rand^Setting.alpha*length(rlist)));
deletk  = rlist(rank);
deletr  = Solution(deletk).Routes;
OrderSet = deletr(deletr<=Parameter.PickOrder);
Solution(deletk).Routes = [];
Solution(deletk).Objs   = 0;
Solution(deletk).STime  = 0;
Solution(deletk).SDis   = 0;
L = length(OrderSet);
if L<Cnum
    [Solution,NewOrderset] = RandROpt(Solution,Cnum-L,Parameter,Setting);
else
    NewOrderset = [];
end
Orderset = [OrderSet NewOrderset];

end