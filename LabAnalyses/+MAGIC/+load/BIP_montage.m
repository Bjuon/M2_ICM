

function [BIPlabels] = BIP_montage(RecID, BipolarRelabel, InputLabels)

BIPlabels = {};

% BipolarRelabel class : 'none' , 'classic' = classical electrodes, 'extended' => beaucoup de montages , '123' => quelques exemples de mono, bi et tri-polaire 


if     strcmp(BipolarRelabel,'classic')
    MontageCommun = {'Trigger','18D', '23D', '34D', '56D', '67D', '18G', '23G', '34G', '56G', '67G', };
elseif strcmp(BipolarRelabel,'extended')
    MontageCommun = {'Trigger','18D', '2D', '3D', '4D', '5D', '6D', '7D', '25D', '36D', '47D', '23D', '34D', '42D', '56D', '67D', '75D', '18G', '2G', '3G', '4G', '5G', '6G', '7G', '25G', '36G', '47G', '23G', '34G', '42G', '56G', '67G', '75G'};
elseif strcmp(BipolarRelabel,'123')
    MontageCommun = {'Trigger', '18D', '2D' , '3D' ,'23D', '34D', '234D', '18G', '5G' , '6G' , '56G', '67G', '567G',};

elseif strcmp(BipolarRelabel,'GaitInitiation')
    MontageCommun = {'Trigger','25D', '36D', '47D', '23D', '34D', '42D', '56D', '67D', '75D', '25G', '36G', '47G', '23G', '34G', '42G', '56G', '67G', '75G'};       
    if sum(contains(InputLabels, '1D'))
        MontageCommun{end+1} = '12D' ;
        MontageCommun{end+1} = '13D' ;
        MontageCommun{end+1} = '14D' ;        
    end
    if sum(contains(InputLabels, '8D') ~= contains(InputLabels, '18D'))
        MontageCommun{end+1} = '58D' ;
        MontageCommun{end+1} = '68D' ;
        MontageCommun{end+1} = '78D' ;        
    end
    if sum(contains(InputLabels, '1G'))
        MontageCommun{end+1} = '12G' ;
        MontageCommun{end+1} = '13G' ;
        MontageCommun{end+1} = '14G' ;        
    end
    if sum(contains(InputLabels, '8G') ~= contains(InputLabels, '18G'))
        MontageCommun{end+1} = '58G' ;
        MontageCommun{end+1} = '68G' ;
        MontageCommun{end+1} = '78G' ;        
    end
    if (sum(contains(InputLabels, '1G')) && sum(contains(InputLabels, '8G'))) || sum(contains(InputLabels, '18G'))
        MontageCommun{end+1} = '18G' ;
    end
    if (sum(contains(InputLabels, '1D')) && sum(contains(InputLabels, '8D'))) || sum(contains(InputLabels, '18D'))
        MontageCommun{end+1} = '18D' ;
    end
end

switch RecID
    case 'ParkPitie_2020_02_20_FEp'
        BIPlabels = MontageCommun ;
    case 'ParkPitie_2021_04_01_VIj'
        BIPlabels = MontageCommun ;
    case 'ParkPitie_2020_06_25_ALb'
        BIPlabels = MontageCommun ;
    case 'ParkRouen_2021_02_08_FRj'
        BIPlabels = MontageCommun ;
    case 'ParkPitie_2020_09_17_GAl'
        BIPlabels = MontageCommun ;
    case 'ParkPitie_2020_01_16_DEp'
        BIPlabels = MontageCommun ;
    case 'ParkPitie_2020_10_08_SOh'
        BIPlabels = MontageCommun ;
    case 'ParkRouen_2020_11_30_GUg'
        BIPlabels = MontageCommun ;
    case 'ParkPitie_2021_10_21_SAs'
        BIPlabels = MontageCommun ;
    case 'ParkPitie_2020_07_02_GIs'
        BIPlabels = MontageCommun ;
    case 'ParkPitie_2020_01_09_REa'
        BIPlabels = MontageCommun ;
    case ''
        BIPlabels = MontageCommun ;

    %FRa P03Rouen : Particulier
    case 'ParkRouen_2021_10_04_FRa'
        BIPlabels = MontageCommun ;
