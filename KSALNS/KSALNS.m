% clear
% clc
% main for PDPTWOD-MCSDILC
function Result = KSALNS(filename,Setting)
    Parameter = ImportData_KSALNS(filename);
    
    %%  Parameter setting    
    Parameter.RemovalOPTnum = 10;  % Number of destroy operators
    Parameter.InsertOPTnum  = 6;   % Number of repair operators
    Parameter.FEOPTnum      = 4;   % Number of evaluation operators
    
    Parameter.RemovalWeight = ones(1,Parameter.RemovalOPTnum)*10;
    Parameter.InsertWeight  = ones(1,Parameter.InsertOPTnum)*10;
    Parameter.FEWeight      = ones(1,Parameter.FEOPTnum)*10;
    
    Parameter.RemovalScore  = zeros(1,Parameter.RemovalOPTnum);
    Parameter.InsertScore   = zeros(1,Parameter.InsertOPTnum);
    Parameter.FEScore       = zeros(1,Parameter.FEOPTnum);

    Parameter.RemovalNum    = zeros(1,Parameter.RemovalOPTnum);
    Parameter.InsertNum     = zeros(1,Parameter.InsertOPTnum);
    Parameter.FENum         = zeros(1,Parameter.FEOPTnum);
    
    Parameter.TotalRemovalNum    = zeros(1,Parameter.RemovalOPTnum);
    Parameter.TotalInsertNum     = zeros(1,Parameter.InsertOPTnum);
    Parameter.TotalFENum         = zeros(1,Parameter.FEOPTnum);
    
    
    Parameter.thetat = 0;                                                              % Different degrees of knowledge contribution
    Parameter.pij = zeros(2*Parameter.PickOrder + Parameter.ODnum + 1);                % Record the number of side penalties in GLS
    Parameter.pij2 = zeros(Parameter.PickOrder,Parameter.ODnum + Parameter.RVnum);     % Record the number of penalties for matching orders and vehicles in GLS
    Parameter.TabuList = zeros(2*Parameter.PickOrder+Parameter.ODnum);                 % TabuList
    
    %% Initialization Routes
    [Solution,Objs] = initial_path(Parameter,Setting);
    
    %% ALNS
    BestSolution = Solution;  %Best solution
    BestObjs = Objs;
   
    B = 50;  % B represents the number of solutions that need to be stored to build the correlation matrix
    Parameter.B = B;
    B_Solution = {}; 
    B_Solution{end+1,1} = BestSolution;
    B_Solution{size(B_Solution,1),2} = BestObjs;
    RMatrixEdge = RMatrix(B_Solution,Parameter);
    Parameter.B_Solution  = B_Solution;
    Parameter.RMatrixEdge = RMatrixEdge;
    
    %Terminal condition
    Tinital = 0.2*Objs;
    T = Tinital;
    num = 0;
    t = 0;
    tmax = Setting.tmax;

    %Iterative process Operations weight
    number = 1;
    TotalNum = ceil((log(Setting.Tend) - log(Tinital))/log(Setting.Trate)/tmax);
    Weightlist = zeros(TotalNum,Parameter.RemovalOPTnum+Parameter.InsertOPTnum+Parameter.FEOPTnum);
    Weightlist(number,:) = OPTWeight(Parameter.RemovalWeight,Parameter.InsertWeight,Parameter.FEWeight);
    
    tic;
    while (T > Setting.Tend) 
        Cnum = randi([1,min(Setting.MaxOrder,ceil(Setting.PartC*Parameter.PickOrder))],1);
        Cnum = min(Setting.MaxOrder,Cnum);
        
        [RemovalIndex,InsertIndex] = SelectRemoval_InsertOPT(Parameter);
        FEIndex = SelectEvaluationOPT(Parameter);
        Parameter.RemovalNum(RemovalIndex) = Parameter.RemovalNum(RemovalIndex) + 1;
        Parameter.InsertNum(InsertIndex)   = Parameter.InsertNum(InsertIndex) + 1;
        Parameter.FENum(FEIndex)           = Parameter.FENum(FEIndex) + 1;
        
        Parameter.TotalRemovalNum(RemovalIndex) = Parameter.TotalRemovalNum(RemovalIndex) + 1;
        Parameter.TotalInsertNum(InsertIndex)   = Parameter.TotalInsertNum(InsertIndex) + 1;
        Parameter.TotalFENum(FEIndex) = Parameter.TotalFENum(FEIndex) + 1;
                
        Parameter = RoutesKnowledge(Solution,Objs,Parameter,Setting);
        [Part_Solution,OrderSet]  = RemovalOPT(Cnum,Solution,RemovalIndex,Parameter,Setting); 
        [NewSolution,NewObjs]     = InsertOPT(OrderSet,Part_Solution,InsertIndex,FEIndex,Parameter,Setting);
        
        p0 = exp(-(NewObjs-Objs)/T);
        if BestObjs <= NewObjs
            num = num + 1 ;
        else
            num = 0;
        end
        if NewObjs < Objs
            if NewObjs < BestObjs
                BestSolution = NewSolution;
                BestObjs   = NewObjs;
                Parameter.RemovalScore(RemovalIndex) = Parameter.RemovalScore(RemovalIndex) + Setting.Score(1);
                Parameter.InsertScore(InsertIndex)   = Parameter.InsertScore(InsertIndex) + Setting.Score(1);
                Parameter.FEScore(FEIndex)           = Parameter.FEScore(FEIndex) + Setting.Score(1);
            end
            Solution = NewSolution;
            Objs   = NewObjs;
            Parameter.RemovalScore(RemovalIndex) = Parameter.RemovalScore(RemovalIndex) + Setting.Score(2);
            Parameter.InsertScore(InsertIndex)   = Parameter.InsertScore(InsertIndex) + Setting.Score(2);
            Parameter.FEScore(FEIndex)           = Parameter.FEScore(FEIndex) + Setting.Score(2);
            %Update RMatrixNode / TabuList
            Parameter = UpdateRMatrixEdge(NewSolution,NewObjs,Parameter);
            Parameter = UpdateTabuList(OrderSet,NewSolution,1,Parameter,Setting);
        elseif p0 > rand
            Solution = NewSolution;
            Objs   = NewObjs;
            Parameter.RemovalScore(RemovalIndex) = Parameter.RemovalScore(RemovalIndex) + Setting.Score(3);
            Parameter.InsertScore(InsertIndex)   = Parameter.InsertScore(InsertIndex) + Setting.Score(3);
            Parameter.FEScore(FEIndex)           = Parameter.FEScore(FEIndex) + Setting.Score(3);
            
            %Update RMatrixNode / TabuList
            Parameter = UpdateRMatrixEdge(NewSolution,NewObjs,Parameter);
        else
            Parameter = UpdateTabuList(OrderSet,NewSolution,0,Parameter,Setting);
        end
        t = t + 1;
        %Update T / thetat
        T = T*Setting.Trate;
        Parameter.thetat = Setting.Tend/T;
        
        %Update Stop Condition / Pij
        if mod(t,tmax) == 0
            Parameter = UpdateWeight(Parameter,Setting);
            Parameter = UpdatePij(BestSolution,Parameter,Setting);
            number = number + 1;
            Weightlist(number,:) = OPTWeight(Parameter.RemovalWeight,Parameter.InsertWeight,Parameter.FEWeight);
            toc;
        end
        fprintf('Iteration %d: BestObjs = %f\n', t, BestObjs)
        
    end
    StopTime = toc;
    
    ODs = 0; ODsObjs = 0;
    PFs = 0; PFsObjs = 0;
    for i = 1:length(BestSolution)
        kindex = BestSolution(i).Kindex;
        if kindex<=Parameter.ODnum
            ODs = ODs + 1;
            ODsObjs = ODsObjs + BestSolution(i).Objs;
        else
            PFs = PFs + 1;
            PFsObjs = PFsObjs + BestSolution(i).Objs;
        end
    end
    
    Result.BestSolution = BestSolution;
    Result.BestObjs = BestObjs;
    Result.StopTime = StopTime;
    Result.Weightlist = Weightlist;
    Result.ODs = ODs;
    Result.PFs = PFs;
    Result.ODsObjs = ODsObjs;
    Result.PFsObjs = PFsObjs;
    
end
