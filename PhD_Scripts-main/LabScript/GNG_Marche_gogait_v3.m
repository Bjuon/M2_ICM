%% script pour la tache de go-nogo Marche sous psychtoolbox
% Date : 10/03/2015
% Update : Dec 2016 pour protocole GAITPARK / GBMOV2

% Note : dans le path : D:\MATLAB\Psychtoolbox\Psychtoolbox\PsychBasic\MatlabWindowsFilesR2007a\
% doit apparaitre avant
% 'D:\MATLAB\Psychtoolbox\Psychtoolbox\PsychBasic\'

% Clear the workspace
close all;
clear all;
sca;
  
% chargement en mémoire de la toolbox Cogent
% chemin = 'G:\MATLAB'
%chemin = 'N:\PF-Marche\04_Toolbox\Marche-GoNoGo';
chemin =  'N:\PF-Marche\04_Toolbox\Marche-GoNoGo';
addpath(genpath(chemin))
cd(chemin)
% Screen('Preference', 'SkipSyncTests', 1);


% trigger eeg / nexus
trig_eeg = 8;
trig_controle = 9;
trig_incertain = 10;
trig_go = 11;
trig_nogo = 12;

%% configuration du labjack U6
ljasm = NET.addAssembly('LJUDDotNet'); %Make the UD .NET assembly visible in MATLAB
ljudObj = LabJack.LabJackUD.LJUD;

%Open the first found LabJack U6.
[ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.U6, LabJack.LabJackUD.CONNECTION.USB, '0', true, 0);

% set FIO2 to low
ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 2, 0, 0, 0);
ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 8, 0, 0, 0);
ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 9, 0, 0, 0);
ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 10, 0, 0, 0);
ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 11, 0, 0, 0);
ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 12, 0, 0, 0);
ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 13, 0, 0, 0);
ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 14, 0, 0, 0);
ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 15, 0, 0, 0);
ljudObj.GoOne(ljhandle)

%% Structure de sortie
Resultats.Data = {};
Resultats.Infos = [];
Resultats.Data(1,:) = {'Trial Tag','Start Time','Inter Trial Delay','Fix Time','Pre Stim Delay','Stim Time','Stim','Sortie'};

% Infos sur le sujet
Tag_items = {'Protocole','Session_Med','Code_Patient'};
items = {'GOGAIT','test','test'}; %
% items{1,1} = 'PROTOCOL_GNG';
% items{2,1} = 'SESS_MED';
% items{3,1} = 'PATXX';
items = inputdlg(Tag_items,'Infos',1,items);

if ~isempty(items)
    nom_fich = [items{1} '_' items{2} '_' items{3}];
    Resultats.Infos.Protocole = items{1};
    Resultats.Infos.Session = items{2};
    Resultats.Infos.Subject = items{3};
    Resultats.Infos.FileName = nom_fich;
end
if exist([nom_fich '.xlsx'],'file')==2
    test = 0;
    while test == 0
        test_xls = questdlg({'Attention un fichier Xcel du même nom existe déjà','Voulez-vous l''écraser ?'},'Warning','Oui','Non','Non');
        switch test_xls
            case 'Non'
                items = {'GBMOV_GNG','Marche','XXXXx00'};
                items = inputdlg(Tag_items,'Infos',1,items);
                if ~isempty(items)
                    nom_fich = [items{1} '_' items{2} '_' items{3}];
                    Resultats.Infos.Protocole = items{1};
                    Resultats.Infos.Session = items{2};
                    Resultats.Infos.Subject = items{3};
                    Resultats.Infos.FileName = nom_fich;
                end
                test = 1;
            case 'Oui'
                delete([nom_fich '.*'])
                test = 1;
        end
    end
end

% Chargement du fichier input des tirages GNG
GNG_input = uigetfile('*.mat','Sélectionner les essais Go-NoGo');
% GNG_input = 'test_input.mat'
load(GNG_input);

