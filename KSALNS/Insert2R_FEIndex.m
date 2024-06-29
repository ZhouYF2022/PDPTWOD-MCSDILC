function [minAddCost,NewR,minObjs,minSTime,minSDis] = Insert2R_FEIndex(Order1,r,k,FEIndex,Parameter,Setting)
switch FEIndex
    case 1 %Objective
        [minAddCost,NewR,minObjs,minSTime,minSDis] = Insert2R(Order1,r,k,Parameter,Setting);
    case 2 %Objective + rand noise from max arc
        [minAddCost,NewR,minObjs,minSTime,minSDis] = Insert2RNoise(Order1,r,k,Parameter,Setting);
    case 3 %Objective + Guide local search
        [minAddCost,NewR,minObjs,minSTime,minSDis] = Insert2RGLS(Order1,r,k,Parameter,Setting);
    case 4 %Objective + Tabu search
        [minAddCost,NewR,minObjs,minSTime,minSDis] = Insert2RTS(Order1,r,k,Parameter,Setting);
end


end