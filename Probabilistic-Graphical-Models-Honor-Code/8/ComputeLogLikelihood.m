function loglikelihood = ComputeLogLikelihood(P, G, dataset)
% returns the (natural) log-likelihood of data given the model and graph
% structure
%
% Inputs:
% P: struct array parameters (explained in PA description)
% G: graph structure and parameterization (explained in PA description)
%
%    NOTICE that G could be either 10x2 (same graph shared by all classes)
%    or 10x2x2 (each class has its own graph). your code should compute
%    the log-likelihood using the right graph.
%
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
% 
% Output:
% loglikelihood: log-likelihood of the data (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset,1); % number of examples
K = length(P.c); % number of classes

loglikelihood = 0;
% You should compute the log likelihood of data as in eq. (12) and (13)
% in the PA description
% Hint: Use lognormpdf instead of log(normpdf) to prevent underflow.
%       You may use log(sum(exp(logProb))) to do addition in the original
%       space, sum(Prob).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE

for n = 1:N
    X = reshape(dataset(n, :, :), 10, 3);
    prob = 0;
    for k = 1:K
        if size(G, 3) > 1
            % 10x2x2 (each class has its own graph)
            g = reshape(G(:, :, k), 10, 2);
        else
            % 10x2 (same graph shared by all classes)
            g = G;
        end;
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
        prior = P.c(k);
        prob = prob + prior*exp(log_joint);
    end;
    loglikelihood = loglikelihood + log(prob);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




end