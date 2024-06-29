function RMatrixEdge = RMatrix(B_Solution,Parameter)
N = 2*Parameter.PickOrder;
%Part1: Dismax - Disij and Part2: betaij and Part3: commom arc
RMatrixEdge = zeros(N);
for i = 1:size(B_Solution,1)
    Solution = B_Solution{i,1};
    if ~isempty(Solution)
        for j = 1:length(Solution)
            r = Solution(j).Routes;
            for l = 1:length(r)-1
                RMatrixEdge(r(l),r(l+1)) = RMatrixEdge(r(l),r(l+1)) + 1;
            end
        end
    end
end
% RMatrixNode = (1-Parameter.thetat)*Parameter.RM_Distance ...
%             + (1-Parameter.thetat)*Parameter.RM_Location ...
%             + 2*Parameter.thetat*RMatrixEdge./Parameter.B;
end