monkey = 'Chanel';
task = '1DR';
mintrials = 100;
dateStart = '01/04/2017';
list = monk.sessionList(monkey,task,dateStart,[],mintrials);

pre = 5; % # of trials before block transition
post = 10; % # of trials after block transition

m_01_0 = []; % BlockBlock_Target
m_01_1 = [];
m_10_0 = [];
m_10_1 = [];
for i = 1:numel(list)
   [hdr,data] = monk.load.loadEventIDE(list{i});
   
   [t_01_0,t_01_1,t_10_0,t_10_1] = transitionMat(data,'RT',pre,post);
   m_01_0 = [m_01_0 , t_01_0];
   m_01_1 = [m_01_1 , t_01_1];
   m_10_0 = [m_10_0 , t_10_0];
   m_10_1 = [m_10_1 , t_10_1];
end

figure;
ind = [-pre:-1 1:post];

subplot(121);
hold on;
g = plot(ind,nanmedian(m_01_0,2));
plot(ind,nanmedian(m_01_0,2),'o','MarkerEdgeColor',g.Color,'MarkerFaceColor',g.Color);
g = plot(ind,nanmedian(m_01_1,2));
plot(ind,nanmedian(m_01_1,2),'o','MarkerEdgeColor',g.Color,'MarkerFaceColor',g.Color);
plot([0 0],get(gca,'ylim'),'--');

subplot(122);
hold on;
g = plot(ind,nanmedian(m_10_0,2));
plot(ind,nanmedian(m_10_0,2),'o','MarkerEdgeColor',g.Color,'MarkerFaceColor',g.Color);
g = plot(ind,nanmedian(m_10_1,2));
plot(ind,nanmedian(m_10_1,2),'o','MarkerEdgeColor',g.Color,'MarkerFaceColor',g.Color);
plot([0 0],get(gca,'ylim'),'--');
