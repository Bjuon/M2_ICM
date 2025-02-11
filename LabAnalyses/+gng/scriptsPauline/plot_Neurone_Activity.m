version= 2;
if version ==1
    fin_name= 'name';
else
    fin_name= 'eventVal';
end

nameEvent= 'Cue';

%load('out.mat');
load('proces.mat');

for neur=1:size(out,2)
    out= out{1,neur};
    for e=1:size(out,2)
        evt(e)= out(e).eventProcess.find(fin_name, nameEvent);
    end
    tStart_evt= [evt.tStart];
    tStart_min= min(tStart_evt);
    tStart_max= min(tStart_evt);
    window= [out(e).eventProcess.tStart-tStart_max out(e).eventProcess.tEnd-tStart_min];
    spikes_sync = sync([out.pointProcess], tStart_evt, 'window',window);
    
    %h= figure('name',sprintf('neurone = %d', neur))
    plot(spikes_sync);
    hold on;
    plot(zeros(2,1) , [1 size(out,2)],'k','Linewidth',1);
    hold off;
end