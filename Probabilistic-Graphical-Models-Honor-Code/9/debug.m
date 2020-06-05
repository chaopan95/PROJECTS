clear all;
load('PA9SampleCases.mat');
load('PA9Data.mat');

%{
[P, loglikelihood, ClassProb] = EM_cluster(...
    exampleINPUT.t1a1, exampleINPUT.t1a2,...
    exampleINPUT.t1a3, exampleINPUT.t1a4);

[P, loglikelihood, ClassProb] = EM_cluster(poseData1, G,...
    InitialClassProb1, 20);
%}

%{
[P, loglikelihood, ClassProb, PairProb] = EM_HMM(...
    exampleINPUT.t2a1b, exampleINPUT.t2a2b, exampleINPUT.t2a3b,...
    exampleINPUT.t2a4b, exampleINPUT.t2a5b, exampleINPUT.t2a6b);

[accuracy, predicted_labels] = RecognizeActions(...
    exampleINPUT.t3a1, exampleINPUT.t3a2,...
    exampleINPUT.t3a3, exampleINPUT.t3a4);
%}


%RecognizeUnknownActions(datasetTrain3, datasetTest3, G);

datasetTest3.labels = zeros(90, 1);
[accuracy, predicted_labels] = RecognizeActions(...
    datasetTrain3, datasetTest3, G, 10);
SavePredictions (predicted_labels);




