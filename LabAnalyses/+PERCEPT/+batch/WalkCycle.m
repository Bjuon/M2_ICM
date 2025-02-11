
filename = 'C:\Users\mathieu.yeche\Desktop\PERCEPT\P05\LFP\Report_Json_Session_Report_20231213T122659.json'   ;
Visual_inspection = true ;
recording = 0 ;
deltaTemporel_t0LFPentempsVICON = 24.37 ;

[lfp,Peaks, CondStim] = PERCEPT.load.read_json(filename, recording, Visual_inspection) ;


h = btkReadAcquisition('C:\Users\mathieu.yeche\Desktop\PERCEPT\P05\Pilote\11_12_2023\Pilote_PERCEPT_Test_OFF_Catwalk_02.c3d') ;
Ev = btkGetEvents(h) ;

% Identify gait cycle events
FSmerged = sort([Ev.Right_Foot_Strike, Ev.Left_Foot_Strike]) ;
FOmerged = sort([Ev.Right_Foot_Off, Ev.Left_Foot_Off]) ;

% If time from the n event to the n+1 event is more than 1.5s, 
Step_list = {} ;
for i = 1:length(FSmerged)-1
    if FSmerged(i+1) - FOmerged(i) < 1.8 && FSmerged(i+1) - FOmerged(i) > 0.1
        Step_list{size(Step_list,1)+1,1} = FOmerged(i)   ;     %#ok<SAGROW> 
        Step_list{size(Step_list,1)  ,2} = FSmerged(i)   ;
        Step_list{size(Step_list,1)  ,3} = FOmerged(i+1) ;
        Step_list{size(Step_list,1)  ,4} = FSmerged(i+1) ;
    end
end

fprintf(2, "todo \n")
%  Step_list{:,5} = selon le timing passerelle ou toit
%  puis calcul temps passerelle / toit moyenne glissante sur 10 essais
%  puis calcul distance en prenant la moyenne de tous les pts

% Chop LFP arround gait cycle events


%%% Simple event based analysis
lfp_spec  = tfr(lfp,'method','chronux','tBlock',0.5,'tStep',0.03,'f',[1 100],'tapers',[2 3],'pad',1);
tf_values = mean(lfp_spec.values{1,1}, 3) ;
Time_stamp = lfp_spec.times{1} - 0.5/2 + deltaTemporel_t0LFPentempsVICON ;
Fs = lfp_spec.Fs ;

t_max = 70 ;

MeanTF_forFO = {} ;
for freq = 1:101
    for time = 0:t_max
        temp_tf = [] ;
        for i = 1:length(FOmerged)
            event = round(FOmerged(i)*Fs + t_max/2) ;
            temp_tf = [temp_tf, tf_values(event-t_max+time, freq )] ;
        end
        MeanTF_forFO{freq,time+1} = median(temp_tf) ;
    end
end


MeanTF_forFS = {} ;
for freq = 1:101
    for time = 0:t_max
        temp_tf = [] ;
        for i = 1:length(FSmerged)
            event = round(FSmerged(i)*Fs + t_max/2) ;
            temp_tf = [temp_tf, tf_values(event-t_max+time, freq )] ;
        end
        MeanTF_forFS{freq,time+1} = median(temp_tf) ;
    end
end

% Plots
t_axis = -t_max/2/Fs:1/Fs:t_max/2/Fs  ;
figure() ;
g = subplot(1,2,1) ;
surf(t_axis, lfp_spec.f, cell2mat(MeanTF_forFO), 'edgecolor', 'none', 'Parent', g);
view(g,0,90); hold on
colormap('jet')
title('Foot Off')
xlabel('Time (s)')
ylabel('Frequency (Hz)')
plot3([0 0], ylim, [max(max(cell2mat(MeanTF_forFO))) max(max(cell2mat(MeanTF_forFO)))],  'k')

g = subplot(1,2,2) ;
surf(t_axis, lfp_spec.f, cell2mat(MeanTF_forFS), 'edgecolor', 'none', 'Parent', g);
view(g,0,90); hold on
colormap('jet')
colorbar
title('Foot Strike')
xlabel('Time (s)')
ylabel('Frequency (Hz)')
plot3([0 0], ylim, [max(max(cell2mat(MeanTF_forFS))) max(max(cell2mat(MeanTF_forFS)))],  'k')

close all
