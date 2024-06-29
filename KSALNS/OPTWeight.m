function WeightList = OPTWeight(RemovalWeight,InsertWeight,FEWeight)
WeightList = [RemovalWeight/sum(RemovalWeight) InsertWeight/sum(InsertWeight) FEWeight/sum(FEWeight)];
end