function Parameter = UpdateWeight(Parameter,Setting)
rho = Setting.rho;

RWeight = Parameter.RemovalWeight;
IWeight = Parameter.InsertWeight;
FEWeight = Parameter.FEWeight;

RScore = Parameter.RemovalScore;
IScore = Parameter.InsertScore;
FEScore = Parameter.FEScore;

RNum = Parameter.RemovalNum;
INum = Parameter.InsertNum;
FENum = Parameter.FENum;

RL = Parameter.RemovalOPTnum;
IL = Parameter.InsertOPTnum;
FEL = Parameter.FEOPTnum;

NewRWeight = zeros(1,RL);
NewIWeight = zeros(1,IL);
NewFEWeight = zeros(1,FEL);

for i1 = 1:RL
    if RNum(i1)==0
        NewRWeight(i1) = (1-rho)*RWeight(i1);
    else
        NewRWeight(i1) = (1-rho)*RWeight(i1) + rho*RScore(i1)/RNum(i1);
    end
end

for i2 = 1:IL
    if INum(i2)==0
        NewIWeight(i2) = (1-rho)*IWeight(i2);
    else
        NewIWeight(i2) = (1-rho)*IWeight(i2) + rho*IScore(i2)/INum(i2);
    end
end

for i3 = 1:FEL
    if FENum(i3)==0
        NewFEWeight(i3) = (1-rho)*FEWeight(i3);
    else
        NewFEWeight(i3) = (1-rho)*FEWeight(i3) + rho*FEScore(i3)/FENum(i3);
    end
end
    
    
Parameter.RemovalWeight = NewRWeight;
Parameter.InsertWeight  = NewIWeight;
Parameter.FEWeight      = NewFEWeight;

Parameter.RemovalScore = zeros(1,RL);
Parameter.InsertScore  = zeros(1,IL);
Parameter.FEScore      = zeros(1,FEL);

Parameter.RemovalNum = zeros(1,RL);
Parameter.InsertNum  = zeros(1,IL);
Parameter.FENum      = zeros(1,FEL);

end