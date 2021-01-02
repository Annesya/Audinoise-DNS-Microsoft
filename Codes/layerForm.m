function lgraph = layerForm(numFeatures,numSegments)
lgraph = layerGraph();
tempLayers = imageInputLayer([numFeatures numSegments 1],"Name","imageinput");
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    fullyConnectedLayer(2048,"Name","fc_1")
    batchNormalizationLayer("Name","batchnorm_1")
    reluLayer("Name","relu_1")
    fullyConnectedLayer(2048,"Name","fc_2")
    batchNormalizationLayer("Name","batchnorm_2")
    reluLayer("Name","relu_2")
    fullyConnectedLayer(numFeatures,"Name","fc_3")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    dotMult('Multiply')
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);
lgraph = connectLayers(lgraph,"imageinput","fc_1");
lgraph = connectLayers(lgraph,"imageinput","Multiply/in2");
lgraph = connectLayers(lgraph,"fc_3","Multiply/in1");
clear tempLayers;
end