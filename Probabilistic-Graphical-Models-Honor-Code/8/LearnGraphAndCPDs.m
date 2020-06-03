function [P, G, loglikelihood] = LearnGraphAndCPDs(dataset, labels)

% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha) 
% labels: N x 2 true class labels for the examples. labels(i,j)=1 if the 
%         the ith example belongs to class j
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);
K = size(labels, 2);

G = zeros(10,2,K); % graph structures to learn
% initialization
for k=1:K
    G(2:end,:,k) = ones(9,2);
end

% estimate graph structure for each class
for k=1:K
    % fill in G(:,:,k)
    % use ConvertAtoG to convert a maximum spanning tree to a graph G
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    idx = labels(:, k) == 1;
    [A, ~] = LearnGraphStructure(dataset(idx, :, :));
    G(:, :, k) = ConvertAtoG(A);
    %%%%%%%%%%%%%%%%%%%%%%%%%
end

% estimate parameters

P.c = zeros(1,K);
% compute P.c
% the following code can be copied from LearnCPDsGivenGraph.m
% with little or no modification
%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE

% These are dummy lines added so that submit.m will run even if you 
% have not started coding. Please delete them.

P.c = sum(labels)/N;
P.clg = repmat(struct(...
    'mu_y', [], 'sigma_y', [],...
    'mu_x', [], 'sigma_x', [],...
    'mu_angle', [], 'sigma_angle', [],...
    'theta', zeros(2, 12)), 1, 10);

for k = 1:K
    idx = find(labels(:, k) == 1);
    if size(G, 3) > 1
        g = squeeze(G(:, :, k));
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