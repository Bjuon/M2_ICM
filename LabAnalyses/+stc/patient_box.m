%create array with stc.array_all first 

function patient_box(array)

factors = {'br','bi','fr','ps','np','pd','pr','cv','lvr','cv2','lv'};

for i = 1:length(factors)

    patient = categorical(array(2:end,1));

    factor = array(2:end,(i+3));
    factor = [factor{:}]';
    
    boxplot(factor,patient)
    set(gca,'FontSize',10,'XTickLabelRotation',90)
    saveas(gcf,[char(factors(i)) '_patient_box.jpeg']);
end

end
