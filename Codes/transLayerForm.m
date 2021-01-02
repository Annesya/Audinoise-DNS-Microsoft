function lgraph = transLayerForm(transLayer,numFeatures,WeightLearnRateFactor,BiasLearnRateFactor)
lgraph = layerGraph();
tempLayers = [
    transLayer
    fullyConnectedLayer(numFeatures,"Name","newFC",'WeightLearnRateFactor',WeightLearnRateFactor,'BiasLearnRateFactor',BiasLearnRateFactor)];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    dotMult('Multiply')
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);
lgraph = connectLayers(lgraph,"imageinput","Multiply/in2");
lgraph = connectLayers(lgraph,"newFC","Multiply/in1");
clear tempLayers;
end