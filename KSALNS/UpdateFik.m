function Fik = UpdateFik(InsertIndex,Insertkindex,Fik,OrderSet,Solution,FEIndex,Parameter,Setting)
Fik(InsertIndex,:) = [];
[inum,knum] = size(Fik);
r   = Solution(Insertkindex).Routes;
k   = Solution(Insertkindex).Kindex;
if Insertkindex > knum
    Fik = [Fik Inf(inum,1)];
    for i = 1:inum
        Order1 = OrderSet(i);
        Rlist = Parameter.ctypelist{Order1};
        if ismember(k,Rlist)
            Fik(i,Insertkindex) = Insert2R_FEIndex(Order1,r,k,FEIndex,Parameter,Setting);
        end
    end
else
    for i = 1:inum
        Order1 = OrderSet(i);
        Rlist = Parameter.ctypelist{Order1};
        if ismember(k,Rlist)
            Fik(i,Insertkindex) = Insert2R_FEIndex(Order1,r,k,FEIndex,Parameter,Setting);
        end
    end
end


end