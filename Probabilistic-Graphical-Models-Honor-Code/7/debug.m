%{
% StochasticGradientDescent.m
clear all;
load('Train1X.mat');
load('Train1Y.mat');
lambda = 0;
thetaOpt = LRTrainSGD(Train1X, Train1Y, lambda);
pred = LRPredict (Train1X, thetaOpt);
acc = LRAccuracy(Train1Y, pred);
%}


%{
% LRSearchLambdaSGD
clear all;

load('Train1X.mat');
load('Train1Y.mat');
load('Validation1X.mat');
load('Validation1Y.mat');
load('Part1Lambdas.mat');
load('ValidationAccuracy.mat');

allAcc = LRSearchLambdaSGD(Train1X, Train1Y, Validation1X,...
    Validation1Y, Part1Lambdas);
%}


clear all;
load('Part2Sample.mat');

%{
% LogZ
[P, logZ] = CliqueTreeCalibrate(sampleUncalibratedTree, 0);
%}


X = sampleX;
y = sampleY;
theta = sampleTheta;
modelParams = sampleModelParams;
lambda = modelParams.lambda;

clear sampleX sampleY sampleTheta sampleModelParams;
%{
featureSet = GenerateAllFeatures(X, modelParams);

[F, FeatureCounts] = GenerateFactors(y, theta, featureSet, modelParams);
P = CreateCliqueTree(F);
[P, logZ] = CliqueTreeCalibrate(P, 0);
WeightFeatureCounts = theta.*FeatureCounts;
RegulazrizationCost = (lambda/2)*(theta*theta');
NLL = logZ - sum(WeightFeatureCounts) + RegulazrizationCost;

F = ComputeNormalizedP(P, F);

[ModelFeatureCounts] = GenerateModelFeatureCounts(F, featureSet);
%}
[nll, grad] = InstanceNegLogLikelihood(X, y, theta, modelParams);




