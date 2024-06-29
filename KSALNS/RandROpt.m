function  [Solution,OrderSet] = RandROpt(Solution,Cnum,Parameter,Setting)
Routes = [Solution.Routes];
RoutesOrderSet = Routes(Routes<=Parameter.PickOrder);
OrderSet  = RoutesOrderSet(randperm(length(RoutesOrderSet),Cnum));
OrderSetn = OrderSet + Parameter.PickOrder;
for i = 1:length(Solution)
    r = Solution(i).Routes;
    k = Solution(i).Kindex;
    if ~isempty(r)
        Newr = r(~ismember(r,[OrderSet OrderSetn]));
        if ~isequal(r,Newr)
            [Objs,Sik,SDis] = CalObjective(Newr,k,Parameter,Setting);
            Solution(i).Routes = Newr;
            Solution(i).Objs   = Objs;
            Solution(i).STime  = Sik;
            Solution(i).SDis   = SDis;
        end
    end
end

end