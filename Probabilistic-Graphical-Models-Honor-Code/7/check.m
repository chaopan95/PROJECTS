if sum(sum(sampleUncalibratedTree.edges ~= P.edges))
    error('UncalibratedTree.edges is wrong')
end;
for i = 1:length(P.cliqueList)
    if sum(P.cliqueList(i).var ~=...
            sampleUncalibratedTree.cliqueList(i).var)
        error('UncalibratedTree.cliqueList.var is wrong');
    end;
    if sum(P.cliqueList(i).card ~=...
            sampleUncalibratedTree.cliqueList(i).card)
        error('UncalibratedTree.cliqueList.card is wrong');
    end;
    if sum(P.cliqueList(i).val ~=...
            sampleUncalibratedTree.cliqueList(i).val)
        
        error('UncalibratedTree.cliqueList.val is wrong');
    end;
end;