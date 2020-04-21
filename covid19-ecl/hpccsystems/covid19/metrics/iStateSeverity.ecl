EXPORT iStateSeverity := DATASET([
                                {'Regressing', 7},
                                {'Spreading', 6},
                                {'Emerging', 5},
                                {'Stabilizing', 4},
                                {'Stabilized', 3},
                                {'Recovering', 2},
                                {'Recovered', 1},
                                {'Initial', 0}]
                ,{STRING stateName, UNSIGNED severity});