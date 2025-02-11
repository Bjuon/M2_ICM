[out] = gbmov.load.getBasicScores4('raw',true);


id = {out.id};
uid = unique(id);

clear mat;
for i = 1:numel(uid)
   ind = strcmp(id,uid{i});
   temp = out(ind);
   
   t1 = 0;
   t2 = 0;
   n = [];
   sides = [];
   for j = 1:numel(temp)
      fprintf('%s\t%s\t%g\t%1.2f\n',temp(j).id,temp(j).cond,...
         length(temp(j).labels),4*mean(sum(temp(j).mask)));
      t1 = t1 + 4*size(temp(j).mask,1);
      t2 = t2 + 4*mean(sum(temp(j).mask));
      n = [n , length(temp(j).labels)];
      
      sides = [sides , numel(unique({temp(j).labels.side}))];
   end
   mat(i).id = uid{i};
   mat(i).n = n;               % number of clean dipoles
   mat(i).sides = sides;
   mat(i).t1 = t1/numel(temp); % Average recording time, ignoring artifacts
   mat(i).t2 = t2/numel(temp); % Average recording time, removing artifacts
end

mean([mat.t1])
mean([mat.t2])
sum(arrayfun(@(x) mean(x.n),mat))

arrayfun(@(x) mean(x.n),mat)
