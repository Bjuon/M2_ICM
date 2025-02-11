clear SCORES scores P;
SCORES = {};
q = linq();
%%
vars = {'dementia' 'hallucinations' 'updrsIIOff' 'updrsIIOn' 'swallowingOff' 'swallowingOn' 'fallsOff' 'fallsOn'...
        'updrsIIIOffSOffM' 'updrsIIIOffSOnM' 'updrsIIIOnSOffM' 'updrsIIIOnSOnM'...
        'akinesiaOffSOffM' 'akinesiaOffSOnM' 'akinesiaOnSOffM' 'akinesiaOnSOnM'...
        'rigidityOffSOffM' 'rigidityOffSOnM' 'rigidityOnSOffM' 'rigidityOnSOnM'...
        'tremorOffSOffM' 'tremorOffSOnM' 'tremorOnSOffM' 'tremorOnSOnM'...
        'axeOffSOffM' 'axeOffSOnM' 'axeOnSOffM' 'axeOnSOnM'...
        'updrsIV' 'OFF' 'DSK' 'HYOff' 'HYOn' 'SEOff' 'SEOn'...
        'MMS' 'Mattis' 'frontal50' 'Wisconsin' 'ldopa' 'agonists'};

for i = 1:numel(vars)
   temp1 = q(dat).where(@(x) x.pattern(end)=='1').select(@(x) x.visit(1).(vars{i})).toArray;   
   temp2 = q(dat).where(@(x) x.pattern(end)=='1').select(@(x) x.visit(5).(vars{i})).toArray;
   try
      p = signrank(temp1,temp2);
   catch
      p = NaN;
   end
   %fprintf('%s\t\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.3f\n',vars{i},nanmean(temp),nanstd(temp),nanmean(temp1),nanstd(temp1),nanmean(temp2),nanstd(temp2),p);
   
   scores{1,1} = temp1;
   scores{1,2} = temp2;
   scores{1,3} = p;
   scores{1,4} = vars{i};
   SCORES = cat(1,SCORES,scores);
end

[h,~,~,P] = stat.fdr_bh(cat(1,SCORES{:,3}),0.05,'pdep');
fprintf('\t\t\tBaseline\t10years (n=%g)\n',numel(temp1))
for i = 1:size(SCORES,1)
   temp1 = SCORES{i,1};
   temp2 = SCORES{i,2};
   str = '                ';
   if numel(SCORES{i,4}) <= 16
      str(1:numel(SCORES{i,4})) = SCORES{i,4};
   else
      str = SCORES{i,4};
   end
   fprintf('%s\t%1.2f(%1.2f)\t%1.2f(%1.2f)\t%1.3f',str,nanmean(temp1),nanstd(temp1),nanmean(temp2),nanstd(temp2),P(i));
   if h(i)
      fprintf('*');
   end
   fprintf('\n');
end
