function acq=MAJ_APA(acq)


Fech = acq.Fech;

%% Détection des pics de vitesses

ind_TR = round(acq.tMarkers.TR*Fech);
ind_T0 = round(acq.tMarkers.T0*Fech);
ind_HO = round(acq.tMarkers.HO*Fech);
ind_TO = round(acq.tMarkers.TO*Fech);
ind_FC1 = round(acq.tMarkers.FC1*Fech);
ind_FO2 = round(acq.tMarkers.FO2*Fech);
ind_FC2 = round(acq.tMarkers.FC2*Fech);

try
    [val t] = min(acq.CP_AP(ind_T0:ind_HO));
    acq.primResultats.minAPAy_AP(1) = t - 1 +ind_T0;
    acq.primResultats.minAPAy_AP(2) = - (val - acq.CP_AP(ind_T0));
catch
    acq.primResultats.minAPAy_AP(1:2) = NaN;
end

try
    [val t] = max(sign(acq.CP_ML(ind_T0) - acq.CP_ML(ind_TO)) * (acq.CP_ML(ind_T0:ind_HO) - acq.CP_ML(ind_T0)));
    acq.primResultats.APAy_ML(1) = t - 1 +ind_T0;
    acq.primResultats.APAy_ML(2) = abs(acq.CP_ML(acq.primResultats.APAy_ML(1)) - acq.CP_ML(ind_T0));
catch
    acq.primResultats.APAy_ML(1:2) = NaN;
end

try
    [val t] = max(acq.V_CG_AP(ind_FC1:ind_FO2));
    acq.primResultats.Vm(1) = t - 1 + ind_FC1;
    acq.primResultats.Vm(2) = val;
catch
    acq.primResultats.Vm(1:2) = NaN;
end

try
    acq.primResultats.Vy_FO1(1) = ind_TO;
    acq.primResultats.Vy_FO1(2) = acq.V_CG_AP(ind_TO);
catch
    acq.primResultats.Vy_FO1(1:2) = NaN;
end

try
    [val t] = min(acq.V_CG_Z(ind_T0:ind_TO));
    acq.primResultats.VZmin_APA(1) = ind_T0 - 1 + t;
    acq.primResultats.VZmin_APA(2) = val;
catch
    acq.primResultats.VZmin_APA(1:2) = NaN;
end

try
    [val t] = min(acq.V_CG_Z(ind_TO:ind_FC1));
    acq.primResultats.V1(1) = ind_TO - 1 + t;
    acq.primResultats.V1(2) = val;
catch
    acq.primResultats.V1(1:2) = NaN;
end

try
    acq.primResultats.V2(1) = ind_FC1;
    acq.primResultats.V2(2) = acq.V_CG_Z(ind_FC1);
catch
    acq.primResultats.V2(1:2) = NaN;
end

end