%         if     strcmp(BipolarRelabel,'classic')
%             BIPlabels = {'Trigger','18D', '23D', '34D', '56D', '67D', '18G', '23G', '34G', '67G', };
%         elseif strcmp(BipolarRelabel,'extended')
%             BIPlabels = {'Trigger','18D', '2D', '3D', '4D', '5D', '6D', '7D', '25D', '36D', '47D', '23D', '34D', '42D', '56D', '67D', '75D', '18G', '2G', '3G', '4G', '6G', '7G', '36G', '47G', '23G', '34G', '42G', '67G', };
%         elseif strcmp(BipolarRelabel,'123')
%             BIPlabels = {'Trigger', '18D', '2D' , '3D' ,'23D', '34D', '234D', '18G', '7G' , '6G' , '36G', '67G', '234G',};
%         end


        %% Gogait a montage per-enregistrement
    case 'ParkPitie_2019_02_21_BAg'
        BIPlabels = {'Trigger','23D', '34D', '56D', '67D', '23G', '34G', '56G', '67G' };       % 12G et D, '78D' et G et '45DG' qui ne fait pas sens car en diagonale de 2 segmentees
    case 'ParkPitie_2019_03_14_DRc'
        BIPlabels = {'Trigger','23D', '34D', '42D', '25D', '36D', '47D', '23G', '34G', '42G', '25G', '36G', '47G'}; % Sont exclus 12 13 14 58 68 78 G et D
    case 'ParkPitie_2020_02_13_DEj'
        BIPlabels = {'Trigger','23D', '34D', '42D', '25D', '36D', '47D', '23G', '34G', '42G', '25G', '36G', '47G'}; % Sont exclus 12 13 14 58 68 78 G et D
    case 'ParkPitie_2019_10_24_COm'
        BIPlabels = {'Trigger','23D', '34D', '42D', '25D', '36D', '47D', '23G', '34G', '42G', '25G', '36G', '47G'}; % Sont exclus 12 13 14 58 68 78 G et D
    case 'ParkPitie_2019_10_03_BEm'
        BIPlabels = {'Trigger','23D', '34D', '42D', '25D', '36D', '47D', '23G', '34G', '42G', '25G', '36G', '47G'}; % Sont exclus 12 13 14 58 68 78 G et D
    case 'ParkPitie_2019_11_28_LOp'
        BIPlabels = {'Trigger','23D', '34D', '42D', '25D', '36D', '47D', '23G', '34G', '42G', '25G', '36G', '47G'}; % Sont exclus 12 13 14 58 68 78 G et D

    case 'ParkPitie_2016_10_13_AUa'
        BIPlabels = {'Trigger','01D','12D','23D','01G','12G','23G'} ; % Medtronic 3389 ou Boston similaire



        %% Si vide

    otherwise 
        warning("AUCUN MONTAGE PERSONALISE N'EST DEFINI POUR CE PATIENT")
        dbstop()
        BIPlabels = MontageCommun ;


%%%%%%%%%%%% ATTENTION %%%%%%%%%%%
%% Prendre en compte FileNumber %%
%%               +              %%
%%     Ajouter les 'Trigger'    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end


if iscell(BIPlabels) && ~strcmp(BIPlabels{1}, 'Trigger')
    BIPlabels = [{'Trigger'} , BIPlabels(:)'] ;
end

% if todo_Relabellisation  % Renomme les hotspot pour moyennage plus tard.
%     switch RecID  
%         case 'ParkPitie_2020_02_20_FEp'
%             Relabellisation = {'18D', 'Motor'} ;
%         case ''
%     end
% end