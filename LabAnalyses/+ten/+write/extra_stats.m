cd /Users/brian.lau/CloudStation/Work/Production/Papers/2015_STN10Year/Data/

dat = ten.load.data();


d = [dat.dureeEvolution2]';
median(d)
iqr(d)
prctile(d,[25 75])

d = [dat.ageAtIntervention]';
median(d)
iqr(d)
prctile(d,[25 75])

s = {dat.sex};
sum(strcmp(s,'F'))/length(s)

%
for i = 1:numel(dat)
   t1{i} = dat(i).doi;
   if dat(i).deceased
      deceased(i) = true;
      t2{i} = dat(i).dod;
   else
      deceased(i) = false;
      t2{i} = dat(i).dolv;
   end
end


d1 = years([dat.dureeEvolution2]');
d2 = between(datetime(t1),datetime(t2),'years')';

d3 = years(d1) + calyears(d2);

median(d3)
iqr(d3)
prctile(d3,[25 75])

%
d = [dat.ageDebut]';
sum(d < 45)
sum(d < 45) / length(d)