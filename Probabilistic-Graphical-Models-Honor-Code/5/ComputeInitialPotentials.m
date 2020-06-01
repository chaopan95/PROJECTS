%COMPUTEINITIALPOTENTIALS Sets up the cliques in the clique tree that is
%passed in as a parameter.
%
%   P = COMPUTEINITIALPOTENTIALS(C) Takes the clique tree skeleton C which
%   is a struct with three fields:
%   - nodes: cell array representing the cliques in the tree.
%   - edges: represents the adjacency matrix of the tree.
%   - factorList: represents the list of factors that were used to build
%   the tree. 
%   
%   It returns the standard form of a clique tree P that we will use
%   through the rest of the assigment. P is struct with two fields:
%   - cliqueList: represents an array of cliques with appropriate factors 
%   from factorList assigned to each clique. Where the .val of each clique
%   is initialized to the initial potential of that clique.
%   - edges: represents the adjacency matrix of the tree. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function P = ComputeInitialPotentials(C)

% number of cliques
N = length(C.nodes);

% initialize cluster potentials 
P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), N, 1);
P.edges = zeros(N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% First, compute an assignment of factors from factorList to cliques. 
% Then use that assignment to initialize the cliques in cliqueList to 
% their initial potentials. 

% C.nodes is a list of cliques.
% So in your code, you should start with: P.cliqueList(i).var = C.nodes{i};
% Print out C to get a better understanding of its structure.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P.edges = C.edges;
M = length(C.factorList);

all_var = unique([C.factorList.var]);
all_var_cards = zeros(1, M);

alpha = zeros(1, M);

for j = 1:M
    
    % the number of factors = the number of unique variables in Bayesian
    % network
    var = C.factorList(j).var(1);
    all_var_cards(var) = C.factorList(j).card(1);

    % Assign each factor to certain cluster
    for i = 1:N
        if isempty(setdiff(C.factorList(j).var, C.nodes{i}))
            alpha(j) = i;
            break;
        end;
    end;
end;

% Initialize clusters
for i = 1:N
    P.cliqueList(i).var = C.nodes{i};
    P.cliqueList(i).card = all_var_cards(C.nodes{i});
    P.cliqueList(i).val = ones(1, prod(P.cliqueList(i).card));
end;

% Clusters' value
for j = 1:M
    P.cliqueList(alpha(j)) = FactorProduct(P.cliqueList(alpha(j)),...
        C.factorList(j));
end;

end

