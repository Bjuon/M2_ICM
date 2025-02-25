function [APA_N,TrialParams_N] = Normalise_APA_signal(Signal1,TrialParams1)
% normalisation temporelle des signaux APA selon le cycle :
% TR ------- T0 -------  TO ------- FC1 ------- FC2
%  0 ------- 100 ------- 200------- 300 ------- 400


% Normalisation temporelle des signaux
var = Signal1.Data;
Fech = Signal1.Fech;
temps = floor(TrialParams1.EventsTime * Fech)+1;

var_coupe=var(:,temps(1):temps(2));
uncycle=0:(100/(temps(2)-temps(1))):100;
echant=0:1:100;
var_norm1 = zeros(size(var_coupe,1),size(echant,2));
for j=1:size(var_coupe,1)
    var_norm1(j,:) =interp1(uncycle,var_coupe(j,:),echant);
end;

var_coupe=var(:,temps(2)+1:temps(7));
uncycle=1:(299/(temps(7)-temps(2)-1)):300;
echant=1:1:300;
var_norm2 = zeros(size(var_coupe,1),size(echant,2));
for j=1:size(var_coupe,1)
    var_norm2(j,:) =interp1(uncycle,var_coupe(j,:),echant);
end;

% var_coupe=var(:,temps(4)+1:temps(5));
% uncycle=1:(99/(temps(5)-temps(4)-1)):100;
% echant=1:1:100;
% var_norm3 = zeros(size(var_coupe,1),size(echant,2));
% for j=1:size(var_coupe,1)
%     var_norm3(j,:) =interp1(uncycle,var_coupe(j,:),echant);
% end;
% 
% var_coupe=var(:,temps(5)+1:temps(7));
% uncycle=1:(99/(temps(7)-temps(5)-1)):100;
% echant=1:1:100;
% var_norm4 = zeros(size(var_coupe,1),size(echant,2));
% for j=1:size(var_coupe,1)
%     var_norm4(j,:) =interp1(uncycle,var_coupe(j,:),echant);
% end;

APA_N = Signal1;
APA_N.Data = cat(2,var_norm1,var_norm2);
APA_N.Time = 1:size(APA_N.Data,2);
APA_N.Fech = 1;
APA_N.Description = 'Time-Normalised';


% normalisation temporelle des evenements du pas
TrialParams_N = TrialParams1;
TrialParams_N.EventsTime(2) = 100;
TrialParams_N.EventsTime(3) = 300/(temps(7)-temps(2))*temps(3) + 400 - temps(7)*300/(temps(7)-temps(2));
TrialParams_N.EventsTime(4) = 300/(temps(7)-temps(2))*temps(4) + 400 - temps(7)*300/(temps(7)-temps(2));
TrialParams_N.EventsTime(5) = 300/(temps(7)-temps(2))*temps(5) + 400 - temps(7)*300/(temps(7)-temps(2));
TrialParams_N.EventsTime(6) = 300/(temps(7)-temps(2))*temps(6) + 400 - temps(7)*300/(temps(7)-temps(2));
TrialParams_N.EventsTime(7) = 400;
TrialParams_N.Description = 'Time-Normalised';

end