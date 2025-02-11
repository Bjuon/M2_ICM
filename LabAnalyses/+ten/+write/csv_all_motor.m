%score = 'akinesia';
% ten.write.csv(dat,'akinesia');
% ten.write.csv(dat,'tremor');
% ten.write.csv(dat,'rigidity');
% ten.write.csv(dat,'axe');

function csv_all_motor(dat)

%fid = 1;
fid = fopen(['motor_subscores.txt'],'w');

t = [0 1 2 5 10]; % nominal follow-up times
d = ','; % delimiter

% DSK, OFF, levodopa, axeOn
% ageatonset (? equal to age at intervention - duration?)
% year of surgery
% levodopa response

fprintf(fid,['id' d 'akinesia' d 'tremor' d 'rigidity' d 'axe' d...
   'treatment' d 't' d 't2' d 'sex' d 'ageAtIntervention' d 'ageDebut' d 'duration' d...
   'yearOfSurgery' d 'doparesponse' d...
   'updrsI_Intake' d 'updrsIIOff_Intake' d 'updrsIIIOff_Intake' d 'updrsIV_Intake' d...
   'deceased' d 'deceased2' d 'survival' d 'dementia_Intake' d 'hallucinations_Intake' d 'Mattis' d 'frontal' d...
   'ledd' d 'axeOff_Intake' d 'axeOn_Intake' d 'tremorOff_Intake' d 'tremorOn_Intake' d 'rigidityOff_Intake' d 'rigidityOn_Intake' d 'akinesiaOff_Intake' d 'akinesiaOn_Intake' d...
   'fallsOn_Intake' d 'fallsOff_Intake' d 'swallowingOff_Intake' '\n']);

for i = 1:numel(dat)
   for j = 2:5
      %if ~isnan(dat(i).visit(j).([score 'OffSOffM']))
         fprintf(fid,['%s' d],dat(i).id);
         
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(j).(['akinesia' 'OffSOffM']),dat(i).visit(j).(['tremor' 'OffSOffM']),dat(i).visit(j).(['rigidity' 'OffSOffM']),dat(i).visit(j).(['axe' 'OffSOffM']));
         fprintf(fid,['%s' d],'OffSOffM');
         
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
      %end

      %if ~isnan(dat(i).visit(j).([score 'OffSOnM']))
         fprintf(fid,['%s' d],dat(i).id);
         
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(j).(['akinesia' 'OffSOnM']),dat(i).visit(j).(['tremor' 'OffSOnM']),dat(i).visit(j).(['rigidity' 'OffSOnM']),dat(i).visit(j).(['axe' 'OffSOnM']));
         fprintf(fid,['%s' d],'OffSOnM');
         
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
      %end
      
      %if ~isnan(dat(i).visit(j).([score 'OnSOffM']))
         fprintf(fid,['%s' d],dat(i).id);
         
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(j).(['akinesia' 'OnSOffM']),dat(i).visit(j).(['tremor' 'OnSOffM']),dat(i).visit(j).(['rigidity' 'OnSOffM']),dat(i).visit(j).(['axe' 'OnSOffM']));
         fprintf(fid,['%s' d],'OnSOffM');
         
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
      %end
      
      %if ~isnan(dat(i).visit(j).([score 'OnSOnM']))
         fprintf(fid,['%s' d],dat(i).id);
                  
         fprintf(fid,['%g' d '%g' d '%g' d '%g' d],...
            dat(i).visit(j).(['akinesia' 'OnSOnM']),dat(i).visit(j).(['tremor' 'OnSOnM']),dat(i).visit(j).(['rigidity' 'OnSOnM']),dat(i).visit(j).(['axe' 'OnSOnM']));
         fprintf(fid,['%s' d],'OnSOnM');
         
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
         
      %end
   end
end

fclose(fid);
