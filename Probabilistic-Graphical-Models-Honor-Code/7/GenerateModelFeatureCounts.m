
function [ModelFeatureCounts] = GenerateModelFeatureCounts(F, featureSet)


num_factors = length(F);
num_features = length(featureSet.features);
num_paras = featureSet.numParams;

ModelFeatureCounts = zeros(1, num_paras);
features = featureSet.features;


for i = 1:num_factors
    var_fac = F(i).var;
    card = F(i).card;
    val = F(i).val;

    for j = 1:num_features
        var_fea = features(j).var;
        % A sampe scope for factor and feature is necessary
        if length(var_fac) ~= length(var_fac)
            continue;
        end;

        if all(sort(var_fac) == sort(var_fea))
            % in_fea means if elements in var_fac is in var_fea
            % map_fea_fac mans its index in var_fea:
            %   var_fea[map_fea_fac] = var_fac
            [~, map_fea_fac] = ismember(var_fac, var_fea);
            assignment = features(j).assignment;

            % ¡ÆP*fi, where P is a conditional probability (in other word,
            % factor), fi is feature which is 1 when it has a same scope
            % as P (or F(i))
            idx = AssignmentToIndex(assignment(map_fea_fac), card);
            ModelFeatureCounts(features(j).paramIdx) =...
                ModelFeatureCounts(features(j).paramIdx) + val(idx);
        end;
    end;
end;
    

end