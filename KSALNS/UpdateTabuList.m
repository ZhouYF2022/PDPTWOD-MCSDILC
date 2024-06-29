function Parameter = UpdateTabuList(OrderSet,Solution,Accept,Parameter,Setting)
Parameter.TabuList = max(0,Parameter.TabuList - 1);
if Accept == 1
    for i = 1:length(Solution)
        r = Solution(i).Routes;
        if ~isempty(r)
            k = Solution(i).Kindex;
            if k <= Parameter.ODnum
                OrderList = r(ismember(r,OrderSet));
                if ~isempty (OrderList)
                    for j = 1:length(OrderList)
                        Orderj = OrderList(j);
                        OrderjIndex  = find(r==Orderj);
                        if OrderjIndex == 1
                            if Parameter.TabuList(k,Orderj) == 0
                                Parameter.TabuList(k,Orderj) = Setting.Kxi(3);
                            end
                        else
                            if Parameter.TabuList(r(OrderjIndex-1),r(OrderjIndex)) == 0
                                Parameter.TabuList(r(OrderjIndex-1),r(OrderjIndex)) = Setting.Kxi(3);
                            end
                            if Parameter.TabuList(r(OrderjIndex),r(OrderjIndex+1)) == 0
                                Parameter.TabuList(r(OrderjIndex),r(OrderjIndex+1)) = Setting.Kxi(3);
                            end
                        end
                        OrderjnIndex = find(r==Orderj + Parameter.PickOrder);
                        if OrderjnIndex == length(r)
                            if Parameter.TabuList(r(OrderjnIndex-1),r(OrderjnIndex)) == 0
                                Parameter.TabuList(r(OrderjnIndex-1),r(OrderjnIndex)) = Setting.Kxi(3);
                            end
                        else
                            if Parameter.TabuList(r(OrderjnIndex-1),r(OrderjnIndex)) == 0
                                Parameter.TabuList(r(OrderjnIndex-1),r(OrderjnIndex)) = Setting.Kxi(3);
                            end
                            if Parameter.TabuList(r(OrderjnIndex),r(OrderjnIndex+1)) == 0
                                Parameter.TabuList(r(OrderjnIndex),r(OrderjnIndex+1)) = Setting.Kxi(3);
                            end
                        end
                        OrderSet(OrderSet==Orderj) = [];
                    end
                end
            end
        end
    end
else
    for i = 1:length(Solution)
        r = Solution(i).Routes;
        if ~isempty(r)
            k = Solution(i).Kindex;
            if k <= Parameter.ODnum
                OrderList = r(ismember(r,OrderSet));
                if ~isempty (OrderList)
                    for j = 1:length(OrderList)
                        Orderj = OrderList(j);
                        OrderjIndex  = find(r==Orderj);
                        if OrderjIndex == 1
                            Parameter.TabuList(k,Orderj) = 0;
                        else
                            Parameter.TabuList(r(OrderjIndex-1),r(OrderjIndex)) = 0;
                            Parameter.TabuList(r(OrderjIndex),r(OrderjIndex+1)) = 0;
                        end
                        OrderjnIndex = find(r==Orderj + Parameter.PickOrder);
                        if OrderjnIndex == length(r)
                            Parameter.TabuList(r(OrderjnIndex-1),r(OrderjnIndex)) = 0;
                        else
                            Parameter.TabuList(r(OrderjnIndex-1),r(OrderjnIndex)) = 0;
                            Parameter.TabuList(r(OrderjnIndex),r(OrderjnIndex+1)) = 0;
                        end
                        OrderSet(OrderSet==Orderj) = [];
                    end
                end
            end
        end
    end
end


end