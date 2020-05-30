% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = OptimizeLinearExpectations( I )
  % Inputs: An influence diagram I with a single decision node and one or
  %             more utility nodes.
  %         I.RandomFactors = list of factors for each random variable.
  %             These are CPDs, with the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional
  %             utilities.
  % Return value: the maximum expected utility of I and an optimal decision
  %     rule (represented again as a factor) that yields that expected
  %     utility. You may assume that there is a unique optimal decision.
  %
  % This is similar to OptimizeMEU except that we will have to account for
  % multiple utility factors.  We will do this by calculating the expected
  % utility factors and combining them, then optimizing with respect to
  % that combined expected utility factor.
  
  MEU = [];
  OptimalDecisionRule = [];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE
  %
  % A decision rule for D assigns, for each joint assignment to D's
  % parents, probability 1 to the best option from the EUF for that joint
  % assignment to D's parents, and 0 otherwise.  Note that when D has no
  % parents, it is a degenerate case we can handle separately for
  % convenience.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  MEU = 0;
  OptimalDecisionRule = struct('var', [], 'card', [], 'val', []);
  
  D = I.DecisionFactors(1);
  euf = struct('var', [], 'card', [], 'val', []);
  temp = I;
  for i = 1:length(I.UtilityFactors)
      temp.UtilityFactors = I.UtilityFactors(i);
      EUF = CalculateExpectedUtilityFactor(temp);
      euf = FactorSum(EUF, euf);
  end;
  
  % do the same thing like OptimizeMEU
  odr = struct('var', [], 'card', [], 'val', []);
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
