cd /Users/brian/Downloads/

fnames = {'Ratta_10 sessions.mat',...
          'Q_10 sessions.mat',...
          'Pika_10 sessions.mat'};
       
for i = 1:numel(fnames)
   temp = strsplit(fnames{i},'_');
   id = temp{1};
   
   dat = load(fnames{i});
   dat = dat.(id);
   
   %ind = ~isnan(dat(:,1)) & ~isnan(dat(:,2));
   %dat = dat(ind,:);
   
   isAbort = isnan(dat(:,1)) | isnan(dat(:,2));
   
   fid = fopen([id '.txt'],'wt');
   fprintf(fid,'Trial.Type,Is.Aborted,RT,MT\n');
   for j = 1:size(dat,1)
      if dat(j,3) == 0
         fprintf(fid,'Incongruent,');
      else
         fprintf(fid,'Congruent,');
      end
      fprintf(fid,'%g,%g,%g\n',isAbort(j),dat(j,1),dat(j,2));
         
   end
   fclose(fid);
end