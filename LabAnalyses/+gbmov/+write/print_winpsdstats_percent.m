gbmov.batch.winpsdstats;
f = m(1).f;

f_range = [12 20];
% Run script to generate variables
gbmov.fig.bk_vars;

% Average within frequency range, keep channels separate
tasks = {'BASELINEASSIS' };%{'BASELINEASSIS' 'BASELINEDEBOUT' 'REACH' 'MSUP'};

fid = fopen('percent_power.txt','w+');
fprintf(fid,'p,');
fprintf(fid,'PATIENTID,TASK,SIDE,CHANNEL,locAP,locML,locDV,classAP,classML,classDV,');
fprintf(fid,'UPDRSIII,BR,BRADYKINESIA,RIGIDITY,TREMOR,AXIAL,UPDRSIV,EQUIVDOPA,DUREE_LDOPA,pOn,pOff,peakp,TH');
fprintf(fid,'\n')

for i = 1:numel(info)
   for j = 1:numel(tasks)
      if fsOff(i) == fsOn(i) % Matching sampling frequencies
         for c = 1:6
            if ~isnan(PERCENT_POWER(i,c))
               fprintf(fid,'%1.3f,',PERCENT_POWER(i,c));
               fprintf(fid,'%s,%s,',m(i).PATIENTID,tasks{j});
               if c <= 3
                  fprintf(fid,'%s,','L');
                  fprintf(fid,'%g,',c);
               else
                  fprintf(fid,'%s,','R');
                  fprintf(fid,'%g,',c-3);
               end
               fprintf(fid,'%1.3f,%1.3f,%1.3f,%g,%g,%g,',...
                  locAP(i,c),...
                  locML(i,c),...
                  locDV(i,c),...
                  classAP(i,c),...
                  classML(i,c),...
                  classDV(i,c));
               fprintf(fid,'%1.3f,%1.3f,%1.3f,%1.3f,%1.3f,%1.3f,%1.3f,%1.3f,%1.3f,%1.3f,%1.3f,%1.3f,',...
                  PERCENT_UPDRSIII(i,c),...
                  PERCENT_BR(i,c),...
                  PERCENT_BRADYKINESIA(i,c),...
                  PERCENT_RIGIDITY(i,c),...
                  PERCENT_AXIAL(i,c),...
                  PERCENT_TREMOR(i,c),...
                  m(i).UPDRS_IV,...
                  m(i).EQUIVLDOPA,m(i).DUREE_LDOPA,pOn(i,c),pOff(i,c));
               if c <= 3
                  fprintf(fid,'%1.3f,',PERCENT_PEAKPOWER(i,2)); % RIGHT
               else
                  fprintf(fid,'%1.3f,',PERCENT_PEAKPOWER(i,1)); % LEFT
               end
               if c == 1
                  fprintf(fid,'%g\n',m(i).CP_01G);
               elseif c == 2
                  fprintf(fid,'%g\n',m(i).CP_12G);
               elseif c == 3
                  fprintf(fid,'%g\n',m(i).CP_23G);
               elseif c == 4
                  fprintf(fid,'%g\n',m(i).CP_01D);
               elseif c == 5
                  fprintf(fid,'%g\n',m(i).CP_12D);
               else
                  fprintf(fid,'%g\n',m(i).CP_23D);
               end
            end
         end
      end
   end
end
fclose(fid);

% Peak power within frequency range, keep only peak channel (BROWN)
fid = fopen('percent_peak_power.txt','w+');
fprintf(fid,'p,');
fprintf(fid,'PATIENTID,TASK,SIDE,CHANNEL,locAP,locML,locDV,classAP,classML,classDV,');
fprintf(fid,'UPDRSIII,BR,BRADYKINESIA,RIGIDITY,UPDRSIV,EQUIVDOPA,DUREE_LDOPA,pOn,pOff');
fprintf(fid,'\n');

for i = 1:numel(info)
   for j = 1:numel(tasks)
      if fsOff(i) == fsOn(i)
         for c = 1:2
            if ~isnan(PERCENT_PEAKPOWER(i,c))
               fprintf(fid,'%1.3f,',PERCENT_PEAKPOWER(i,c));
               fprintf(fid,'%s,%s,',m(i).PATIENTID,tasks{j});
               if c == 1
                  fprintf(fid,'%s,','L');
                  ind = find(maxIndOff(i,1:3));
               else
                  fprintf(fid,'%s,','R');
                  ind = 3 + find(maxIndOff(i,4:6));
               end
               
               fprintf(fid,'%g,',ind);
               fprintf(fid,'%1.3f,%1.3f,%1.3f,%g,%g,%g,',...
                  locAP(i,ind),...
                  locML(i,ind),...
                  locDV(i,ind),...
                  classAP(i,ind),...
                  classML(i,ind),...
                  classDV(i,ind));
               fprintf(fid,'%1.3f,%1.3f,%1.3f,%1.3f,%1.3f,%1.3f,%1.3f,%1.3f,%1.3f\n',...
                  PERCENT_UPDRSIII(i,ind),...
                  PERCENT_BR(i,ind),...
                  PERCENT_BRADYKINESIA(i,ind),...
                  PERCENT_RIGIDITY(i,ind),...
                  m(i).UPDRS_IV,...
                  m(i).EQUIVLDOPA,m(i).DUREE_LDOPA,peakOn(i,c),peakOff(i,c));
            end
         end
      end
   end
end
fclose(fid);
