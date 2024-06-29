    function  [Solution,Cset] = RemovalOPT(Cnum,Solution,RemovalIndex,Parameter,Setting)
switch RemovalIndex
    case 1 %Rand removal
        [Solution,Cset] = RandROpt(Solution,Cnum,Parameter,Setting);
    case 2 %Worst objs removal
        [Solution,Cset] = WorstROpt1(Solution,Cnum,Parameter,Setting);
    case 3 %Worst distance removal
        [Solution,Cset] = WorstROpt2(Solution,Cnum,Parameter,Setting);
    case 4 %relation removal for orders
        [Solution,Cset] = RelationOROpt(Solution,Cnum,Parameter,Setting);
    case 5 %relation removal for customers
        [Solution,Cset] = RelationCROpt(Solution,Cnum,Parameter,Setting);
    case 6 %Routes removal for  max objs routes
        [Solution,Cset] = WorstRouteROpt1(Solution,Cnum,Parameter,Setting);
    case 7 %Routes removal for max distance routes
        [Solution,Cset] = WorstRouteROpt2(Solution,Cnum,Parameter,Setting);  
    case 8 %Remove RVs service customers from knowledge
        [Solution,Cset] = WorstRouteROpt3(Solution,Cnum,Parameter,Setting);
    case 9 %Remove Order by RMatrix1 from adjacent edge knowledge 
        [Solution,Cset] = RMROpt(Solution,Cnum,Parameter,Setting);
    case 10 %Remove Order from serach knowledge of Order priority
        [Solution,Cset] = OPROpt(Solution,Cnum,Parameter,Setting);
end
%Remove not be used RVs 
if length(Solution)>Parameter.ODnum
    Deletk = zeros(1,length(Solution)-Parameter.ODnum);
    for i = Parameter.ODnum+1:length(Solution)
        r = Solution(i).Routes;
        if isempty(r)
            Deletk(i-Parameter.ODnum) = i;
        end
    end
    Solution(Deletk(Deletk~=0)) = [];
end
end

