function accuracy = ClassifyDataset(dataset, labels, P, G)
% returns the accuracy of the model P and graph G on the dataset 
%
% Inputs:
% dataset: N x 10 x 3, N test instances represented by 10 parts
% labels:  N x 2 true class labels for the instances.
%          labels(i,j)=1 if the ith instance belongs to class j 
% P: struct array model parameters (explained in PA description)
% G: graph structure and parameterization (explained in PA description) 
%
% Outputs:
% accuracy: fraction of correctly classified instances (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);
accuracy = 0.0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
res = zeros(N, 2);


for n = 1:N
    prob = zeros(1, 2);
    for k = 1:2
        if size(G, 3) > 1
            g = reshape(G(:, :, k), 10, 2);
        else
            g = G;
        end;
        
        X = reshape(dataset(n, :, :), 10, 3);
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
        prob(k) = prior*exp(log_joint);
    end;
    [~, idx] = max(prob);

    res(n, idx) = 1;
end;

accuracy = sum(res(:, 1) == labels(:, 1))/N;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Accuracy: %.2f\n', accuracy);