%% initialisation de psyctoolbox
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
% screenNumber = max(screens);
screenNumber = 2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0);
disp('ok');

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% on charge les images dans la memoire
theImageLocation = [chemin filesep 'Pt_Fix_green.png'];
Pt_Fix_green = imread(theImageLocation);
% Make the image into a texture
Pt_Fix_green_IT = Screen('MakeTexture', window, Pt_Fix_green);

theImageLocation = [chemin filesep 'Pt_Fix_red.png'];
Pt_Fix_red = imread(theImageLocation);
% Make the image into a texture
Pt_Fix_red_IT = Screen('MakeTexture', window, Pt_Fix_red);

theImageLocation = [chemin filesep 'GO_circle.png'];
GO_circle = imread(theImageLocation);
% Make the image into a texture
GO_circle_IT = Screen('MakeTexture', window, GO_circle);

theImageLocation = [chemin filesep 'NOGO_cross.png'];
NOGO_cross = imread(theImageLocation);
% Make the image into a texture
NOGO_cross_IT = Screen('MakeTexture', window, NOGO_cross);

% idnetification de la
BeginKey = KbName('RightArrow');
PauseKey = KbName('0');
QuitKey = KbName('ESCAPE');

ControlBlockKey = KbName('7');
UncertainBlockKey = KbName('8');
RecordKey = KbName('1');

%% Début de la session
% initialisation compteur
cpt = 1;
cpt_ctrl=0;
cpt_gng=0;
exit = 0;

while exit~=1

% choix de la session
disp('block controle = 7 / Block incertain = 8 / Sortie & Enregistrement = 1')
disp('choisir un block')

[secs, keyCode, deltaSecs] = KbWait;

while (keyCode(ControlBlockKey) ~=1 && keyCode(UncertainBlockKey) ~=1 && keyCode(RecordKey) ~=1)
    disp('block controle = 7 / Block incertain = 8 / Sortie & Enregistrement = 1')
    disp('choisir un block')
    [secs, keyCode, deltaSecs] = KbWait;
end

if keyCode(ControlBlockKey)
    Block = 'Controle';
    disp('Block Contrôle ========  Appuyer sur la flèche de droite pour lancer chaque essai')
elseif keyCode(UncertainBlockKey)
    Block = 'Go-NoGo';
    disp('Block Go incertain ========  Appuyer sur la flèche de droite pour lancer chaque essai')
elseif keyCode(RecordKey)
    Block = 'Sortie';
    disp('Block Sortie & Enregistrement ========  Appuyer sur la flèche de droite pour lancer chaque essai')

else
    [secs, keyCode, deltaSecs] = KbWait;
end

    
switch Block
        case 'Controle'
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% série
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% d'essais
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Controles
            
            % tirage des délais pré-stim
            temp = [repmat([1,2,3],1,3),randperm(3)];
            ind_delay = temp(1:10);
            clear temp
             ind_delay = 500 + 500*ind_delay(randperm(length(ind_delay)));
            i=0;
            while i < 10           
                
                %Appui sur la touche espace pour lancer l'essai
                [secs, keyCode, deltaSecs] = KbWait;
                
                if keyCode(BeginKey)
%                      if 1
                    i=i+1;
                    cpt_ctrl=cpt_ctrl+1;
                    
                    % lancement du key listener
                    KbQueueCreate()
                    KbQueueStart()
                    % ecriture dans le log file
                    str=sprintf('%s','===================================================================');
                    disp(str);
                    str=sprintf('%s',['Go_Control_' num2str(cpt)]);
                    disp(str)
                    % incrémentation du compteur0
                    cpt = cpt+1;
                    pause = 0;
                    
                    % black screen
                    Screen('FillRect', window, [0 0 0]);
                    tag_stim = 'Go_Control';
                    t_0 = Screen('Flip', window)*1000;
                    % t_0 = GetSecs*1000;
                    % Screen('Flip', window);
                    
