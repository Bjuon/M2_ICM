
if ~exist("sentences")
       sentences = cell(10,1) ;
end

% Faire ctrl + Maj + V dans sentences


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Initialisation de la sortie
output_data = {};

for i=1:length(sentences)
    % Rechercher les phrases qui commencent par 'i_loop :'
    if endsWith(sentences{i}, '%')
        % Extraire le numéro de boucle
        ev_art = str2double(extractAfter(extractBefore(sentences{i},' |'),': '));
        loop_num = str2double(extractAfter(extractBefore(sentences{i},' |'),': '));
        loop_num = str2double(extractAfter(extractBefore(sentences{i},' |'),': '));
        
%         % Extraire l'ID

%         id = extractBefore(extractAfter(sentences{i}, '| '), '-');
%         
%         % Extraire l'événement
%         event = extractAfter(sentences{i}, '-');
%         
%         % Initialiser le statut
%         status = 'Pending';
%         
%         % Rechercher la phrase qui contient 'End of patient :'
%         for j=1:length(sentences)
%             if startsWith(sentences{j}, 'End of patient')
%                 % Extraire l'ID de cette phrase
%                 id_verification = extractBefore(extractAfter(sentences{j},': '), ' (');
%                 if strcmp(id, id_verification)
%                     %Extraire l'evenement de cette phrase
%                     event_verification = extractBefore(extractAfter(sentences{j},'('), ')');
%                     if strcmp(event, event_verification)
%                         status = 'End';
%                         break;
%                     end
%                 end
%             end
%             if contains(sentences{j}, 'ECHEC de ')
%                 % Extraire l'ID de cette phrase
%                 id_verification = extractBefore(extractAfter(sentences{j},': '), '-');
%                 if strcmp(id, id_verification)
%                     %Extraire l'evenement de cette phrase
%                     event_verification = extractAfter(sentences{j},'-');
%                     if strcmp(event, event_verification)
%                         status = 'ECHEC';
%                         break;
%                     end
%                 end
%             end
%         end
%         
%         % Ajouter les données extraites à la sortie
%         output_data = [output_data; {loop_num, id, event, status}];
%     end
% end
% output_data = sortrows(output_data,1);
% output_data = sortrows(output_data,4);
% already_ended = cell2mat(output_data(strcmp(output_data(:,4),'End')));
% 
% 
% output_data ;