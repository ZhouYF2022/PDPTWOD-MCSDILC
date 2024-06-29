function  [Solution,Objs] = InsertOPT(OrderSet,Solution,InsertIndex,FEIndex,Parameter,Setting)
switch InsertIndex
    case 1 %Rand Insert
        [Solution,Objs] = RandIOpt(Solution,OrderSet,FEIndex,Parameter,Setting);
    case 2 %Deep Greedy Insert
        [Solution,Objs] = GreedyI2Opt(Solution,OrderSet,FEIndex,Parameter,Setting); 
    case 3 %regret-2 Insert
        [Solution,Objs] = Regret2IOpt(Solution,OrderSet,FEIndex,Parameter,Setting);
    case 4 %regret-3 Insert
        [Solution,Objs] = Regret3IOpt(Solution,OrderSet,FEIndex,Parameter,Setting);
    case 5 %regret-4 Insert
        [Solution,Objs] = Regret4IOpt(Solution,OrderSet,FEIndex,Parameter,Setting);
    case 6 %OPT Insert
        [Solution,Objs] = OPIOpt(Solution,OrderSet,FEIndex,Parameter,Setting);
end
end

