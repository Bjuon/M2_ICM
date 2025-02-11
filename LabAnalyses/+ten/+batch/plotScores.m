dat = ten.load.data;

varStr = {'updrsIIIOff'};

varStr = {...
    'dementia'
    'hallucinations'
    'updrsI'
    'updrsIIOff'
    'updrsIIOn'
    'swallowingOff'
    'swallowingOn'
    'fallsOff'
    'fallsOn'
    'freezingOff'
    'freezingOn'
    'marcheADLOff'
    'marcheADLOn'
    'tremorOnSOffM'
    'tremorOffSOffM'
    'tremorOffSOnM'
    'tremorOnSOnM'
    'rigidityOnSOffM'
    'rigidityOffSOffM'
    'rigidityOffSOnM'
    'rigidityOnSOnM'
    'akinesiaOnSOffM'
    'akinesiaOffSOffM'
    'akinesiaOffSOnM'
    'akinesiaOnSOnM'
    'paroleOnSOffM'
    'paroleOffSOffM'
    'paroleOffSOnM'
    'paroleOnSOnM'
    'leverOnSOffM'
    'leverOffSOffM'
    'leverOffSOnM'
    'leverOnSOnM'
    'postureOnSOffM'
    'postureOffSOffM'
    'postureOffSOnM'
    'postureOnSOnM'
    'marcheOnSOffM'
    'marcheOffSOffM'
    'marcheOffSOnM'
    'marcheOnSOnM'
    'equilibreOnSOffM'
    'equilibreOffSOffM'
    'equilibreOffSOnM'
    'equilibreOnSOnM'
    'axeOnSOffM'
    'axeOffSOffM'
    'axeOffSOnM'
    'axeOnSOnM'
    'updrsIIIOnSOffM'
    'updrsIIIOffSOffM'
    'updrsIIIOffSOnM'
    'updrsIIIOnSOnM'
    'DSK'
    'OFF'
    'updrsIV'
    'agonists'
    'ldopaEquiv'
    'Mattis'
    'frontal50'
    'MADRS'};
 
 for i = 2:5
    ten.plot.scoreCorr(dat,varStr,i);
    orient tall;
    eval(['print -dpdf score' num2str(i)]);
    close;
 end
 
 for i = 1:numel(varStr)
    ten.plot.scoreRepeated(dat,varStr{i});
    orient tall;
    eval(['print -dpdf scoreRepeated_' varStr{i}]);
    close;
 end