clear all;
load('PA8SampleCases.mat');
load('PA8Data.mat');

%{
[Beta, sigma] = FitLinearGaussianParameters(exampleINPUT.t2a1,...
    exampleINPUT.t2a2);

loglikelihood = ComputeLogLikelihood(exampleINPUT.t3a1,...
    exampleINPUT.t3a2, trainData.data);

[P, loglikelihood] = LearnCPDsGivenGraph(...
    exampleINPUT.t4a1,...
    exampleINPUT.t4a2,...
    exampleINPUT.t4a3);

accuracy = ClassifyDataset(...
    exampleINPUT.t5a1, exampleINPUT.t5a2,...
    exampleINPUT.t5a3, exampleINPUT.t5a4);

%}

%{
[P1, likelihood1] = LearnCPDsGivenGraph(trainData.data, G1, trainData.labels);
accuracy1 = ClassifyDataset(testData.data, testData.labels, P1, G1);
VisualizeModels(P1, G1);

[P2 likelihood2] = LearnCPDsGivenGraph(trainData.data, G2, trainData.labels);
accuracy1 = ClassifyDataset(testData.data, testData.labels, P2, G2);
VisualizeModels(P2, G2);

%}

[A, W] = LearnGraphStructure(exampleINPUT.t6a1);

[P, G, loglikelihood] = LearnGraphAndCPDs(...
    exampleINPUT.t7a1, exampleINPUT.t7a2);

[P, G, likelihood3] = LearnGraphAndCPDs(trainData.data, trainData.labels);
accuracy = ClassifyDataset(testData.data, testData.labels, P, G);