%                     envoi du trigger sur le labjack
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 2, 1, 0, 0);
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 1, 0, 0);
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_eeg, 1, 0, 0); 
                    ljudObj.GoOne(ljhandle);                     
                    tic
                    while toc < 0.2
                        ;
                    end
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 2, 0, 0, 0);
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 0, 0, 0);                
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_eeg, 0, 0, 0);
                    ljudObj.GoOne(ljhandle);
%                     
                    % delay interessai
                    WaitSecs('UntilTime', (t_0 - 1 + (800 + 400*rand(1)))*1e-3);
%                     WaitSecs('UntilTime', (t_0 - 1 + (800 + 400))*1e-3);

                    
                    % affichage fix
                    Screen('DrawTexture', window, Pt_Fix_green_IT, [], [], 0);
                   % t_fix = GetSecs*1000;
                    % Flip to the screen
                    %Screen('Flip', window);
                    t_fix = Screen('Flip', window)*1000;
                    
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_controle, 1, 0, 0); 
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 1, 0, 0);
                    ljudObj.GoOne(ljhandle);
                    tic
                    while toc < 0.2
                        ;
                    end
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_controle, 0, 0, 0);
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 0, 0, 0);
                    ljudObj.GoOne(ljhandle);
                    
                    % calcul delay inter-essai
                    d_fix = t_fix - t_0;
                    
                    % delay pre-stim
                    WaitSecs('UntilTime', (t_fix + ind_delay(i))*1e-3);
                    % affichage stim
                    Screen('DrawTexture', window, GO_circle_IT, [], [], 0);
                    %t_stim = GetSecs*1000;
                    % Flip to the screen
                    %Screen('Flip', window);
                    
                    t_stim = Screen('Flip', window)*1000;
                    
                    % envoi du trigger
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_go, 1, 0, 0);
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 1, 0, 0);
                    ljudObj.GoOne(ljhandle);
                    tic
                    while toc < 0.2
                        ;
                    end
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_go, 0, 0, 0);
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 0, 0, 0);
                    ljudObj.GoOne(ljhandle);                    
                    
                    % calcul dealy pre-stim
                    d_stim = t_stim - t_fix;
                    
                    % fond noir après 100ms
                    WaitSecs('UntilTime', (t_stim + 100)*1e-3);
                    % black screen
                    Screen('FillRect', window, [0 0 0]);
                    Screen('Flip', window);
                    
                    WaitSecs('UntilTime', (t_stim + 1600)*1e-3);
                    
                    % lecture des evenements keybord (la barre d'espace spécifiquement)
                    KbQueueStop()
                    [pressed, firstPress, firstRelease, lastPress, lastRelease]=KbQueueCheck();
                    
                    % Sortie si Echap pressée
                    quit = 0;
                    if firstPress(QuitKey)~=0
                        quit = firstPress(QuitKey)*1000;
                        % ecriture dans le log file
                        str=sprintf('%s',['Quit : ' firstPress(QuitKey)*1000]);
                        disp(str);
                         Resultats.Data(cpt,:) = {['Trial' num2str(cpt-1)],t_0,d_fix,t_fix,d_stim,t_stim,tag_stim,quit};
                        
                         break;
                    end
                    
                    % stockage des resultats
                    Resultats.Data(cpt,:) = {['Trial' num2str(cpt-1)],t_0,d_fix,t_fix,d_stim,t_stim,tag_stim,quit};
                end
            end
            %% sauvegarde resultats
            xlswrite([nom_fich '.xlsx'],Resultats.Data,1,'A1')
            save(nom_fich,'Resultats')
            %% Passage à un nouveau block
            disp('block controle = 7 / Block incertain = 8 / Sortie & Enregistrement = 1')
            disp('fin du block Go contrôle  ========  choisir un nouveau block')
            [secs, keyCode, deltaSecs] = KbWait;

            while (keyCode(ControlBlockKey) ~=1 && keyCode(UncertainBlockKey) ~=1 && keyCode(RecordKey) ~=1)
                disp('block controle = 7 / Block incertain = 8 / Sortie & Enregistrement = 1')
                disp('choisir un block')
                [secs, keyCode, deltaSecs] = KbWait;
            end

            if keyCode(ControlBlockKey)
                Block = 'Controle';
                disp('Block Contrôle ========  Appuyer sur la flèche de droite pour lancer chaque essai')
            elseif keyCode(UncertainBlockKey)
                Block = 'Go-NoGo';
                disp('Block Go incertain ========  Appuyer sur la flèche de droite pour lancer chaque essai')
            elseif keyCode(RecordKey)
                Block = 'Sortie';
                disp('Block Sortie & Enregistrement ========  Appuyer sur la flèche de droite pour lancer chaque essai')

            else
                [secs, keyCode, deltaSecs] = KbWait;
            end

            
        case 'Go-NoGo'
            %% 2° série (40 mixte go-NoGo)
                % tirage des délais pré-stim
            temp = [repmat([1,2,3],1,13),randperm(3)];
            ind_delay = temp(1:40);
            clear temp
            ind_delay = 500 + 500*ind_delay(randperm(length(ind_delay)));
            i=0;
            while i < 40
                
                %Appui sur la touche espace pour lancer l'essai
                [secs, keyCode, deltaSecs] = KbWait;
                if keyCode(BeginKey)
                    i=i+1;
                    cpt_gng=cpt_gng+1;
                                
                % lancement du key listener
                KbQueueCreate()
                KbQueueStart()
                
                % ecriture dans le log file
                str=sprintf('%s','===================================================================');
                disp(str);
                str=sprintf('%s',['Go_NoGo_' num2str(cpt)]);
                disp(str);
                
                % incrémentation du compteur
                cpt = cpt+1;
                pause = 0;

                % affichage fond noir
                Screen('FillRect', window, [0 0 0]);
%                 t_0 = GetSecs*1000;
%                 Screen('Flip', window);
                t_0 = Screen('Flip', window)*1000;
                
%                 envoi du trigger sur le labjack
                ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 2, 1, 0, 0);
                ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 1, 0, 0);
                ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_eeg, 1, 0, 0);
                ljudObj.GoOne(ljhandle);
                tic
                while toc < 0.2
                    ;
                end
                ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 2, 0, 0, 0);
                ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 0, 0, 0);
                ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_eeg, 0, 0, 0);
                ljudObj.GoOne(ljhandle);
                
                % delay interessai
                WaitSecs('UntilTime', (t_0 - 1 + (800 + 400*rand(1)))*1e-3);
                
                % affichage fix
                Screen('DrawTexture', window, Pt_Fix_red_IT, [], [], 0);
                t_fix = Screen('Flip', window)*1000;
                
                ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_incertain, 1, 0, 0);
                ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 1, 0, 0);
                ljudObj.GoOne(ljhandle);
                tic
                while toc < 0.2
                    ;
                end
                ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_incertain, 0, 0, 0);
                ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 0, 0, 0);
                ljudObj.GoOne(ljhandle);                
                
                % Flip to the screen
