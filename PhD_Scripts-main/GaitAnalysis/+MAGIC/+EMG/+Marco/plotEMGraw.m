function plotEMGraw(rawEMG, trialname, MinTP, MaxTP, center)

emg_labels = fieldnames(rawEMG);

fig = figure('units','normalized','outerposition',[.1 .1 .8 .8]) ;
sgtitle(['Raw EMG data', trialname])
for n = 1:numel(fieldnames(rawEMG))
    subplot(3, 2, n)
    plot(rawEMG.(emg_labels{n})(MinTP:MaxTP,:),'k') 
    hold on
    plot([center-MinTP center-MinTP],[-1 1],'b')
    title(emg_labels{n})
    ylim([-1 1])
    xlim([0 length(rawEMG.(emg_labels{n})(MinTP:MaxTP,:))])
    xticks([0 length(rawEMG.(emg_labels{n})(MinTP:MaxTP,:))])
    xticklabels({'MinTP', 'MaxTP'})
end

opts.WindowStyle = 'normal' ;
opts.Interpreter = 'tex';
opts.Resize = 'on';
deplace_bouton = 0 ;
size_bouton = 3 ;

prompt = uibuttongroup('Visible','off','Position',[0 0 1 .03*mean([1 ,size_bouton])]);              
% Create three radio buttons in the button group.
r1 = uicontrol(prompt,'Style', 'pushbutton','String','Accept', 'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [200 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@Accept }      ,'BackgroundColor',[0.7   1 0.7]);
r2 = uicontrol(prompt,'Style', 'pushbutton','String','Discard','FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [300 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@Discard }     ,'BackgroundColor',[  1 0.7 0.7]);
r3 = uicontrol(prompt,'Style', 'pushbutton','String','Exit',   'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [500 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@StopFunction});
% Make the uibuttongroup visible after creating child objects. 
prompt.Visible = 'on';
                
uiwait(fig)
                

end

function Accept(~,~)
    assignin('base','Included','Yes')
    close all
end

function Discard(~,~)
    assignin('base','Included','No')
    close all
end

function StopFunction(~,~)
    fprintf(2, 'Manual Stop......... \n')
    close all
end
