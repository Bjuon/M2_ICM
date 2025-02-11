% scores with one condition, like Mattis

function csv1(dat,score)

fid = 1;
fid = fopen([score '.txt'],'w');

t = [0 1 2 5 10];
d = ','; % delimiter

% DSK, OFF, levodopa, axeOn
% ageatonset (? equal to age at intervention - duration?)
% year of surgery
% levodopa response

fprintf(fid,['id' d 'score' d...
   't' d 't2' d 'sex' d 'ageAtIntervention' d 'ageDebut' d 'duration' d...
   'yearOfSurgery' d 'doparesponse' d...
   'updrsI_Intake' d 'updrsIIOff_Intake' d 'updrsIIIOff_Intake' d 'updrsIV_Intake' d...
   'deceased' d 'deceased2' d 'survival' d 'dementia_Intake' d 'hallucinations_Intake' d 'Mattis' d 'frontal' d...
   'ledd' d 'axeOff_Intake' d 'axeOn_Intake' d 'tremorOff_Intake' d 'tremorOn_Intake' d 'rigidityOff_Intake' d 'rigidityOn_Intake' d 'akinesiaOff_Intake' d 'akinesiaOn_Intake' d...
   'fallsOn_Intake' d 'fallsOff_Intake' d 'swallowingOff_Intake' '\n']);

lineWritten = false;
for i = 1:numel(dat)
   for j = 2:5
      if ~isnan(dat(i).visit(j).(score))
         fprintf(fid,['%s' d],dat(i).id);
         fprintf(fid,['%g' d],dat(i).visit(j).(score));
         fprintf(fid,['%g' d],dat(i).visit(j).monthsReIntervention);
         fprintf(fid,['%g' d],t(j));
         fprintf(fid,['%s' d '%g' d '%g' d '%g' d],...
            dat(i).sex,dat(i).ageAtIntervention,dat(i).ageDebut,dat(i).dureeEvolution2);
         doparesponse = (dat(i).visit(1).updrsIIIOffSOffM-dat(i).visit(1).updrsIIIOffSOnM)/dat(i).visit(1).updrsIIIOffSOffM;
         fprintf(fid,['%g' d '%1.3f' d],...
            str2num(dat(i).doi(end-3:end)),doparesponse);
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(1).updrsI,dat(i).visit(1).updrsIIOff,dat(i).visit(1).updrsIIIOffSOffM,dat(i).visit(1).updrsIV);
         fprintf(fid,['%g' d],dat(i).deceased);
         if dat(i).deceasedPark
            fprintf(fid,['%s' d],'deceasedPark');
         elseif dat(i).deceasedNonPark
            fprintf(fid,['%s' d],'deceasedNonPark');
         else
            fprintf(fid,['%s' d],'alive');
         end
         fprintf(fid,['%g' d],dat(i).survival2);
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(1).dementia,dat(i).visit(1).hallucinations,dat(i).visit(1).Mattis,dat(i).visit(1).frontal50,dat(i).visit(1).ldopaEquiv);
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d '%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(1).axeOffSOffM,dat(i).visit(1).axeOffSOnM,dat(i).visit(1).tremorOffSOffM,dat(i).visit(1).tremorOffSOnM,dat(i).visit(1).rigidityOffSOffM,dat(i).visit(1).rigidityOffSOnM,dat(i).visit(1).akinesiaOffSOffM,dat(i).visit(1).akinesiaOffSOnM);
         fprintf(fid,['%g' d '%g' d '%g' ],dat(i).visit(1).fallsOn,dat(i).visit(1).fallsOff,dat(i).visit(1).swallowingOff);
         fprintf(fid,'\n');
         
         lineWritten = true;
      end
   end
   
%    if lineWritten
%       fprintf(fid_id,['%s' d],dat(i).id);
%       fprintf(fid_id,['%s' d '%g' d '%g' d '%g' d],...
%          dat(i).sex,dat(i).ageAtIntervention,dat(i).ageDebut,dat(i).dureeEvolution2);
%       doparesponse = (dat(i).visit(1).updrsIIIOffSOffM-dat(i).visit(1).updrsIIIOffSOnM)/dat(i).visit(1).updrsIIIOffSOffM;
%       fprintf(fid_id,['%g' d '%1.3f' d],...
%          str2num(dat(i).doi(end-3:end)),doparesponse);
%       fprintf(fid_id,['%g' d '%g' d '%g' d '%g' d],...
%          dat(i).visit(1).updrsI,dat(i).visit(1).updrsIIOff,dat(i).visit(1).updrsIIIOffSOffM,dat(i).visit(1).updrsIV);
%       if dat(i).survival2 <= max([dat(i).visit.monthsReIntervention])
%          fprintf(fid_id,['%g' d '%g' d],...
%             dat(i).deceased,dat(i).survival2+1);
%       else
%          fprintf(fid_id,['%g' d '%g' d],...
%             dat(i).deceased,dat(i).survival2);
%       end
%       fprintf(fid_id,['%g' d '%g' d '%g' d '%g' d '%g' d],...
%          dat(i).visit(1).dementia,dat(i).visit(1).hallucinations,dat(i).visit(1).Mattis,dat(i).visit(1).frontal50,dat(i).visit(1).ldopaEquiv);
%       fprintf(fid_id,['%g' d '%g' d '%g' d '%g' d],...
%          dat(i).visit(1).axeOffSOffM,dat(i).visit(1).tremorOffSOffM,dat(i).visit(1).rigidityOffSOffM,dat(i).visit(1).akinesiaOffSOffM);
%       fprintf(fid_id,['%g' d '%g' d '%g' ],dat(i).visit(1).fallsOn,dat(i).visit(1).fallsOff,dat(i).visit(1).swallowingOff);
%       fprintf(fid_id,'\n');
%    end
   lineWritten = false;
end
fclose(fid);
