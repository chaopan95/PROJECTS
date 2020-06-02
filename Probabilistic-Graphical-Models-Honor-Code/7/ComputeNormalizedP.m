

function [F] = ComputeNormalizedP(P, F)


for i = 1:length(F)
    for j = 1:length(P.cliqueList)
        if isempty(setdiff(F(i).var, P.cliqueList(j).var))
            var_to_remove = setdiff(P.cliqueList(j).var, F(i).var);
            F(i) = FactorMarginalization(P.cliqueList(j), var_to_remove);
            F(i).val = F(i).val/sum(F(i).val);
            break;
        end;
    end;
end;


end