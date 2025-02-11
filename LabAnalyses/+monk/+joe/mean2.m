
files = {...
   'Q_160415_DelMov.mat',...
};
align = 'Reaction';
win = [-3 3];

t0r0 = [];
t0r1 = [];
t1r1 = [];
t1r0 = [];
for i = 1:numel(files)
   load(files{i});

   align = 'Reaction';
   win = [-4 4];
   out = monk.joe.getPsth(data,align,win);
   t0r0 = [t0r0 , out.t0r0.values];
   t0r1 = [t0r1 , out.t0r1.values];
   t1r1 = [t1r1 , out.t1r1.values];
   t1r0 = [t1r0 , out.t1r0.values];
   
end
t = out.t0r0.times;

% figure;

c = parula(5);

h = subplot(222); hold on

plot(t,mean(t0r0,2),'Color',c(1,:))
plot(t,mean(t1r1,2),'Color',c(2,:))
plot(t,mean(t0r1,2),'Color',c(3,:))
plot(t,mean(t1r0,2),'Color',c(4,:))
axis tight
legend({'T0R0' 'T1R1' 'T0R1' 'T1R0'})
axis([-3 3 0 25])

% t0r0 = [];