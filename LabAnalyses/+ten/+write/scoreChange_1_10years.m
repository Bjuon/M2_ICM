
score = 'axe';
cond = 'OnSOnM';
for i = 1:numel(dat)
   temp_0(i) = dat(i).visit(1).([score cond]);
   temp_1(i) = dat(i).visit(2).([score cond]);
   temp_10(i) = dat(i).visit(5).([score cond]);
end

nanmean(temp_10 - temp_0)
nanstd(temp_10 - temp_0)

nanmean(temp_10 - temp_1)
nanstd(temp_10 - temp_1)



score = 'updrsII';
cond = 'On';
for i = 1:numel(dat)
   temp_0(i) = dat(i).visit(1).([score cond]);
   temp_1(i) = dat(i).visit(2).([score cond]);
   temp_10(i) = dat(i).visit(5).([score cond]);
end

nanmean(temp_10 - temp_0)
nanstd(temp_10 - temp_0)

nanmean(temp_10 - temp_1)
nanstd(temp_10 - temp_1)


score = 'ldopaEquiv';
for i = 1:numel(dat)
   temp_0(i) = dat(i).visit(1).([score]);
   temp_1(i) = dat(i).visit(2).([score]);
   temp_2(i) = dat(i).visit(3).([score]);
   temp_5(i) = dat(i).visit(4).([score]);
   temp_10(i) = dat(i).visit(5).([score]);
end

nanmean((temp_1 - temp_0)./temp_0)
nanmean((temp_2 - temp_0)./temp_0)
nanmean((temp_5 - temp_0)./temp_0)
nanmean((temp_10 - temp_0)./temp_0)

score = 'DSK';
for i = 1:numel(dat)
   temp_0(i) = dat(i).visit(1).([score]);
   temp_1(i) = dat(i).visit(2).([score]);
   temp_10(i) = dat(i).visit(5).([score]);
end

nanmean(temp_10 - temp_0)
nanstd(temp_10 - temp_0)

nanmean(temp_10 - temp_1)
nanstd(temp_10 - temp_1)

score = 'OFF';
for i = 1:numel(dat)
   temp_0(i) = dat(i).visit(1).([score]);
   temp_1(i) = dat(i).visit(2).([score]);
   temp_10(i) = dat(i).visit(5).([score]);
end

nanmean(temp_10 - temp_0)
nanstd(temp_10 - temp_0)

nanmean(temp_10 - temp_1)
nanstd(temp_10 - temp_1)


