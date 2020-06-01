clear all;
load('PA4Sample.mat');
%load('PA4Test.mat');

%{
P = ComputeInitialPotentials(InitPotential.INPUT);
%sum(sum(P.edges ~= InitPotential.RESULT.edges))

for i = 1:length(InitPotential.RESULT.cliqueList)
    var = sum(InitPotential.RESULT.cliqueList(i).var ~= P.cliqueList(i).var);
    card = sum(InitPotential.RESULT.cliqueList(i).card ~= P.cliqueList(i).card);
    val = sum(InitPotential.RESULT.cliqueList(i).val ~= P.cliqueList(i).val);
    if var && card && val
        i
    end;
end;
%}

%{
P = GetNextC.INPUT1;
messages = GetNextC.INPUT2;
[i, j] = GetNextCliques(P, messages);
%}

%{
isMax = 0;
P = SumProdCalibrate.INPUT;
P = CliqueTreeCalibrate(P, isMax);
%}

%{
P = CliqueTreeCalibrate(CreateCliqueTree(ExactMarginal.INPUT, []), 0);
M = ComputeExactMarginalsBP(ExactMarginal.INPUT, [], 0);
%}

%{
A = FactorMax.INPUT1;
V = FactorMax.INPUT2;
B = FactorMaxMarginalization(A, V);
%}

%{
P = CliqueTreeCalibrate(MaxSumCalibrate.INPUT, 1);
%}

%{
M = ComputeExactMarginalsBP(MaxMarginals.INPUT, [], 1);
%}


A = MaxDecoding( MaxDecoded.INPUT );







