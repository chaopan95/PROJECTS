% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = OptimizeMEU( I )

  % Inputs: An influence diagram I with a single decision node and a single
  %         utility node.
  %         I.RandomFactors = list of factors for each random variable.
  %         These are CPDs, with the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional
  %         utilities.
  % Return value: the maximum expected utility of I and an optimal decision
  %         rule (represented again as a factor) that yields that expected
  %         utility.
  
  % We assume I has a single decision node.
  % You may assume that there is a unique optimal decision.
  D = I.DecisionFactors(1);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE...
  % 
  % Some other information that might be useful for some implementations
  % (note that there are multiple ways to implement this):
  % 1.  It is probably easiest to think of two cases - D has parents and D 
  %     has no parents.
  % 2.  You may find the Matlab/Octave function setdiff useful.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  MEU = 0;
  odr = struct('var', [], 'card', [], 'val', []);

  euf = CalculateExpectedUtilityFactor(I);

  odr.var = euf.var;
  odr.card = euf.card;
  odr.val = zeros(1, prod(odr.card));

  num_var = length(euf.var);
  map_euf_to_D = zeros(1, num_var);
  map_D_to_euf = zeros(1, num_var);

  for i = 1:length(D.var)
      % idx of D.var in euf.var, euf.var(map_euf_to_D) = D.var
      map_euf_to_D(i) = find(euf.var == D.var(i));
      % idx of euf.var in D.var, D.var(map_D_to_euf) = euf.var
      map_D_to_euf(i) = find(D.var == euf.var(i));
  end;

  if num_var == 1
      [~, idx] = max(euf.val);
      odr.val(idx) = 1;
  else
      assignments_X = IndexToAssignment(1:prod(D.card(2:end)), D.card(2:end));
      % for each row of assignments of parents X, we supply a decision
      % variable to form a new sub-assignment. Besides, in this case, 
      % decision variable has 2 value 1 and 2.
      for i = 1:length(assignments_X)
          sub_assignment_D = [[1:2]', repmat(assignments_X(i, :), 2, 1)];
          sub_assignment_euf = sub_assignment_D(:, map_D_to_euf);
          sub_idx = AssignmentToIndex(sub_assignment_euf, euf.card);
          [~, idx] = max(euf.val(sub_idx));
          odr.val(sub_idx(idx)) = 1;
      end;
  end;

  OptimalDecisionRule = odr;
  F = FactorProduct(OptimalDecisionRule, euf);
  MEU = sum(F.val);
  
end