%                 Screen('Flip', window);
                % calcul delay inter-essai
                d_fix = t_fix - t_0;

                % delay pre-stim
                WaitSecs('UntilTime', (t_fix + ind_delay(i))*1e-3);
                % affichage stim
                if isgo(i)
                    % affichage stim
                    Screen('DrawTexture', window, GO_circle_IT, [], [], 0);
                    t_stim = Screen('Flip', window)*1000;
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_go, 1, 0, 0);
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 1, 0, 0);
                    ljudObj.GoOne(ljhandle);
                    tic
                    while toc < 0.2
                        ;
                    end
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_go, 0, 0, 0);
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 0, 0, 0);
                    ljudObj.GoOne(ljhandle);
                    % Flip to the screen
                    %                     Screen('Flip', window);
                    tag_stim = 'Go';
                else
                    % affichage stim
                    Screen('DrawTexture', window, NOGO_cross_IT, [], [], 0);
                    t_stim = Screen('Flip', window)*1000;
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_nogo, 1, 0, 0);
                    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 1, 0, 0);
                    ljudObj.GoOne(ljhandle);
                    tic
                    while toc < 0.2
                    ;
                end
                ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, trig_nogo, 0, 0, 0);
                ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 0, 0, 0, 0);
                ljudObj.GoOne(ljhandle);                    
                   % Flip to the screen
