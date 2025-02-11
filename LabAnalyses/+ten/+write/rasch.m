
fid = 1;
fid = fopen(['rasch.txt'],'w');

d = ','; % delimiter

fprintf(fid,['id' d 'condition' d 'falls' d 'freezing' d 'marcheADL' d 'parole' d 'lever' d 'posture' d 'marche' d 'equilibre' '\n']);

for i = 1:numel(dat)
   for j = 1:2
      fprintf(fid,['%s' d],dat(i).id);
      if j == 1
         cond = 'OffSOffM';
         cond2 = 'Off';
      else
         cond = 'OffSOnM';
         cond2 = 'On';
      end
      fprintf(fid,['%s' d],cond);

      fprintf(fid,['%g' d],dat(i).visit(1).(['falls' cond2]));
      fprintf(fid,['%g' d],dat(i).visit(1).(['freezing' cond2]));
      fprintf(fid,['%g' d],dat(i).visit(1).(['marcheADL' cond2]));

      fprintf(fid,['%g' d],dat(i).visit(1).(['parole' cond]));
      fprintf(fid,['%g' d],dat(i).visit(1).(['lever' cond]));
      fprintf(fid,['%g' d],dat(i).visit(1).(['posture' cond]));
      fprintf(fid,['%g' d],dat(i).visit(1).(['marche' cond]));
      fprintf(fid,['%g'],dat(i).visit(1).(['equilibre' cond]));
      
      fprintf(fid,'\n');

   end
end
fclose(fid)