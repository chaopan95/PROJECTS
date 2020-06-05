% File: EM_HMM.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [P, loglikelihood, ClassProb, PairProb] = EM_HMM(...
    actionData, poseData, G, InitialClassProb, InitialPairProb, maxIter)

% INPUTS
% actionData: structure holding the actions as described in the PA
% poseData: N x 10 x 3 matrix, where N is number of poses in all actions
% G: graph parameterization as explained in PA description
% InitialClassProb: N x K matrix, initial allocation of the N poses to the
%   K states. InitialClassProb(i,j) is the probability that example i
%   belongs to state j.
%   This is described in more detail in the PA.
% InitialPairProb: V x K^2 matrix, where V is the total number of pose
%   transitions in all HMM action models, and K is the number of states.
%   This is described in more detail in the PA.
% maxIter: max number of iterations to run EM

% OUTPUTS
% P: structure holding the learned parameters as described in the PA
% loglikelihood: #(iterations run) x 1 vector of loglikelihoods stored for
%   each iteration
% ClassProb: N x K matrix of the conditional class probability of the N
%   examples to the K states in the final iteration. ClassProb(i,j) is
%   the probability that example i belongs to state j. This is described
%   in more detail in the PA.
% PairProb: V x K^2 matrix, where V is the total number of pose transitions
%   in all HMM action models, and K is the number of states. This is
%   described in more detail in the PA.

% Initialize variables
N = size(poseData, 1);
K = size(InitialClassProb, 2);
L = size(actionData, 2); % number of actions
V = size(InitialPairProb, 1);

ClassProb = InitialClassProb;
PairProb = InitialPairProb;

loglikelihood = zeros(maxIter,1);

P.c = [];
P.clg.sigma_x = [];
P.clg.sigma_y = [];
P.clg.sigma_angle = [];

% EM algorithm
for iter=1:maxIter

    % M-STEP to estimate parameters for Gaussians
    % Fill in P.c, the initial state prior probability (NOT the class
    % probability as in PA8 and EM_cluster.m)
    % Fill in P.clg for each body part and each class
    % Make sure to choose the right parameterization based on G(i,1)
    % Hint: This part should be similar to your work from PA8 and
    % EM_cluster.m

    P.c = zeros(1,K);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % initial state prior probability
    % each action has a series of poses/states
    for l = 1:L
        % initial state
        ini_st = actionData(l).marg_ind(1);
        % initial state probability to each action/class
        P.c = P.c + ClassProb(ini_st, :);
    end;
    P.c = P.c/L;
    
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

    % M-STEP to estimate parameters for transition matrix
    % Fill in P.transMatrix, the transition matrix for states
    % P.transMatrix(i,j) is the probability of transitioning from state i
    % to state j
    P.transMatrix = zeros(K,K);

    % Add Dirichlet prior based on size of poseData to avoid 0
    % probabilities
    P.transMatrix = P.transMatrix + size(PairProb,1) * .05;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Transition CPD
    tran_mat = reshape(mean(PairProb, 1), K, K);
    P.transMatrix = (tran_mat+0.05)./repmat(sum(tran_mat+0.05, 2), 1, K);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % E-STEP preparation: compute the emission model factors (emission
    % probabilities) in log space for each of the poses in all actions =
    % log( P(Pose | State) )
    % Hint: This part should be similar to (but NOT the same as) your code
    % in EM_cluster.m

    logEmissionProb = zeros(N,K);

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
            logEmissionProb(n, k) = log_joint;
        end;
    end;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % E-STEP to compute expected sufficient statistics
    % ClassProb contains the conditional class probabilities for each pose
    % in all actions
    % PairProb contains the expected sufficient statistics for the
    % transition CPDs (pairwise transition probabilities)
    % Also compute log likelihood of dataset for this iteration
    % You should do inference and compute everything in log space, only
    % converting to probability space at the end
    % Hint: You should use the logsumexp() function here to do probability
    % normalization in log space to avoid numerical issues

    ClassProb = zeros(N,K);
    PairProb = zeros(V,K^2);
    loglikelihood(iter) = 0;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % log-likelihood for single iteration
    lll = 0;
    for act = 1:length(actionData)
        % Construct factors: log( P(S1) ), log( P(Si|Si-1) ),
        % log( P(Pose | State) )
        marg_ind = actionData(act).marg_ind;
        pair_ind = actionData(act).pair_ind;
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

        [M, PCalibrated] = ComputeExactMarginalsHMM(F);
        %PCalibrated
        cliqueList = PCalibrated.cliqueList;
        lll = lll + sum(logsumexp(cliqueList(1).val));

        for m = 1:length(M)
            denominator = logsumexp(M(m).val);
            ClassProb(M(m).var+marg_ind(1)-1, :) =...
                exp(M(m).val - denominator);
        end;
        for cl =1:length(cliqueList)
            denominator = logsumexp(cliqueList(cl).val);
            PairProb(cliqueList(cl).var(1)+pair_ind(1)-1, :) =...
                exp(cliqueList(cl).val - denominator);
        end;

    end;
    loglikelihood(iter) = lll;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    % Print out loglikelihood
    disp(sprintf('EM iteration %d: log likelihood: %f',...
        iter, loglikelihood(iter)));
    if exist('OCTAVE_VERSION')
        fflush(stdout);
    end
  
    % Check for overfitting by decreasing loglikelihood
    if iter > 1
        if loglikelihood(iter) < loglikelihood(iter-1)
            break;
        end;
    end;
  
end;

% Remove iterations if we exited early
loglikelihood = loglikelihood(1:iter);


end