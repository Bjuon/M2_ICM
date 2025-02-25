[files dossier] = uigetfile('*.c3d','Choix du/des fichier(s) c3d','Multiselect','on');

wb = waitbar(0);
set(wb,'Name','Please wait... loading data');

%%Cas ou selection d'un fichier unique
if iscell(files)
    nb_acq = length(files);
else
    nb_acq =1;
end

for i = 1:nb_acq
    if i==1 && ischar(files)
        acq = extract_spaces(files(1:end-4));
        fichier = files;
    else
        acq = extract_spaces(files{i}(1:end-4));
        fichier = files{i};
    end;
    
    waitbar(i/length(files),wb,['Marche(s) ' num2str(i) '/' num2str(nb_acq)]);
    
    %Lecture du fichier
    DATA = lire_donnees_c3d(strcat(dossier,fichier));
    h = btkReadAcquisition(strcat(dossier,fichier));
    Freq_vid = btkGetPointFrequency(h);
    
    %Extraction de la GRF sur la PF
    Fres = DATA.actmec(:,7:9);
    fin = round(find(Fres==0,1,'first')) - 2;
    CP_filt = filtrage(DATA.actmec(1:fin+1,1:2),'fir',30,8,Freq_vid);
    t = (0:fin)*1/Freq_vid;
    
    % Calcul des vitesses du CG
    [V_CG_PF V_CG_Der] = calcul_vitesse_CG_v2(Fres,Freq_vid,DATA);
    
    %Extraction des marqueurs temporels d'inititation du pas (!!Faire une fonction plus tard!!)
    evts = sort(DATA.events.temps);
    Donnes.(acq).T0 = calcul_APA_T0_v3(CP_filt(1:evts(1)*Freq_vid,:),t(1:evts(1)*Freq_vid));
    Donnes1.(acq).T0 = calcul_APA_T0(CP_filt(1:evts(1)*Freq_vid,:),t(1:evts(1)*Freq_vid));
end
close(wb);