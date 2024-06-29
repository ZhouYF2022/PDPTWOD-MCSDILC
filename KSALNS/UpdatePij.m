function Parameter = UpdatePij(Solution,Parameter,Setting)
pij = Parameter.pij;
pij2 = Parameter.pij2;
uij = zeros(2*Parameter.PickOrder + Parameter.ODnum + 1); % The utility of edges determines which edges are punished
uij2 = zeros(Parameter.PickOrder,Parameter.ODnum+Parameter.RVnum);
for i = 1:length(Solution)
    r = Solution(i).Routes;
    if ~isempty(r)
        k = Solution(i).Kindex;
        Cost = Solution(i).Objs;
        if k <= Parameter.ODnum
            for j = 1:length(r)-1
                if j == 1
                    darc = Parameter.S2M(k,r(j));
                    uij(k+2*Parameter.PickOrder,r(j)) = darc/(1+pij(k+2*Parameter.PickOrder,r(j)));
                    if r(j) <= Parameter.PickOrder
                        deletC = r(j);
                        Newr = r(~ismember(r,[deletC deletC+Parameter.PickOrder]));
                        uij2(r(j),k) = (Cost - CalObjective(Newr,k,Parameter,Setting))/(1+pij2(r(j),k));
                    end
                else
                    darc = Parameter.M2C(r(j-1),r(j));
                    uij(r(j-1),r(j)) = darc/(1+pij(r(j-1),r(j)));
                    if r(j) <= Parameter.PickOrder
                        deletC = r(j);
                        Newr = r(~ismember(r,[deletC deletC+Parameter.PickOrder]));
                        uij2(r(j),k) = (Cost - CalObjective(Newr,k,Parameter,Setting))/(1+pij2(r(j),k));
                    end
               end
            end
        else
            N = 2*Parameter.PickOrder+Parameter.ODnum+1;
            for j = 1:length(r)+1
                if j == 1
                    darc = Parameter.RV_S2M(r(j));
                    uij(N,r(j)) = darc/(1+pij(N,r(j)));
                    if r(j) <= Parameter.PickOrder
                        deletC = r(j);
                        Newr = r(~ismember(r,[deletC deletC+Parameter.PickOrder]));
                        uij2(r(j),k) = (Cost - CalObjective(Newr,k,Parameter,Setting))/(1+pij2(r(j),k));
                    end
                elseif j == length(r)+1
                    darc = Parameter.RV_S2M(r(j-1));
                    uij(r(j-1),N) = darc/(1+pij(r(j-1),N));
                else
                    darc = Parameter.M2C(r(j-1),r(j));
                    uij(r(j-1),r(j)) = darc/(1+pij(r(j-1),r(j)));
                    if r(j) <= Parameter.PickOrder
                        deletC = r(j);
                        Newr = r(~ismember(r,[deletC deletC+Parameter.PickOrder]));
                        uij2(r(j),k) = (Cost - CalObjective(Newr,k,Parameter,Setting))/(1+pij2(r(j),k));
                    end
                end
            end
        end
    end
end
%update pij1
[Orderi,Orderj] = find(uij>0);
uijMatrix = zeros(length(Orderi),3);
for i = 1:length(Orderi)
    uijMatrix(i,:) = [Orderi(i) Orderj(i) uij(Orderi(i),Orderj(i))];
end
uijMatrix = sortrows(uijMatrix,3,'descend');
PenaltyNum = ceil(Setting.PenaltyNum * length(Orderi)); 
for i = 1:PenaltyNum
    pij(uijMatrix(i,1),uijMatrix(i,2)) = pij(uijMatrix(i,1),uijMatrix(i,2)) + 1;
end
Parameter.pij = pij;
%update pij2
[Orderi,Orderj] = find(uij2>0);
uij2Matrix = zeros(length(Orderi),3);
for i = 1:length(Orderi)
    uij2Matrix(i,:) = [Orderi(i) Orderj(i) uij2(Orderi(i),Orderj(i))];
end
uij2Matrix = sortrows(uij2Matrix,3,'descend');
PenaltyNum = ceil(Setting.PenaltyNum * length(Orderi)); 
for i = 1:PenaltyNum
    pij2(uij2Matrix(i,1),uij2Matrix(i,2)) = pij2(uij2Matrix(i,1),uij2Matrix(i,2)) + 1;
end
Parameter.pij2 = pij2;
end