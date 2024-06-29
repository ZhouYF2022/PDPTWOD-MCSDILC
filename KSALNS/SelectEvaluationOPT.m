function FEIndex = SelectEvaluationOPT(Parameter)
FEWeight = Parameter.FEWeight;
Fitness = cumsum(FEWeight);
Fitness = Fitness./max(Fitness);
FEIndex   = arrayfun(@(S)find(rand<=Fitness,1),1);

end