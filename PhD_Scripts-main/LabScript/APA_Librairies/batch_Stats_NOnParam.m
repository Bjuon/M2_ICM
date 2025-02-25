nom_fichier_res = 'Resultats_Intra_NonParam.xls';
STims = {'CER' 'SMA' 'SHAM'};

[nom_fichiers path] =uigetfile({'*.xls;*.xlsx'},'Choix du/des fichier(s) xls','Multiselect','on');
if iscell(nom_fichiers)
    nb_files = length(nom_fichiers);
else
    nb_files =1;
end

Moys_Pre=[];
Std_Pre=[];
Moys_Post=[];
Std_Post=[];
N_stim_cumul = NaN*ones(3,nb_files); %%

for f = 1:nb_files
    if f==1 && ischar(nom_fichiers)
        Sheet = extract_spaces(nom_fichiers(1:end-4)); % On nomme chaque acquisition en commencant par le dossier ou elle se trouve
        fichier = nom_fichiers;
    else
        Sheet = [extract_spaces(nom_fichiers{f}(1:end-4))];
        fichier = nom_fichiers{f};
    end
    
    BdD = extrait_donnees_excel_v2([path fichier]);
    
    Nb_conditions = length(BdD); %% Une feuille par condition
    c=0;
    Headers={};
    Moys_Pre=[];
    Std_Pre=[];
    Moys_Post=[];
    Std_Post=[];

    Ps=[];
    Row1={};
    TMS={};
    for i=1:Nb_conditions
        Condition{i,1} = BdD(i).sheet_name;
        Data = BdD(i).donnees;
        [stops Pos]= scan_stop(BdD(i).vides);
        if ~isempty(Pos)
            Data(stops(Pos),:)=[];
        end
        n_stim = 0;
        stops = [0;stops;size(Data,1)+1];
        for k=1:2:length(stops)-2
            c=c+1;
            Pre = Data(stops(k)+1:stops(k+1)-1,:);
            Post = Data(stops(k+1)+1:stops(k+2)-1,:);
            Ps(c,:) = batch_Wilcox_2(Pre,Post);
%             Ps(c,:) = batch_tTest(Pre,Post);
            Moys_Pre(c,:) = nanmean(Pre,1);
            Std_Pre(c,:) = nanstd(Pre,1);
            Moys_Post(c,:) = nanmean(Post,1);
            Std_Post(c,:) = nanstd(Post,1);
            n_stim = n_stim+1;
            
%             eval(['MoyPre' STims{n_stim} '_' Condition{i} '(' num2str(f) ',:)=nanmean(Pre,1);']);
%             eval(['MoyPost' STims{n_stim} '_' Condition{i} '(' num2str(f) ',:)=nanmean(Post,1);']);
%             eval(['StdPre' STims{n_stim} '_' Condition{i} '(' num2str(f) ',:)=nanstd(Pre,1);']);
%             eval(['StdPost' STims{n_stim} '_' Condition{i} '(' num2str(f) ',:)=nanstd(Post,1);']);
%             
        end
        N_stim_cumul(i,f) = n_stim;
        
    end
    
    Params = BdD(i).noms;
    Ligne1 = {'P-values' 'TMS'};
    Ligne1 = [Ligne1 Params];
    vides = repmat({' '},1,length(Ligne1));
    Ligne2 = ['MoyennesPre' 'TMS' Params];   
    Ligne3 = ['STDPre' 'TMS' Params];
    Ligne4 = ['MoyennesPost' 'TMS' Params];   
    Ligne5 = ['STDPost)' 'TMS' Params];
    
    kki = 1;
    for kk=1:size(N_stim_cumul,1)
        for kkk = 1:N_stim_cumul(kk,f)
            if kkk==1
                Row1{kki,1} = cell2mat(Condition(kk));
            else
                Row1{kki,1} =[];
            end
            TMS{kki,1} = cell2mat(STims(kkk));
            kki = kki + 1;
        end
    end

%     Headers = [Row1 repmat(TMS,length(Condition),1)];
    Headers = [Row1 TMS];
    Ps_filtered = Ps;
    Ps_filtered(Ps>0.1)=NaN;
    Ps = troncature(Ps,3);
    Ps_filtered = troncature(Ps_filtered,3);
    Excl_p = [Headers num2cell(Ps)];
    Excl_p_filtered = [Headers num2cell(Ps_filtered)];
    
    Excl_p = [Ligne1;Excl_p];
%     Excl_p_filtered = [Ligne1;Excl_p_filtered];
    
    Excl_M_Pre = [Headers num2cell(troncature(Moys_Pre,3))];
    Excl_STD_Pre = [Headers num2cell(troncature(Std_Pre,3))];
    Excl_M_Post = [Headers num2cell(troncature(Moys_Post,3))];
    Excl_STD_Post = [Headers num2cell(troncature(Std_Post,3))];
%     Write = [Excl_p_filtered;Excl_M_Pre;Excl_STD_Pre;Excl_M_Post;Excl_STD_Post];
    Write2 = [Excl_p;vides;Ligne2;Excl_M_Pre;vides;Ligne3;Excl_STD_Pre;vides;Ligne4;Excl_M_Post;vides;Ligne5;Excl_STD_Post];
