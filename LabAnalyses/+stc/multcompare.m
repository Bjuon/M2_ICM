function multcomp(array)
    %filenames = {'patient_name','pathology','burst_rate','burst_index','firing_rate','cv2','%spk'};
    %burst
    %filenames = {'patient_name','pathology','cv','lvr','cv2','lv'};
    %regularity
    filenames = {'patient_name','pathology','num_pause','pause_dur','pause_rate'};
    %pause
    
    for i = 3:size(array,2)
        x = array(:,i);
        x = [x{:}]';
        [p,t,st] = anova1(x,array(:,2));
        multcompare(st);
        name = filenames{i}
        saveas(gcf,[name '.fig']);
    end
end
