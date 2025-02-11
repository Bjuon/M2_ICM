function csv3(dat,score)

fid = 1;
fid = fopen('test3.txt','w');
fid_id = fopen('test3_id.txt','w');
%score = 'updrsIII';


t = [0 1 2 5 10];
d = ','; % delimiter


fprintf(fid,['id' d 'score' d 'treatment' d 't' d 't2' d 'sex' d 'ageAtIntervention' d 'duration' d...
   'updrsI_Intake' d 'updrsIIOff_Intake' d 'updrsIIIOff_Intake' d 'updrsIV_Intake' d...
   'deceased' d 'survival' d 'dementia' d 'hallucinations' d 'Mattis' d 'frontal' d...
   'ledd' d 'axeOff_Intake' d 'tremorOff_Intake' d 'rigidityOff_Intake' d 'akinesiaOff_Intake' d...
   'fallsOn_Intake' d 'fallsOff_Intake' d 'swallowingOff_Intake' '\n']);
fprintf(fid_id,['id' d 'sex' d 'ageAtIntervention' d 'duration' d...
   'updrsI_Intake' d 'updrsIIOff_Intake' d 'updrsIIIOff_Intake' d 'updrsIV_Intake' d...
   'deceased' d 'survival' d 'dementia' d 'hallucinations' d 'Mattis' d 'frontal' d...
   'ledd' d 'axeOff_Intake' d 'tremorOff_Intake' d 'rigidityOff_Intake' d 'akinesiaOff_Intake' d...
   'fallsOn_Intake' d 'fallsOff_Intake' d 'swallowingOff_Intake' '\n']);
% fprintf(fid,['id' d 'score' d 'treatment' d 't' d 'sex' d 'ageAtIntervention' d 'duration' d...
%    'updrsI_Intake' d 'updrsIIOff_Intake' d 'updrsIIIOff_Intake' d 'updrsIV_Intake' d...
%    'deceased' d 'survival' '\n']);