%     Write2 = [Excl_p;Excl_M_Pre;Excl_STD_Pre;Excl_M_Post;Excl_STD_Post];

%     xlswrite(P_values_BioM,Write,[Sheet '_Wilcox']);
    xlswrite(nom_fichier_res,Write2,[Sheet '_Wilcox']);
end

% Vides = NaN*ones(1,length(Params));
% 
% MN_YO = [MoyPreCER_MN_YO;Vides;MoyPostCER_MN_YO;Vides;MoyPreSMA_MN_YO;Vides;MoyPostSMA_MN_YO;Vides;MoyPreSHAM_MN_YO;Vides;MoyPostSHAM_MN_YO];
% MR_YO = [MoyPreCER_MR_YO;Vides;MoyPostCER_MR_YO;Vides;MoyPreSMA_MR_YO;Vides;MoyPostSMA_MR_YO;Vides;MoyPreSHAM_MR_YO;Vides;MoyPostSHAM_MR_YO];
% 
% MN_YF = [MoyPreCER_MN_YF;Vides;MoyPostCER_MN_YF;Vides;MoyPreSMA_MN_YF;Vides;MoyPostSMA_MN_YF;Vides;MoyPreSHAM_MN_YF;Vides;MoyPostSHAM_MN_YF];
% MR_YF = [MoyPreCER_MR_YF;Vides;MoyPostCER_MR_YF;Vides;MoyPreSMA_MR_YF;Vides;MoyPostSMA_MR_YF;Vides;MoyPreSHAM_MR_YF;Vides;MoyPostSHAM_MR_YF];
% 
% MN  = [MoyPreCER_MN ;Vides;MoyPostCER_MN ;Vides;MoyPreSMA_MN ;Vides;MoyPostSMA_MN ;Vides;MoyPreSHAM_MN ;Vides;MoyPostSHAM_MN ];
% MR  = [MoyPreCER_MR ;Vides;MoyPostCER_MR ;Vides;MoyPreSMA_MR ;Vides;MoyPostSMA_MR ;Vides;MoyPreSHAM_MR ;Vides;MoyPostSHAM_MR ];
% 
% MN_YO_Std = [StdPreCER_MN_YO;Vides;StdPostCER_MN_YO;Vides;StdPreSMA_MN_YO;Vides;StdPostSMA_MN_YO;Vides;StdPreSHAM_MN_YO;Vides;StdPostSHAM_MN_YO];
% MR_YO_Std = [StdPreCER_MR_YO;Vides;StdPostCER_MR_YO;Vides;StdPreSMA_MR_YO;Vides;StdPostSMA_MR_YO;Vides;StdPreSHAM_MR_YO;Vides;StdPostSHAM_MR_YO];
% 
% MN_YF_Std = [StdPreCER_MN_YF;Vides;StdPostCER_MN_YF;Vides;StdPreSMA_MN_YF;Vides;StdPostSMA_MN_YF;Vides;StdPreSHAM_MN_YF;Vides;StdPostSHAM_MN_YF];
% MR_YF_Std = [StdPreCER_MR_YF;Vides;StdPostCER_MR_YF;Vides;StdPreSMA_MR_YF;Vides;StdPostSMA_MR_YF;Vides;StdPreSHAM_MR_YF;Vides;StdPostSHAM_MR_YF];
% 
% MN_Std  = [StdPreCER_MN ;Vides;StdPostCER_MN ;Vides;StdPreSMA_MN ;Vides;StdPostSMA_MN ;Vides;StdPreSHAM_MN ;Vides;StdPostSHAM_MN ];
% MR_Std  = [StdPreCER_MR ;Vides;StdPostCER_MR ;Vides;StdPreSMA_MR ;Vides;StdPostSMA_MR ;Vides;StdPreSHAM_MR ;Vides;StdPostSHAM_MR ];
% 
% xlswrite('Moyennes_new.xls',[Params; num2cell(MN_YO)],'MN_YO');
% xlswrite('Moyennes_new.xls',[Params; num2cell(MR_YO)],'MR_YO');
% xlswrite('Moyennes_new.xls',[Params; num2cell(MN_YF)],'MN_YF');
% xlswrite('Moyennes_new.xls',[Params; num2cell(MR_YF)],'MR_YF');
% xlswrite('Moyennes_new.xls',[Params; num2cell(MN)],'MN');
% xlswrite('Moyennes_new.xls',[Params; num2cell(MR)],'MR');
% 
% xlswrite('STds_new.xls',[Params; num2cell(MN_YO_Std)],'MN_YO');
% xlswrite('STds_new.xls',[Params; num2cell(MR_YO_Std)],'MR_YO');
% xlswrite('STds_new.xls',[Params; num2cell(MN_YF_Std)],'MN_YF');
% xlswrite('STds_new.xls',[Params; num2cell(MR_YF_Std)],'MR_YF');
% xlswrite('STds_new.xls',[Params; num2cell(MN_Std)],'MN');
% xlswrite('STds_new.xls',[Params; num2cell(MR_Std)],'MR');
