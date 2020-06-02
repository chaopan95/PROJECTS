clear all;
load('Part2Sample.mat');
X = sampleX;
y = sampleY;
theta = sampleTheta;
modelParams = sampleModelParams;

clear sampleX sampleY sampleTheta sampleModelParams;

featureSet = GenerateAllFeatures(X, modelParams);

n = length(y);
for i=1:n-1
    F(i) = EmptyFactorStruct();
    F(i).var = i;
    F(i).card = 26;
    F(i).val = zeros(1,26);
    
    FF(i) = EmptyFactorStruct();
    FF(i).var = [i, i+1];
    FF(i).card = [26, 26];
    FF(i).val = zeros(1,26*26);
end;
F(n) = EmptyFactorStruct();
F(n).var = n;
F(n).card = [26];
F(n).val = zeros(1,26);

allFactors = [F, FF];

%Populate the factor values

%Loop over each factor
ThetaCount = zeros(size(theta));
for f = 1:length(allFactors)
    factorVar = allFactors(f).var;
    for i=1:length(featureSet.features)
        %Find the factor that has the same scope as the factor
        if(length(factorVar) ~= length(featureSet.features(i).var))
            continue;
        end;
        if all(sort(factorVar) == sort(featureSet.features(i).var))
            if(all(y(featureSet.features(i).var) == featureSet.features(i).assignment))
                ThetaCount(featureSet.features(i).paramIdx) = ThetaCount(featureSet.features(i).paramIdx) + 1;
            end;
            map = [];
            for j = 1:length(factorVar)
                map(j) = find(factorVar == featureSet.features(i).var(j));
            end;
            idx = AssignmentToIndex(featureSet.features(i).assignment(map), allFactors(f).card);
            allFactors(f).val(idx) = allFactors(f).val(idx) + theta(featureSet.features(i).paramIdx);
        end;
    end;
end;

for i=1:length(allFactors)
    allFactors(i).val = exp(allFactors(i).val);
end;

P = CreateCliqueTree(allFactors);





