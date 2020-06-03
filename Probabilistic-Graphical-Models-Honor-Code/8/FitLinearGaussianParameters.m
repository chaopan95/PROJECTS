function [Beta, sigma] = FitLinearGaussianParameters(X, U)

% Estimate parameters of the linear Gaussian model:
% X|U ~ N(Beta(1)*U(1) + ... + Beta(n)*U(n) + Beta(n+1), sigma^2);

% Note that Matlab/Octave index from 1, we can't write Beta(0).
% So Beta(n+1) is essentially Beta(0) in the text book.

% X: (M x 1), the child variable, M examples
% U: (M x N), N parent variables, M examples
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

M = size(U,1);
N = size(U,2);

Beta = zeros(N+1,1);
sigma = 1;

% collect expectations and solve the linear system
% A = [ E[U(1)],      E[U(2)],      ... , E[U(n)],      1     ; 
%       E[U(1)*U(1)], E[U(2)*U(1)], ... , E[U(n)*U(1)], E[U(1)];
%       ...         , ...         , ... , ...         , ...   ;
%       E[U(1)*U(n)], E[U(2)*U(n)], ... , E[U(n)*U(n)], E[U(n)] ]

% construct A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
A = ones(N+1, N+1);
for i = 1:N+1
    for j = 1:N+1
        if i == 1
            if j == N+1
                continue;
            end;
            Uij = U(:, j);
        else
            if j == N+1
                Uij = U(:, i-1);
            else
                Uij = U(:, i-1).*U(:, j);
            end;
        end;
        [mu, ~] = FitGaussianParameters(Uij);
        A(i, j) = mu;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% B = [ E[X]; E[X*U(1)]; ... ; E[X*U(n)] ]

% construct B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
B = ones(N+1, 1);

for i = 1:N+1
    if i == 1
        XUi = X;
    else
        XUi = X.*U(:, i-1);
    end;
    [mu, ~] = FitGaussianParameters(XUi);
    B(i) = mu;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% solve A*Beta = B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
Beta = A\B;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% then compute sigma according to eq. (11) in PA description
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
term2 = 0;
for i = 1:N
    for j = 1:N
        Ui = U(:, i);
        Uj = U(:, j);
        covUiUj = mean(Ui.*Uj) - mean(Ui)*mean(Uj);
        term2 = term2 + Beta(i)*Beta(j)*covUiUj;
    end;
end;
covX = mean(X.*X) - mean(X)^2;
sigma = sqrt(covX - term2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end