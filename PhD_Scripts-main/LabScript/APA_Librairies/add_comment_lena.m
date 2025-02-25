function [comments color] = add_comment_lena(Evt)
% function [comments color] = add_comment_lena(Evt)
%% Fonction interne pour export lena (ajout des explications des evts)
switch Evt
    case {'GD' 'GG' 'GO' 'TR'}
        comments = 'GO Sonore - Depart pied Droit/Gauche';
        color = '#000000';
    case 'TA'
        comments = 'Inhibition muscles TA';
        color = '#000001';
    case 'T0'
        comments = 'Debut du mouvement';
        color = '#000010';
    case 'HO'
        comments = 'Decollement Talon - Pied oscillant';
        color = '#000011';
    case 'TO'
        comments = 'Decollement Orteil - Pied oscillant';
        color = '#000100';
    case 'FC1'
        comments = 'Pose du talon - Pied oscillant';
        color = '#000101';
    case 'FO2'
        comments = 'Decollement Orteil - Pied appui';
        color = '#001000';
    case 'FC2'
        comments = 'Fin cycle initiation (Pose du talon)';
        color = '#000101';
    case 'FOG'
        comments = 'Freezing Of Gait';
        color = '#010000';
    case 'DT'
        comments = 'Demi-Tour';
        color = '#100000';
    otherwise
        comments = Evt;
        color = '#100001';
end