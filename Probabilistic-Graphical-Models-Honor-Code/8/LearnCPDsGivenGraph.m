function [P, loglikelihood] = LearnCPDsGivenGraph(dataset, G, labels)
%
% Inputs:
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
% G: graph parameterization as explained in PA description
% labels: N x 2 true class labels for the examples. labels(i,j)=1 if the 
%         the ith example belongs to class j and 0 elsewhere        
%
% Outputs:
% P: struct array parameters (explained in PA description)
% loglikelihood: log-likelihood of the data (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);
K = size(labels,2);

loglikelihood = 0;
P.c = zeros(1,K);

% estimate parameters
% fill in P.c, MLE for class probabilities
% fill in P.clg for each body part and each class
% choose the right parameterization based on G(i,1)
% compute the likelihood - you may want to use ComputeLogLikelihood.m
% you just implemented.
%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE

% These are dummy lines added so that submit.m will run even if you 
% have not started coding. Please delete them.
P.clg.sigma_x = 0;
P.clg.sigma_y = 0;
P.clg.sigma_angle = 0;


P.c = sum(labels)/N;
P.clg = repmat(struct(...
    'mu_y', [], 'sigma_y', [],...
    'mu_x', [], 'sigma_x', [],...
    'mu_angle', [], 'sigma_angle', [],...
    'theta', zeros(2, 12)), 10, 1);

for k = 1:K
    idx = find(labels(:, k) == 1);
    if size(G, 3) > 1
        g = reshape(G(:, :, k), 10, 2);
    else
        g = G;
    end;
    for i = 1:10
        y = squeeze(dataset(idx, i, 1));
        x = squeeze(dataset(idx, i, 2));
        angle = squeeze(dataset(idx, i, 3));
        if g(i, 1)
            parent = g(i, 2);
            data_parent = squeeze(dataset(idx, parent, :));
            
            [theta_y, sigma_y] = FitLinearGaussianParameters(y,...
                data_parent);
            [theta_x, sigma_x] = FitLinearGaussianParameters(x,...
                data_parent);
            [theta_angle, sigma_angle] = FitLinearGaussianParameters(...
                angle, data_parent);

            P.clg(i).theta(k, :) = [...
                theta_y(4), theta_y(1:3)',...
                theta_x(4), theta_x(1:3)',...
                theta_angle(4), theta_angle(1:3)'];
        else
            [mu_y, sigma_y] = FitGaussianParameters(y);
            [mu_x, sigma_x] = FitGaussianParameters(x);
            [mu_angle, sigma_angle] = FitGaussianParameters(angle);
            P.clg(i).mu_y(k) = mu_y;
            P.clg(i).mu_x(k) = mu_x;
            P.clg(i).mu_angle(k) = mu_angle;
            P.clg(i).theta = [];
        end;
        P.clg(i).sigma_y(k) = sigma_y;
        P.clg(i).sigma_x(k) = sigma_x;
        P.clg(i).sigma_angle(k) = sigma_angle;
    end;
end;

loglikelihood = ComputeLogLikelihood(P, G, dataset);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('log likelihood: %f\n', loglikelihood);

