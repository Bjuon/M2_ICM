%create array with stc.array_all first 

function patho_box(array)

factors = {'br','bi','fr','ps','np','pd','pr','cv','lvr','cv2','lv'};
patho = categorical(array(2:end,2));

for i = 1:length(factors)

    factor = array(2:end,(i+3));
    factor = [factor{:}]';
    
    boxplot(factor,patho)
    
    saveas(gcf,[char(factors(i)) '_patho_box.jpeg']);
end

end
