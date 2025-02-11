clear SCORES scores;

cd('/Users/brian.lau/CloudStation/Work/Production/Papers/2015_STN10Year/Data');
dat = ten.load.data();

q = linq();
%%
temp = [dat.sex]=='H';
temp1 = toArray(q(dat).where(@(x) x.pattern(end)=='1').select(@(x) x.sex))=='H';
temp2 = toArray(q(dat).where(@(x) x.deceased).select(@(x) x.sex))=='H';
[~,p] = stat.compProp2([sum(temp1) sum(temp2) ; sum(~temp1) sum(~temp2)]);

SCORES{1,1} = temp;
SCORES{1,2} = temp1;
SCORES{1,3} = temp2;
SCORES{1,4} = p;
SCORES{1,5} = 'sex ratio';
%fprintf('%s\t\t%1.2f\t%1.2f\t%1.2f\t%1.3f\n','sex ratio',nanmean(temp),nanmean(temp1),nanmean(temp2),p);

%%
vars = {'ageDebut' 'ageAtIntervention' 'dureeEvolution2'};

for i = 1:numel(vars)
   temp = [dat.(vars{i})];
   temp1 = q(dat).where(@(x) x.pattern(end)=='1').select(@(x) x.(vars{i})).toArray;
   temp2 = q(dat).where(@(x) x.deceased).select(@(x) x.(vars{i})).toArray;
   p = ranksum(temp1,temp2);
   %fprintf('%s\t\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.3f\n',vars{i},nanmean(temp),nanstd(temp),nanmean(temp1),nanstd(temp1),nanmean(temp2),nanstd(temp2),p);
   
   scores{1,1} = temp;
   scores{1,2} = temp1;
   scores{1,3} = temp2;
   scores{1,4} = p;
   scores{1,5} = vars{i};
   SCORES = cat(1,SCORES,scores);
end

%%
vars = {'dementia' 'hallucinations' 'updrsIIOff' 'updrsIIOn' 'swallowingOff' 'swallowingOn' 'fallsOff' 'fallsOn'...
        'updrsIIIOffSOffM' 'updrsIIIOffSOnM' 'akinesiaOffSOffM' 'akinesiaOffSOnM' 'rigidityOffSOffM' 'rigidityOffSOnM' 'tremorOffSOffM' 'tremorOffSOnM'...
        'axeOffSOffM' 'axeOffSOnM' 'updrsIV' 'OFF' 'DSK' 'HYOff' 'HYOn' 'SEOff' 'SEOn' ...
        'Mattis' 'frontal50' 'ldopaEquiv' 'agonists'};
vis = 1;

for i = 1:numel(vars)
   temp = q(dat).select(@(x) x.visit(vis).(vars{i})).toArray;
   temp1 = q(dat).where(@(x) x.pattern(end)=='1').select(@(x) x.visit(vis).(vars{i})).toArray;   
   temp2 = q(dat).where(@(x) x.deceased).select(@(x) x.visit(vis).(vars{i})).toArray;
   p = ranksum(temp1,temp2);   
   %fprintf('%s\t\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.3f\n',vars{i},nanmean(temp),nanstd(temp),nanmean(temp1),nanstd(temp1),nanmean(temp2),nanstd(temp2),p);
   
   scores{1,1} = temp;
   scores{1,2} = temp1;
   scores{1,3} = temp2;
   scores{1,4} = p;
   scores{1,5} = vars{i};
   SCORES = cat(1,SCORES,scores);
end

temp = q(dat).select(@(x) (x.visit(vis).('updrsIIIOffSOffM')-x.visit(vis).('axeOffSOffM')) / x.dureeEvolution2).toArray;
temp1 = q(dat).where(@(x) x.pattern(end)=='1').select(@(x) (x.visit(vis).('updrsIIIOffSOffM')-x.visit(vis).('axeOffSOffM')) / x.dureeEvolution2).toArray;
temp2 = q(dat).where(@(x) x.deceased).select(@(x) (x.visit(vis).('updrsIIIOffSOffM')-x.visit(vis).('axeOffSOffM')) / x.dureeEvolution2).toArray;
p = ranksum(temp1,temp2);
scores{1,1} = temp;
scores{1,2} = temp1;
scores{1,3} = temp2;
scores{1,4} = p;
scores{1,5} = 'nonaxialProg';
SCORES = cat(1,SCORES,scores);
%fprintf('%s\t\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.3f\n','nonaxialProgression',nanmean(temp),nanstd(temp),nanmean(temp1),nanstd(temp1),nanmean(temp2),nanstd(temp2),p);

temp = q(dat).select(@(x) x.visit(vis).('axeOffSOffM') / x.dureeEvolution2).toArray;
temp1 = q(dat).where(@(x) x.pattern(end)=='1').select(@(x) x.visit(vis).('axeOffSOffM') / x.dureeEvolution2).toArray;
temp2 = q(dat).where(@(x) x.deceased).select(@(x) x.visit(vis).('axeOffSOffM') / x.dureeEvolution2).toArray;
p = ranksum(temp1,temp2);
scores{1,1} = temp;
scores{1,2} = temp1;
scores{1,3} = temp2;
scores{1,4} = p;
scores{1,5} = 'axialProg';
SCORES = cat(1,SCORES,scores);
%fprintf('%s\t\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.3f\n','axialProgression',nanmean(temp),nanstd(temp),nanmean(temp1),nanstd(temp1),nanmean(temp2),nanstd(temp2),p);

[h,~,~,P] = stat.fdr_bh(cat(1,SCORES{:,4}),0.05,'pdep');
fprintf('\t\t\tAll (n=%g)\t10years (n=%g)\tDead (n=%g)\n',numel(temp),numel(temp1),numel(temp2))
for i = 1:size(SCORES,1)
   temp = SCORES{i,1};
   temp1 = SCORES{i,2};
   temp2 = SCORES{i,3};
   str = '                ';
   if numel(SCORES{i,5}) <= 16
      str(1:numel(SCORES{i,5})) = SCORES{i,5};
   else
      str = SCORES{i,5};
   end
   fprintf('%s\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.3f',str,nanmean(temp),nanstd(temp),nanmean(temp1),nanstd(temp1),nanmean(temp2),nanstd(temp2),P(i));
   if h(i)
      fprintf('*');
   end
   fprintf('\n');
end

