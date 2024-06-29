    clear
    clc
    % main for PDPTWOD-MCSDILC
    %% Import data and parameters
    filename = 'AAn5m3-o1t0.mat';
%     Ordertype = 3;
    
    Setting.Score = [50 30 15];     % Different new solution scores
    Setting.PartC = 0.4;            % Percentage of removed orders
    Setting.MaxOrder = 25;          % Remove the maximum number of orders
    Setting.alpha = 5;              % Destruct the randomization parameters of the operator
    Setting.Tend  = 0.05;           % Minimum temperature
    Setting.Trate = 0.995;          % SA temperature attenuation factor
    Setting.rho   = 0.3;            % Weight adjustment factor
    
    Setting.Kxi   = [0.2 0.01 20];  % The level of noise in FE, the size of the penalty for the bad edge, and the length of the tabu
    Setting.PenaltyNum = 0.01;      % The number of penalty edges
    Setting.P = [500 1 1.5 10 2];   % RV fixed cost/RV variable cost /OD variable cost/reciept cos//delay penalty
    Setting.tmax = 30;
    
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
    %Best solution
    BestSolution = Solution;
    BestObjs = Objs;
    
    % B represents the number of solutions that need to be stored to build the correlation matrix
    B = 50;
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

