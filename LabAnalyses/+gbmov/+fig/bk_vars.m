% script to concatenate power/clinical variables using a defined f_range
ind = (f>=f_range(1)) & (f<=f_range(2));

%% Note that power is concatenated LEFT then RIGHT
pOn = nan(numel(m),6);
pOff = nan(numel(m),6);
peakOn = nan(numel(m),2);
peakOff = nan(numel(m),2);
maxIndOff = zeros(numel(m),6);
fsOn = nan(numel(m),1); %Sampling frequency in ON state 
fsOff = nan(numel(m),1);
validOn = zeros(numel(m),1); % valid ON power 
validOff = zeros(numel(m),1);
for i = 1:numel(m)
   % We have power in ON state
   if ~isnan(m(i).BASELINEASSIS.ON.L_power(1,1))
      pOn(i,:) = [mean(m(i).BASELINEASSIS.ON.L_power(ind,:),1) mean(m(i).BASELINEASSIS.ON.R_power(ind,:),1)];
      fsOn(i) = unique(m(i).BASELINEASSIS.ON.origFs);
      peakOn(i,1) = m(i).BASELINEASSIS.ON.L_peakMag(m(i).BASELINEASSIS.ON.L_bandmax);
      peakOn(i,2) = m(i).BASELINEASSIS.ON.R_peakMag(m(i).BASELINEASSIS.ON.R_bandmax);
   end
   % We have power in OFF state
   if ~isnan(m(i).BASELINEASSIS.OFF.L_power(1,1))
      maxIndOff(i,:) = [m(i).BASELINEASSIS.OFF.L_bandmax , m(i).BASELINEASSIS.OFF.R_bandmax];
      peakOff(i,1) = m(i).BASELINEASSIS.OFF.L_peakMag(m(i).BASELINEASSIS.OFF.L_bandmax);
      peakOff(i,2) = m(i).BASELINEASSIS.OFF.R_peakMag(m(i).BASELINEASSIS.OFF.R_bandmax);
      pOff(i,:) = [mean(m(i).BASELINEASSIS.OFF.L_power(ind,:),1) mean(m(i).BASELINEASSIS.OFF.R_power(ind,:),1)];
      fsOff(i) = unique(m(i).BASELINEASSIS.OFF.origFs);
   end
   if isnan(fsOn(i)) && isnan(fsOff(i))
   elseif isnan(fsOn(i)) && ~isnan(fsOff(i))
      validOff(i) = 1;
   elseif ~isnan(fsOn(i)) && isnan(fsOff(i))
      validOn(i) = 1;
   else
      if fsOn(i) < fsOff(i)
         validOff(i) = 1;
      elseif fsOn(i) > fsOff(i)
         validOn(i) = 1;
      else
         validOn(i) = 1;
         validOff(i) = 1;
      end
   end
end
maxIndOff = logical(maxIndOff);

% Dipole localizations, first three LEFT, last three RIGHT
locAP = [cat(1,m.L_loc_ap) , cat(1,m.R_loc_ap)];
locML = [cat(1,m.L_loc_ml) , cat(1,m.R_loc_ml)];
locDV = [cat(1,m.L_loc_dv) , cat(1,m.R_loc_dv)];
classAP = [cat(1,m.L_class_ap) , cat(1,m.R_class_ap)];
classML = [cat(1,m.L_class_ml) , cat(1,m.R_class_ml)];
classDV = [cat(1,m.L_class_dv) , cat(1,m.R_class_dv)];

% SIDE EFFECTS / MEDICATION, one number per patient
UPDRSIV = cat(1,m.UPDRS_IV);
EQUIVLDOPA = cat(1,m.EQUIVLDOPA);
OFF = cat(1,m.SCORE_OFF);
AGONIST = cat(1,m.AGONISTE);
LDOPA = cat(1,m.LDOPA);
DYSKINESIA = cat(1,m.DYSKINESIA);
DUREE_MP = cat(1,m.DUREE_MP);
DUREE_LDOPA = cat(1,m.DUREE_LDOPA);

