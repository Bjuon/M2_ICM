
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

max(datetime(t2))

d = between(datetime(t1),datetime(t2),'months')
d = calmonths(d)

min(datetime(t1))
max(datetime(t1))

max(d)
median(d)
iqr(d)
prctile(d,[25 75])

median(d(deceased))
iqr(d(deceased))
prctile(d(deceased),[25 75])


%

