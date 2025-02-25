% modifs par rapport à la version calcul_auto_APA_marker.m
% on renomme : 
%   APAy --> APA_antpost
%   APAy_lateral --> APA_lateral

% on ajoute également la dimension du trigger qui peut être déclencher après le début d'enregistrement 
% -> On soustrait tMarkers(0) à chaque  I

function Trial_Res_APA = calcul_auto_APA_marker_v2(Trial_APA,Trial_TrialParams,Trial_Res_APA)
% infos
Trial_Res_APA.TrialName = Trial_APA.CP_Position.TrialName;
Trial_Res_APA.TrialNum = Trial_APA.CP_Position.TrialNum;
Trial_Res_APA.Description = Trial_APA.CP_Position.Description;

try
    %% Extraction des fields d'intérêt
    tMarkers = Trial_TrialParams.EventsTime;
    Fech = Trial_APA.CP_Position.Fech;
    
    %% Valeur minimale du CP en antéropostérieur (APA_antpost)
    [C,I] = min(Trial_APA.CP_Position.Data(1,round(tMarkers(2)*Fech):round(tMarkers(3)*Fech)));
    Trial_Res_APA.APA_antpost(1:2) = [mean(Trial_APA.CP_Position.Data(1,round(tMarkers(1)*Fech+1):round(tMarkers(2)*Fech))) - C , I(1)+round(tMarkers(2)*Fech)-1-round(tMarkers(1)*Fech)];
    clear C I;
    %% Déplacement latéral max du CP lors des APA (APA_lat)
    %% Valeur minimale du CP en antéropostérieur (APA)
    [C,I] = max(sign(Trial_APA.CP_Position.Data(2,round(tMarkers(2)*Fech)) - Trial_APA.CP_Position.Data(2,round(tMarkers(4)*Fech)))*(Trial_APA.CP_Position.Data(2,round(tMarkers(2)*Fech):round(tMarkers(3)*Fech)) - Trial_APA.CP_Position.Data(2,round(tMarkers(2)*Fech))));
    Trial_Res_APA.APA_lateral(1:2) = [abs(mean(Trial_APA.CP_Position.Data(2,round(tMarkers(1)*Fech+1):round(tMarkers(2)*Fech))) - Trial_APA.CP_Position.Data(2,I(1)+round(tMarkers(2)*Fech)-1)) , ...
        I(1)+round(tMarkers(2)*Fech)-round(tMarkers(1)*Fech)];
    
    %% Vitesse maximale entre HO et FO2
    [Trial_Res_APA.Vm(1,1) ind] = max(Trial_APA.CG_Speed.Data(1,round(tMarkers(3)*Fech):round(tMarkers(6)*Fech)));
    Trial_Res_APA.Vm(1,2) = round(tMarkers(3)*Fech) + ind - round(tMarkers(1)*Fech);
    
    %% Vitesse verticale minimale pendant les APA
    [Trial_Res_APA.VZmin_APA(1,1) Trial_Res_APA.VZmin_APA(1,2)] = min(Trial_APA.CG_Speed.Data(3,round(tMarkers(1)*Fech)+1:round(tMarkers(4)*Fech)));

    %% Vitesse minimale pendant l'éxecution du pas
    [Trial_Res_APA.V1(1) ind] = min(Trial_APA.CG_Speed.Data(3,round(tMarkers(4)*Fech):round(tMarkers(5)*Fech)));
    Trial_Res_APA.V1(2) = ind + round(tMarkers(4)*Fech) - round(tMarkers(1)*Fech);
    
    %% Vitesse verticale lors du foot-contact
    Trial_Res_APA.V2 = [Trial_APA.CG_Speed.Data(3,round(tMarkers(5)*Fech)) round(tMarkers(5)*Fech)-round(tMarkers(1)*Fech)];
end







