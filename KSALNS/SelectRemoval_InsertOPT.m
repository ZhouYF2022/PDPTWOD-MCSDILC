function [RemovalIndex,InsertIndex] = SelectRemoval_InsertOPT(Parameter)
RemovalWeight = Parameter.RemovalWeight;
InsertWeight = Parameter.InsertWeight;

Fitness1 = cumsum(RemovalWeight);
Fitness1 = Fitness1./max(Fitness1);
RemovalIndex   = arrayfun(@(S)find(rand<=Fitness1,1),1);

Fitness2 = cumsum(InsertWeight);
Fitness2 = Fitness2./max(Fitness2);
InsertIndex   = arrayfun(@(S)find(rand<=Fitness2,1),1);

end