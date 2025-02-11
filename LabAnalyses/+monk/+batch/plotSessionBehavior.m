
monkeys = {'Chanel' 'Jules' 'Flocky' 'Tess'};
tasks = {'1DR' 'GNG'};

dateStart = '01/02/2017';
dateEnd = '04/05/2017';
overwrite = false;
mintrials = 100;

for i = 1:numel(monkeys)
   for j = 1:numel(tasks)
      monk.plot.sessionBehavior(monkeys{i},tasks{j},dateStart,dateEnd,overwrite,mintrials);
   end
end