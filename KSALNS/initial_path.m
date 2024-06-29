function [Solution,Objs] = initial_path(Parameter,Setting)
Solution = struct('Kindex',cell(1,Parameter.ODnum),...
                  'Routes', cell(1,Parameter.ODnum),...
                  'Objs',cell(1,Parameter.ODnum),...
                  'STime',cell(1,Parameter.ODnum),...
                  'SDis',cell(1,Parameter.ODnum));
for i = 1:Parameter.ODnum
    Solution(i).Kindex = i;
    Solution(i).Objs   = 0;
    Solution(i).STime  = 0;
    Solution(i).SDis   = 0;
end

%% Weighting Insert
% tic
Weight= [0 0.2 0.4 0.6 0.8 1];
WeightList = [];
for i = 1:length(Weight)
    for j = 1:length(Weight)
        for k = 1:length(Weight)
            if Weight(i) + Weight(j) + Weight(k) == 1
                WeightList(end+1,:) = [Weight(i) Weight(j) Weight(k)];
            end
        end
    end
end
%minObjs Solution
minObjs     = Inf;
for i = 1:size(WeightList,1)
    W = WeightList(i,:);
    FEIndex = 1;
    OrderSet = 1:Parameter.PickOrder;
    [NewSolution,NewObjs] = WeightIOpt(Solution,OrderSet,W,FEIndex,Parameter,Setting);
    if NewObjs < minObjs
        Solution_Weight = NewSolution;
        minObjs = NewObjs;
    end
end
%toc
Solution = Solution_Weight;
Objs = minObjs;
end