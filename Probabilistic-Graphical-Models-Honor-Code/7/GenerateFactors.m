

function [factors, feature_count] = GenerateFactors(y, theta,...
    featureSet, modelParams)


num_chars = length(y);

K = modelParams.numHiddenStates;
features = featureSet.features;
num_features = length(features);
num_paras = featureSet.numParams;

factors = repmat(struct('var', [], 'card', [], 'val', []),...
    num_chars+num_chars-1, 1);

for i = 1:num_chars-1
    %Singleton factors
    factors(i) = struct('var', i, 'card', K, 'val', zeros(1, K));
    %Pairwise factors
    factors(i+num_chars) = struct('var', [i, i+1],...
        'card', [K, K], 'val', zeros(1, K*K));
end;
% Last singleton factor
factors(num_chars) = struct('var', num_chars, 'card', K,...
    'val', zeros(1, K));

feature_count = zeros(1, num_paras);
num_factors = length(factors);
for i = 1:num_factors
    var_fac = factors(i).var;
    card = factors(i).card;
    % exp^{Theta times Feature}
    val = zeros(1, prod(card));

    for j = 1:num_features
        var_fea = features(j).var;
        % A sampe scope for factor and feature is necessary
        if length(var_fac) ~= length(var_fac)
            continue;
        end;

        if all(sort(var_fac) == sort(var_fea))
            if all(y(features(j).var) == features(j).assignment)
                feature_count(features(j).paramIdx) =...
                    feature_count(features(j).paramIdx) + 1;
            end;
            % in_fea means if elements in var_fac is in var_fea
            % map_fea_fac mans its index in var_fea:
            %   var_fea[map_fea_fac] = var_fac
            [~, map_fea_fac] = ismember(var_fac, var_fea);
            assignment = features(j).assignment;

            idx = AssignmentToIndex(assignment(map_fea_fac), card);
            val(idx) = val(idx) + theta(features(j).paramIdx);
        end;

    end;
    factors(i).val = exp(val);
end;
    

end