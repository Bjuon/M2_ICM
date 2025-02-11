function PeakVisualisation(patON,LeftRightON, pat, AroundBPeak,  IdChB, FreqB, PtFq, AroundGPeak,  IdChG, FreqG, VisualInspectionPeak)
    %PEAKVISUALISATION Summary of this function goes here
    %   Detailed explanation goes here
    figure('Name',['Pat ' patON{pat} ' Side ' num2str(LeftRightON(pat))], 'Position', [5 50 1900 1050])
    hold on
    subplot(2,1,1)
    plot(AroundBPeak(pat, :) , 'color','#ff0000')
    xline(3/PtFq+1, 'color','#000000')
    text(5, 0.8*AroundBPeak(pat, 3/PtFq+1), [ num2str(IdChB) ' ' num2str(FreqB)], 'color','#000000', 'FontSize', 20)
    ylim([0 1.1 * max(AroundBPeak(pat, :))])

    subplot(2,1,2)
    plot(AroundGPeak(pat, :) , 'color','#0000ff')
    xline(9/PtFq+1, 'color','#000000')
    text(5, 0.8*AroundGPeak(pat, 9/PtFq+1), [ num2str(IdChG) ' ' num2str(FreqG)], 'color','#000000', 'FontSize', 20)
    ylim([0 1.1 * max(AroundGPeak(pat, :))])
    % See FOGfin for more details
            opts.WindowStyle = 'normal' ;
            opts.Interpreter = 'tex';
            opts.Resize = 'on';
            deplace_bouton = 0 ;
            size_bouton = 1 ;

            prompt = uibuttongroup('Visible','off','Position',[0 0 1 .03*mean([1 ,size_bouton])]);              
            r1 = uicontrol(prompt,'Style', 'pushbutton','String','βbad γok', 'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [200 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@Cas1, VisualInspectionPeak, pat});
            r2 = uicontrol(prompt,'Style', 'pushbutton','String','βok  γok',   'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [300 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@Cas2, VisualInspectionPeak, pat});
            r3 = uicontrol(prompt,'Style', 'pushbutton','String','βok  γbad',      'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [400 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@Cas3 , VisualInspectionPeak, pat});
            r4 = uicontrol(prompt,'Style', 'pushbutton','String','βbad γbad',   'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [500 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@Cas4 , VisualInspectionPeak, pat});
            prompt.Visible = 'on';  
end

function Cas1(~,~, VisualInspectionPeak, pat)
    VisualInspectionPeak = evalin('base', 'VisualInspectionPeak');
    VisualInspectionPeak(pat,1) = pat ; % Id
    VisualInspectionPeak(pat,2) = 0 ; % Beta
    VisualInspectionPeak(pat,3) = 1 ; % Gamma
    assignin('base','VisualInspectionPeak',VisualInspectionPeak)
    close(gcf)
end
function Cas2(~,~, VisualInspectionPeak, pat)
    VisualInspectionPeak = evalin('base', 'VisualInspectionPeak');
    VisualInspectionPeak(pat,1) = pat ; % Id
    VisualInspectionPeak(pat,2) = 1 ; % Beta
    VisualInspectionPeak(pat,3) = 1 ; % Gamma
    assignin('base','VisualInspectionPeak',VisualInspectionPeak)
    close(gcf)
end
function Cas3(~,~, VisualInspectionPeak, pat)
    VisualInspectionPeak = evalin('base', 'VisualInspectionPeak');
    VisualInspectionPeak(pat,1) = pat ; % Id
    VisualInspectionPeak(pat,2) = 1 ; % Beta
    VisualInspectionPeak(pat,3) = 0 ; % Gamma
    assignin('base','VisualInspectionPeak',VisualInspectionPeak)
    close(gcf)
end
function Cas4(~,~, VisualInspectionPeak, pat)
    VisualInspectionPeak = evalin('base', 'VisualInspectionPeak');
    VisualInspectionPeak(pat,1) = pat ; % Id
    VisualInspectionPeak(pat,2) = 0 ; % Beta
    VisualInspectionPeak(pat,3) = 0 ; % Gamma
    assignin('base','VisualInspectionPeak',VisualInspectionPeak)
    close(gcf)
end
