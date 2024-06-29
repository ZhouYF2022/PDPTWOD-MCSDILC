function Parameter = UpdateRMatrixEdge(Routes,Objs,Parameter)
%Update B_Solution and RMatrixEdge
B_Solution = Parameter.B_Solution;
N = size(B_Solution,1);
B_ObjsList = cell2mat(B_Solution(:,2));
if ~ismember(Objs,B_ObjsList)
    if N < Parameter.B
        B_Solution{end+1,1} = Routes;
        B_Solution{size(B_Solution,1),2} = Objs;
        RMatrixEdge = RMatrix(B_Solution,Parameter);
        Parameter.B_Solution  = B_Solution;
        Parameter.RMatrixEdge = RMatrixEdge;
    else
        B_Solution{end+1,1} = Routes;
        B_Solution{size(B_Solution,1),2} = Objs;
        B_ObjsList = cell2mat(B_Solution(:,2));
        [~,index] = max(B_ObjsList);
        B_Solution(index,:) = [];
        RMatrixEdge = RMatrix(B_Solution,Parameter);
        Parameter.B_Solution  = B_Solution;
        Parameter.RMatrixEdge = RMatrixEdge;
    end
end



end