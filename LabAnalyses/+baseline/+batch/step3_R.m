function step3_R(csvFile, data, e, protocol)


lfp = baseline.batch.matrixForR_optim_trial(data, e, protocol);

export(cell2dataset(lfp),'File',csvFile);

clear lfp

