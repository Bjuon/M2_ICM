%% verify that subscores of UPDRS sum correctly

q = linq();

%% updrsIII
v = 4;
updrsIII = (q(dat).select(@(x) cat(1,x.visit(v).updrsIIIOffSOffM)).toArray)';
tremor = (q(dat).select(@(x) cat(1,x.visit(v).tremorOffSOffM)).toArray)';
rigidity = (q(dat).select(@(x) cat(1,x.visit(v).rigidityOffSOffM)).toArray)';
akinesia = (q(dat).select(@(x) cat(1,x.visit(v).akinesiaOffSOffM)).toArray)';
axial = (q(dat).select(@(x) cat(1,x.visit(v).axeOffSOffM)).toArray)';

total = tremor+rigidity+akinesia+axial;
[total updrsIII total~=updrsIII]

find((total~=updrsIII)&(~isnan(total))&(~isnan(updrsIII)))

v = 4;
updrsIII = (q(dat).select(@(x) cat(1,x.visit(v).updrsIIIOnSOffM)).toArray)';
tremor = (q(dat).select(@(x) cat(1,x.visit(v).tremorOnSOffM)).toArray)';
rigidity = (q(dat).select(@(x) cat(1,x.visit(v).rigidityOnSOffM)).toArray)';
akinesia = (q(dat).select(@(x) cat(1,x.visit(v).akinesiaOnSOffM)).toArray)';
axial = (q(dat).select(@(x) cat(1,x.visit(v).axeOnSOffM)).toArray)';

total = tremor+rigidity+akinesia+axial;
[total updrsIII total~=updrsIII]

find((total~=updrsIII)&(~isnan(total))&(~isnan(updrsIII)))

v = 5;
updrsIII = (q(dat).select(@(x) cat(1,x.visit(v).updrsIIIOffSOnM)).toArray)';
tremor = (q(dat).select(@(x) cat(1,x.visit(v).tremorOffSOnM)).toArray)';
rigidity = (q(dat).select(@(x) cat(1,x.visit(v).rigidityOffSOnM)).toArray)';
akinesia = (q(dat).select(@(x) cat(1,x.visit(v).akinesiaOffSOnM)).toArray)';
axial = (q(dat).select(@(x) cat(1,x.visit(v).axeOffSOnM)).toArray)';

total = tremor+rigidity+akinesia+axial;
[total updrsIII total~=updrsIII]

find((total~=updrsIII)&(~isnan(total))&(~isnan(updrsIII)))

v = 5;
updrsIII = (q(dat).select(@(x) cat(1,x.visit(v).updrsIIIOnSOnM)).toArray)';
tremor = (q(dat).select(@(x) cat(1,x.visit(v).tremorOnSOnM)).toArray)';
rigidity = (q(dat).select(@(x) cat(1,x.visit(v).rigidityOnSOnM)).toArray)';
akinesia = (q(dat).select(@(x) cat(1,x.visit(v).akinesiaOnSOnM)).toArray)';
axial = (q(dat).select(@(x) cat(1,x.visit(v).axeOnSOnM)).toArray)';

total = tremor+rigidity+akinesia+axial;
[total updrsIII total~=updrsIII]

find((total~=updrsIII)&(~isnan(total))&(~isnan(updrsIII)))

%% axial
v = 5;
axe = (q(dat).select(@(x) cat(1,x.visit(v).axeOnSOnM)).toArray)';
parole = (q(dat).select(@(x) cat(1,x.visit(v).paroleOnSOnM)).toArray)';
lever = (q(dat).select(@(x) cat(1,x.visit(v).leverOnSOnM)).toArray)';
posture = (q(dat).select(@(x) cat(1,x.visit(v).postureOnSOnM)).toArray)';
marche = (q(dat).select(@(x) cat(1,x.visit(v).marcheOnSOnM)).toArray)';
equilibre = (q(dat).select(@(x) cat(1,x.visit(v).equilibreOnSOnM)).toArray)';

total = parole + lever + posture + marche + equilibre;
[total axe total~=axe]

find((total~=axe)&(~isnan(total))&(~isnan(axe)))


%% Cognitive
v = 5;
frontal = (q(dat).select(@(x) cat(1,x.visit(v).frontal50)).toArray)';
mattis = (q(dat).select(@(x) cat(1,x.visit(v).Mattis)).toArray)';

find( ((isnan(frontal)&~isnan(mattis))|(~isnan(frontal)&isnan(mattis)))...
   &~(isnan(frontal)&isnan(mattis)) )