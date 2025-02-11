function [Artefacts_Detected_per_Sample,outputArg2] = Artefact_detection(data)
%Detect if artefact occur during an event 
%   Idee 1
%   Prends la time windows de la segmentation et si artefact depasse 5 SD
%   de l'essai on supprime l'evenement de la segmentation. 
%   
%   Idee 2 
%   on fait de meme mais sur l'ensemble de de l'essai et remplace
%   les zones artefactes par un joli signal 50Hz parfait qu'on exclura par
%   la suite 
%   
%   Probleme 1 
%   on calcule la SD sur l'amplitude du signal brut ou on fait une 
%   transformée de fourrier ?
%   
%   
%   
%   
%   
%   VOIR PAGE "IDEE ARTEFACTS" CAHIER BLEU


%for boucle sur files
% input args : , Window_size, LOGname, LogDir , trig_LFP, inputArgLog ,inputArgArt

%% ARTEFACTS 

for iBipolaire = 1:size(data.values{1, 1},2)
    
    local_values = data.values{1, 1}(:,iBipolaire) ;
    Duree_Enregistrement = length (local_values) ;
    InvalidArray = zeros(Duree_Enregistrement,1) ;
    Fs = data.Fs ;

    % Suppressions enormes artefacts
    ini_mad = mad(local_values) ;
    for iValue = 1:Duree_Enregistrement
        if abs(local_values(iValue)) > 5*ini_mad
            local_values(iValue)   = 0 ; 
            InvalidArray(iValue)   = 1 ;
        end
    end

    % Highpass
    local_values = highpass(local_values,4,Fs);

    % For function creation and evaluation
    seuil1 = 2 ;
    seuil2 = 3 ;
    Inspection = figure();
             plot(local_values, 'k')
    hold on, plot([0 length(local_values)] ,[mean(local_values) mean(local_values)], 'r')
%     hold on, plot([0 length(local_values)] ,[ seuil1*std(local_values)  seuil1*std(local_values)], 'b')
%     hold on, plot([0 length(local_values)] ,[ seuil2*std(local_values)  seuil2*std(local_values)], 'g')
%     hold on, plot([0 length(local_values)] ,[-seuil1*std(local_values) -seuil1*std(local_values)], 'b')
%     hold on, plot([0 length(local_values)] ,[-seuil2*std(local_values) -seuil2*std(local_values)], 'g')
    hold on, plot([0 length(local_values)] ,[ seuil1*mad(local_values)  seuil1*mad(local_values)], 'm')
    hold on, plot([0 length(local_values)] ,[ seuil2*mad(local_values)  seuil2*mad(local_values)], 'c')
    hold on, plot([0 length(local_values)] ,[-seuil1*mad(local_values) -seuil1*mad(local_values)], 'm')
    hold on, plot([0 length(local_values)] ,[-seuil2*mad(local_values) -seuil2*mad(local_values)], 'c')
%     uicontrol('String','OK','Callback','close all');
%     uiwait(Inspection)
        close all

    new_mad = mad(local_values) ;
    for iValue = 1:Duree_Enregistrement
        if abs(local_values(iValue)) > 3*new_mad
            InvalidArray(iValue)   = 1 ;
        end
    end
    Artefacts_Detected_per_Sample(:,iBipolaire) = InvalidArray ;
end

Artefacts_Detected_per_Sample(1,1) = data.Fs ;

% finir boucle sur file



outputArg2 = 0;