lineWritten = false;
for i = 1:numel(dat)
   for j = 2:5
      if ~isnan(dat(i).visit(j).([score 'OffSOffM'])) && ~isnan(dat(i).visit(j).([score 'OffSOnM']))
         fprintf(fid,['%s' d],dat(i).id);
         fprintf(fid,['%g' d '%s' d],-dat(i).visit(j).([score 'OffSOffM']) + dat(i).visit(j).([score 'OffSOnM']),'OffSOnM');
         fprintf(fid,['%g' d],dat(i).visit(j).monthsReIntervention);
         fprintf(fid,['%g' d],t(j));
         fprintf(fid,['%s' d '%g' d '%g' d],...
            dat(i).sex,dat(i).ageAtIntervention,dat(i).dureeEvolution2);
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(1).updrsI,dat(i).visit(1).updrsIIOff,dat(i).visit(1).updrsIIIOffSOffM,dat(i).visit(1).updrsIV);
         fprintf(fid,['%g' d '%g' d],...
            dat(i).deceased,dat(i).survival2);
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(1).dementia,dat(i).visit(1).hallucinations,dat(i).visit(1).Mattis,dat(i).visit(1).frontal50,dat(i).visit(1).ldopaEquiv);
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(1).axeOffSOffM,dat(i).visit(1).tremorOffSOffM,dat(i).visit(1).rigidityOffSOffM,dat(i).visit(1).akinesiaOffSOffM);
         fprintf(fid,['%g' d '%g' d '%g' ],dat(i).visit(1).fallsOn,dat(i).visit(1).fallsOff,dat(i).visit(1).swallowingOff);
         fprintf(fid,'\n');
         
         lineWritten = true;
      end
      if ~isnan(dat(i).visit(j).([score 'OffSOffM'])) && ~isnan(dat(i).visit(j).([score 'OnSOffM']))
         fprintf(fid,['%s' d],dat(i).id);
         fprintf(fid,['%g' d '%s' d],-dat(i).visit(j).([score 'OffSOffM']) + dat(i).visit(j).([score 'OnSOffM']),'OnSOffM');
         fprintf(fid,['%g' d],dat(i).visit(j).monthsReIntervention);
         fprintf(fid,['%g' d],t(j));
         fprintf(fid,['%s' d '%g' d '%g' d],...
            dat(i).sex,dat(i).ageAtIntervention,dat(i).dureeEvolution2);
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(1).updrsI,dat(i).visit(1).updrsIIOff,dat(i).visit(1).updrsIIIOffSOffM,dat(i).visit(1).updrsIV);
         fprintf(fid,['%g' d '%g' d],...
            dat(i).deceased,dat(i).survival2);
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(1).dementia,dat(i).visit(1).hallucinations,dat(i).visit(1).Mattis,dat(i).visit(1).frontal50,dat(i).visit(1).ldopaEquiv);
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(1).axeOffSOffM,dat(i).visit(1).tremorOffSOffM,dat(i).visit(1).rigidityOffSOffM,dat(i).visit(1).akinesiaOffSOffM);
         fprintf(fid,['%g' d '%g' d '%g' ],dat(i).visit(1).fallsOn,dat(i).visit(1).fallsOff,dat(i).visit(1).swallowingOff);
         fprintf(fid,'\n');
         
         lineWritten = true;
      end
      if ~isnan(dat(i).visit(j).([score 'OffSOffM'])) && ~isnan(dat(i).visit(j).([score 'OnSOnM']))
         fprintf(fid,['%s' d],dat(i).id);
         fprintf(fid,['%g' d '%s' d],-dat(i).visit(j).([score 'OffSOffM']) + dat(i).visit(j).([score 'OnSOnM']),'OnSOnM');
         fprintf(fid,['%g' d],dat(i).visit(j).monthsReIntervention);
         fprintf(fid,['%g' d],t(j));
         fprintf(fid,['%s' d '%g' d '%g' d],...
            dat(i).sex,dat(i).ageAtIntervention,dat(i).dureeEvolution2);
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(1).updrsI,dat(i).visit(1).updrsIIOff,dat(i).visit(1).updrsIIIOffSOffM,dat(i).visit(1).updrsIV);
         fprintf(fid,['%g' d '%g' d],...
            dat(i).deceased,dat(i).survival2);
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(1).dementia,dat(i).visit(1).hallucinations,dat(i).visit(1).Mattis,dat(i).visit(1).frontal50,dat(i).visit(1).ldopaEquiv);
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(1).axeOffSOffM,dat(i).visit(1).tremorOffSOffM,dat(i).visit(1).rigidityOffSOffM,dat(i).visit(1).akinesiaOffSOffM);
         fprintf(fid,['%g' d '%g' d '%g' ],dat(i).visit(1).fallsOn,dat(i).visit(1).fallsOff,dat(i).visit(1).swallowingOff);
         fprintf(fid,'\n');
         
         lineWritten = true;
      end
   end
   
   if lineWritten
      fprintf(fid_id,['%s' d],dat(i).id);
      fprintf(fid_id,['%s' d '%g' d '%g' d],...
         dat(i).sex,dat(i).ageAtIntervention,dat(i).dureeEvolution2);
      fprintf(fid_id,['%g' d '%g' d '%g' d '%g' d],...
         dat(i).visit(1).updrsI,dat(i).visit(1).updrsIIOff,dat(i).visit(1).updrsIIIOffSOffM,dat(i).visit(1).updrsIV);
      if dat(i).survival2 <= max([dat(i).visit.monthsReIntervention])
         fprintf(fid_id,['%g' d '%g' d],...
            dat(i).deceased,dat(i).survival2+1);
      else
         fprintf(fid_id,['%g' d '%g' d],...
            dat(i).deceased,dat(i).survival2);
      end
      fprintf(fid_id,['%g' d '%g' d '%g' d '%g' d '%g' d],...
         dat(i).visit(1).dementia,dat(i).visit(1).hallucinations,dat(i).visit(1).Mattis,dat(i).visit(1).frontal50,dat(i).visit(1).ldopaEquiv);
      fprintf(fid_id,['%g' d '%g' d '%g' d '%g' d],...
         dat(i).visit(1).axeOffSOffM,dat(i).visit(1).tremorOffSOffM,dat(i).visit(1).rigidityOffSOffM,dat(i).visit(1).akinesiaOffSOffM);
      fprintf(fid_id,['%g' d '%g' d '%g' ],dat(i).visit(1).fallsOn,dat(i).visit(1).fallsOff,dat(i).visit(1).swallowingOff);
      fprintf(fid_id,'\n');
   end
   
   lineWritten = false;
end
fclose(fid);
fclose(fid_id);