% UPDRS III
% NOTE SCORES ARE ORGANIZED FOR HEMIBODY CONTRALATERAL TO ELECTRODES!
tempL = cat(1,m.BRADYKINESIA_OFF_L);
tempR = cat(1,m.BRADYKINESIA_OFF_R);
BRADYKINESIA_OFF = [repmat(tempR,1,3) repmat(tempL,1,3)];
tempL = cat(1,m.RIGIDITY_OFF_L);
tempR = cat(1,m.RIGIDITY_OFF_R);
RIGIDITY_OFF = [repmat(tempR,1,3) repmat(tempL,1,3)];
tempL = cat(1,m.TREMOR_OFF_G);
tempR = cat(1,m.TREMOR_OFF_D);
TREMOR_OFF = [repmat(tempR,1,3) repmat(tempL,1,3)];
temp = cat(1,m.AXIAL_OFF);
AXIAL_OFF = [repmat(temp,1,3) repmat(temp,1,3)];
tempL = cat(1,m.BRADYKINESIA_ON_L);
tempR = cat(1,m.BRADYKINESIA_ON_R);
BRADYKINESIA_ON = [repmat(tempR,1,3) repmat(tempL,1,3)];
tempL = cat(1,m.RIGIDITY_ON_L);
tempR = cat(1,m.RIGIDITY_ON_R);
RIGIDITY_ON = [repmat(tempR,1,3) repmat(tempL,1,3)];
tempL = cat(1,m.TREMOR_ON_G);
tempR = cat(1,m.TREMOR_ON_D);
TREMOR_ON = [repmat(tempR,1,3) repmat(tempL,1,3)];
temp = cat(1,m.AXIAL_ON);
AXIAL_ON = [repmat(temp,1,3) repmat(temp,1,3)];
tempL = cat(1,m.UPDRSIII_OFF_L);
tempR = cat(1,m.UPDRSIII_OFF_R);
UPDRSIII_OFF = [repmat(tempR,1,3) repmat(tempL,1,3)];
tempL = cat(1,m.UPDRSIII_ON_L);
tempR = cat(1,m.UPDRSIII_ON_R);
UPDRSIII_ON = [repmat(tempR,1,3) repmat(tempL,1,3)];

BR_OFF = BRADYKINESIA_OFF + RIGIDITY_OFF;
BR_ON = BRADYKINESIA_ON + RIGIDITY_ON;

PERCENT_UPDRSIII = 100*(UPDRSIII_OFF-UPDRSIII_ON)./UPDRSIII_OFF;
PERCENT_BR = 100*(BR_OFF-BR_ON)./BR_OFF;

PERCENT_BRADYKINESIA = 100*(BRADYKINESIA_OFF-BRADYKINESIA_ON)./BRADYKINESIA_OFF;
ind = (BRADYKINESIA_OFF==0)&(BRADYKINESIA_ON==0);
PERCENT_BRADYKINESIA(ind) = 0;

PERCENT_RIGIDITY = 100*(RIGIDITY_OFF-RIGIDITY_ON)./RIGIDITY_OFF;
ind = (RIGIDITY_OFF==0)&(RIGIDITY_ON==0);
PERCENT_RIGIDITY(ind) = 0;

PERCENT_AXIAL = 100*(AXIAL_OFF-AXIAL_ON)./AXIAL_OFF;
ind = (AXIAL_OFF==0)&(AXIAL_ON==0);
PERCENT_AXIAL(ind) = 0;

PERCENT_TREMOR = 100*(TREMOR_OFF-TREMOR_ON)./TREMOR_OFF;
ind = (TREMOR_OFF==0)&(TREMOR_ON==0);
PERCENT_TREMOR(ind) = 0;

PERCENT_POWER = 100*(pOff-pOn)./pOff;
PERCENT_PEAKPOWER = 100*(peakOff-peakOn)./peakOff;