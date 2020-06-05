% File: EM_cluster.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [P, loglikelihood, ClassProb] = EM_cluster(...
    poseData, G, InitialClassProb, maxIter)

% INPUTS
% poseData: N x 10 x 3 matrix, where N is number of poses;
%   poseData(i,:,:) yields the 10x3 matrix for pose i.
% G: graph parameterization as explained in PA8
% InitialClassProb: N x K, initial allocation of the N poses to the K
%   classes. InitialClassProb(i,j) is the probability that example i
%   belongs to class j
% maxIter: max number of iterations to run EM

% OUTPUTS
% P: structure holding the learned parameters as described in the PA
% loglikelihood: #(iterations run) x 1 vector of loglikelihoods stored for
%   each iteration
% ClassProb: N x K, conditional class probability of the N examples to the
%   K classes in the final iteration. ClassProb(i,j) is the probability
%   that example i belongs to class j

% Initialize variables
N = size(poseData, 1);
K = size(InitialClassProb, 2);

ClassProb = InitialClassProb;

loglikelihood = zeros(maxIter,1);

P.c = [];
P.clg.sigma_x = [];
P.clg.sigma_y = [];
P.clg.sigma_angle = [];

% EM algorithm
for iter=1:maxIter
    % M-STEP to estimate parameters for Gaussians
    %
    % Fill in P.c with the estimates for prior class probabilities
    % Fill in P.clg for each body part and each class
    % Make sure to choose the right parameterization based on G(i,1)
    %
    % Hint: This part should be similar to your work from PA8
  
    P.c = zeros(1, K);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    P.c = sum(ClassProb, 1)/N;
    P.clg = repmat(struct(...
        'mu_y', [], 'sigma_y', [],...
        'mu_x', [], 'sigma_x', [],...
        'mu_angle', [], 'sigma_angle', [],...
        'theta', zeros(K, 12)), 1, 10);

    for k = 1:K
        if size(G, 3) > 1
            g = reshape(G(:, :, k), 10, 2);
        else
            g = G;
        end;
        for i = 1:10
            y = squeeze(poseData(:, i, 1));
            x = squeeze(poseData(:, i, 2));
            angle = squeeze(poseData(:, i, 3));
            if g(i, 1)
                parent = g(i, 2);
                data_parent = squeeze(poseData(:, parent, :));

                [theta_y, sigma_y] = FitLG(y, data_parent,...
                    ClassProb(:, k));
                [theta_x, sigma_x] = FitLG(x, data_parent,...
                    ClassProb(:, k));
                [theta_angle, sigma_angle] = FitLG(angle, data_parent,...
                    ClassProb(:, k));

                P.clg(i).theta(k, :) = [...
                    theta_y(4), theta_y(1:3)',...
                    theta_x(4), theta_x(1:3)',...
                    theta_angle(4), theta_angle(1:3)'];
            else
                [mu_y, sigma_y] = FitG(y, ClassProb(:, k));
                [mu_x, sigma_x] = FitG(x, ClassProb(:, k));
                [mu_angle, sigma_angle] = FitG(angle, ClassProb(:, k));
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % E-STEP to re-estimate ClassProb using the new parameters
    %
    % Update ClassProb with the new conditional class probabilities.
    % Recall that ClassProb(i,j) is the probability that example i belongs
    % to class j.
    %
    % You should compute everything in log space, and only convert to
    % probability space at the end.
    %
    % Tip: To make things faster, try to reduce the number of calls to
    % lognormpdf, and inline the function (i.e., copy the lognormpdf code
    % into this file)
    %
    % Hint: You should use the logsumexp() function here to do
    % probability normalization in log space to avoid numerical issues
  
    ClassProb = zeros(N, K);
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            prior = P.c(k);
            ClassProb(n, k) = log(prior) + log_joint;
        end;
    end;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Compute log likelihood of dataset for this iteration
    % Hint: You should use the logsumexp() function here
    loglikelihood(iter) = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %loglikelihood(iter) = sum(logsumexp(ClassProb));
    denominatr = zeros(1, N);
    for n = 1:N
        denominatr(n) = logsumexp(ClassProb(n, :));
        
        ClassProb(n, :) = ClassProb(n, :) - denominatr(n);
    end;    
    ClassProb = exp(ClassProb);
    loglikelihood(iter) = sum(denominatr);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Print out loglikelihood
    disp(sprintf('EM iteration %d: log likelihood: %f', ...
        iter, loglikelihood(iter)));
    if exist('OCTAVE_VERSION')
        fflush(stdout);
    end
  
  % Check for overfitting: when loglikelihood decreases
    if iter > 1
        if loglikelihood(iter) < loglikelihood(iter-1)
            break;
        end;
    end;
end;

% Remove iterations if we exited early
loglikelihood = loglikelihood(1:iter);



end