%                     Screen('Flip', window);
                    tag_stim = 'NoGo';
                end
                % calcul dealy pre-stim
                d_stim = t_stim - t_fix;

                % fond noir après 100ms
                WaitSecs('UntilTime', (t_stim + 100)*1e-3);
                % black screen
                Screen('FillRect', window, [0 0 0]);
                Screen('Flip', window);
                disp(tag_stim)
                
                WaitSecs('UntilTime', (t_stim + 1600)*1e-3);
                % lecture des evenements keybord
                KbQueueStop()
                [pressed, firstPress, firstRelease, lastPress, lastRelease]=KbQueueCheck();
                
                end

%                 % Pause si touche Pad0 pressée
%                 if (PauseKey)~=0
%                     pause = firstPress(PauseKey)*1000;
%                     % ecriture dans le log file
%                     str=sprintf('%s',['Pause : ' firstPress(PauseKey)*1000]);
%                     disp(str);
%                     while (1)
%                         % Get last key press
%                         [secs, keyCode, deltaSecs] = KbWait;
%                         % Exit if specified key has been pressed
%                         if keyCode(PauseKey)
%                             break;
%                         end
%                     end
%                 end
                % Sortie si Echap pressée
                quit = 0;
                if firstPress(QuitKey)~=0
                    quit = firstPress(QuitKey)*1000;
                    % ecriture dans le log file
                    str=sprintf('%s',['Quit : ' firstPress(QuitKey)*1000]);
                    disp(str);
                    Resultats.Data(cpt,:) = {['Trial' num2str(cpt-1)],t_0,d_fix,t_fix,d_stim,t_stim,tag_stim,quit};
                    break;
                end

                % stockage des resultats
                Resultats.Data(cpt,:) = {['Trial' num2str(cpt-1)],t_0,d_fix,t_fix,d_stim,t_stim,tag_stim,quit};
                
            end
            %% sauvegarde resultats
            xlswrite([nom_fich '.xlsx'],Resultats.Data,1,'A1')
            save(nom_fich,'Resultats')
            
            %% Passage à un nouveau block
            disp('block controle = 7 / Block incertain = 8 / Sortie & Enregistrement = 1')
            disp('Fin du Block Go-NoGo  ========  Choisir un nouveau block')

            [secs, keyCode, deltaSecs] = KbWait;

            while (keyCode(ControlBlockKey) ~=1 && keyCode(UncertainBlockKey) ~=1 && keyCode(RecordKey) ~=1)
                disp('block controle = 7 / Block incertain = 8 / Sortie & Enregistrement = 1')
                disp('choisir un block')
                [secs, keyCode, deltaSecs] = KbWait;
            end

            if keyCode(ControlBlockKey)
                Block = 'Controle';
                disp('Block Contrôle ========  Appuyer sur la flèche de droite pour lancer chaque essai')
            elseif keyCode(UncertainBlockKey)
                Block = 'Go-NoGo';
                disp('Block Go incertain ========  Appuyer sur la flèche de droite pour lancer chaque essai')
            elseif keyCode(RecordKey)
                Block = 'Sortie';
                disp('Block Sortie & Enregistrement ========  Appuyer sur la flèche de droite pour lancer chaque essai')

            else
                [secs, keyCode, deltaSecs] = KbWait;
            end

        case 'Sortie'
            disp('enregistrement & sortie');
            exit = input('Taper 1 pour quitter:  ');
    end
    %% sauvegarde resultats
    xlswrite([nom_fich '.xlsx'],Resultats.Data,1,'A1')
    save(nom_fich,'Resultats')
end

% Clear the screen
sca;
