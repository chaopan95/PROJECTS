% File: RecognizeActions.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [accuracy, predicted_labels] = RecognizeActions(...
    datasetTrain, datasetTest, G, maxIter)

% INPUTS
% datasetTrain: dataset for training models, see PA for details
% datasetTest: dataset for testing models, see PA for details
% G: graph parameterization as explained in PA decription
% maxIter: max number of iterations to run for EM

% OUTPUTS
% accuracy: recognition accuracy, defined as (#correctly classified
% examples / #total examples)
% predicted_labels: N x 1 vector with the predicted labels for each of the
% instances in datasetTest, with N being the number of unknown test
% instances


% Train a model for each action
% Note that all actions share the same graph parameterization and number of
% max iterations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.c = zeros(1, 3);
P.clg = repmat(struct(...
        'mu_y', [], 'sigma_y', [],...
        'mu_x', [], 'sigma_x', [],...
        'mu_angle', [], 'sigma_angle', [],...
        'theta', zeros(3, 12)), 1, 10);
P.transMatrix = zeros(3, 3);
Ps = repmat(P, 1, 3);


for i = 1:length(datasetTrain)
    actionData = datasetTrain(i).actionData;
    poseData = datasetTrain(i).poseData;
    InitialClassProb = datasetTrain(i).InitialClassProb;
    InitialPairProb = datasetTrain(i).InitialPairProb;
    Ps(i) = EM_HMM(actionData, poseData, G, InitialClassProb,...
        InitialPairProb, maxIter);
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Classify each of the instances in datasetTrain
% Compute and return the predicted labels and accuracy
% Accuracy is defined as (#correctly classified examples / #total examples)
% Note that all actions share the same graph parameterization

accuracy = 0;
predicted_labels = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

actionData = datasetTest.actionData;
poseData = datasetTest.poseData;
labels = datasetTest.labels;

N = length(poseData);
K = 3;
A = length(actionData);
res = zeros(A, 3);

for p = 1:length(Ps)
    logEmissionProb = zeros(N, K);
    P = Ps(p);
    for n = 1:N
        for k = 1:K
            if size(G, 3) > 1
                g = reshape(G(:, :, k), 10, 2);
            else
                g = G;
            end;

            X = reshape(poseData(n, :, :), 10, 3);
            log_joint = 0;
            for i = 1:10
                if g(i, 1)
                    parent = g(i, 2);
                    x_parent = X(parent, :);
                    mu_y = P.clg(i).theta(k, 1:4)*[1, x_parent]';
                    mu_x = P.clg(i).theta(k, 5:8)*[1, x_parent]';
                    mu_angle = P.clg(i).theta(k, 9:12)*[1, x_parent]';
                else
                    mu_y = P.clg(i).mu_y(k);
                    mu_x = P.clg(i).mu_x(k);
                    mu_angle = P.clg(i).mu_angle(k);
                end;
                sigma_y = P.clg(i).sigma_y(k);
                sigma_x = P.clg(i).sigma_x(k);
                sigma_angle = P.clg(i).sigma_angle(k);
                log_joint = log_joint +...
                    lognormpdf(X(i, 1), mu_y, sigma_y) +...
                    lognormpdf(X(i, 2), mu_x, sigma_x) +...
                    lognormpdf(X(i, 3), mu_angle, sigma_angle);
            end;
            logEmissionProb(n, k) = log_joint;
        end;
    end;
    
    
    for a = 1:A
        marg_ind = actionData(a).marg_ind;
        pair_ind = actionData(a).pair_ind;
        num_fac1 = 1;
        num_fac2 = length(marg_ind);
        num_fac3 = length(pair_ind);
        F = repmat(struct('var', [], 'card', [], 'val', []),...
            num_fac1+num_fac2+num_fac3, 1);
        
        F(1).var = 1;
        F(1).card = K;
        F(1).val = log(P.c);

        for num = 1:num_fac2
            f = struct('var', [], 'card', [], 'val', []);
            f.var = num;
            f.card = K;
            f.val = logEmissionProb(marg_ind(num), :);
            F(num+num_fac1) = f;
        end;

        for num = 1:num_fac3
            f = struct('var', [], 'card', [], 'val', []);
            f.var = [num, num+1];
            f.card = [K, K];
            f.val = log(P.transMatrix(:))';
            F(num+num_fac1+num_fac2) = f;
        end;

        [~, PCalibrated] = ComputeExactMarginalsHMM(F);
        
        cliqueList = PCalibrated.cliqueList;
        
        res(a, p) = logsumexp(cliqueList(1).val);
        %{
        for j = 1:length(cliqueList)
            f = cliqueList(j);
            if length(f.var) == 1
                continue;
            end;
            res(a, p) = logsumexp(f.val);
            break;
        end;
        %}
    end;
end;

[~, predicted_labels] = max(res, [], 2);

accuracy = sum(labels == predicted_labels)/A;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
