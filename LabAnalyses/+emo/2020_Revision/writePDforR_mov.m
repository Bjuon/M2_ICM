basedir = '/Users/brian/ownCloud/LFP_PD_OCD/PARK/paradigm';
savedir = '/Users/brian/ownCloud/LFP_PD_OCD/R_2020_2';
cd(basedir)
boucle = dir([basedir filesep '*PRETF.mat']);

load('/Users/brian/ownCloud/LFP_PD_OCD/R_2020/Coord_PK.mat')

for nfile = 1:numel(boucle)
   prepatient{nfile} = boucle(nfile).name(1:5);
end
clear nfile

patient = unique(prepatient);
clear prepatient

treat {1}='OFF';
treat {2}='ON';

for nindiv = 1:numel(patient)
   tic;
   
   savename = [savedir filesep patient{nindiv} '_PD_PRETF_'];
   
   count = 1;
   for ntreat = 1:2
      filename=[patient{nindiv} '_' treat{ntreat} '_PRETF.mat'];
      if exist(filename,'file')
         load(filename)
      else
         continue
      end
      
      if strcmp(patient{nindiv},'HANJe') && strcmp(treat{ntreat},'ON') || strcmp(patient{nindiv},'RACTh') && strcmp(treat{ntreat},'ON')
         for ntrial = 1:numel(s)
            s(ntrial).quality(4:5) = 0;
         end
      elseif strcmp(patient{nindiv},'LITRo') && strcmp(treat{ntreat},'OFF')
         for ntrial = 1:numel(s)
            s(ntrial).quality(4:6) = 0;
         end
      elseif strcmp(patient{nindiv},'PARJo') && strcmp(treat{ntreat},'OFF')
         for ntrial = 1:numel(s)
            s(ntrial).quality(1:3) = 0;
         end
      elseif strcmp(patient{nindiv},'DECPa') && strcmp(treat{ntreat},'OFF')
         for ntrial = 1:numel(s)
            s(ntrial).quality(5:6) = 0;
         end
      end
      clear ntrial
      
      q = linq(s);
      d = q.where(@(x) x.info('manureject')==0)...
         .where(@(x) x.info('response')==1)...
         .where(@(x) x.info('rt')>0 & x.info('rt')<2);
      clear q s
      
      
      for nelec = 1:6
         if ~d.array(1).quality(nelec) == 1
            continue
         else
            for ntrial = 1:numel(d.array)
               
               % verification artefact
               if d.array(ntrial).info('manureject')==1
                  continue
               else
                  % elec
                  elec{1} = d.array(ntrial).labels(nelec).name(1:2);
                  
                  if ~strcmp(d.array(ntrial).info('bloc'),'pleasant') && ~strcmp(d.array(ntrial).info('bloc'),'unpleasant')
                     continue;
                  else
                     % emo
                     if strcmp(d.array(ntrial).info('im'),'neu') && strcmp(d.array(ntrial).info('bloc'),'pleasant')
                        emo{1} = 'neupos';
                     elseif strcmp(d.array(ntrial).info('im'),'neu') && strcmp(d.array(ntrial).info('bloc'),'unpleasant')
                        emo{1} = 'neuneg';
                     else emo(1) = d.array(ntrial).info('im');
                     end
                     
                     % cond
                     if strcmp(d.array(ntrial).info('cond'),'passif')
                        cond(1) = d.array(ntrial).info('cond');
                     elseif (strcmp(d.array(ntrial).info('cond'),'go') && strcmp(d.array(ntrial).info('im'),'neg') && d.array(ntrial).info('response')==1 && d.array(ntrial).info('rt')>0 && d.array(ntrial).info('rt')<2) ...
                           || (strcmp(d.array(ntrial).info('cond'),'go') && strcmp(d.array(ntrial).info('im'),'pos') && d.array(ntrial).info('response')==1 && d.array(ntrial).info('rt')>0 && d.array(ntrial).info('rt')<2)...
                           || (strcmp(d.array(ntrial).info('cond'),'nogo') && strcmp(d.array(ntrial).info('im'),'neu') && d.array(ntrial).info('response')==1 && d.array(ntrial).info('rt')>0 && d.array(ntrial).info('rt')<2)
                        cond{1} = 'mot';
                     elseif (strcmp(d.array(ntrial).info('cond'),'nogo') && strcmp(d.array(ntrial).info('im'),'neg') && d.array(ntrial).info('response')==0) ...
                           || (strcmp(d.array(ntrial).info('cond'),'nogo') && strcmp(d.array(ntrial).info('im'),'pos') && d.array(ntrial).info('response')==0)...
                           || (strcmp(d.array(ntrial).info('cond'),'go') && strcmp(d.array(ntrial).info('im'),'neu') && d.array(ntrial).info('response')==0)
                        cond{1} = 'nonmot';
                     else
                        cond{1} = '';
                     end
                     
                     if ~strcmp(cond{1},'mot')
                        continue
                     else
                        % hemi
                        if strcmp(d.array(ntrial).labels(nelec).name(3),'D')
                           hemi{1}='D';
                        else
                           hemi{1}='G';
                        end
                        
                        ind = strcmp(patient{nindiv}(1:3),{Coord_PK.names}) & ...
                           strcmp(elec,{Coord_PK.dipoles}) & ...
                           strcmp(hemi,{Coord_PK.side}) & ...
                           strcmp('ACPC',{Coord_PK.coord});
                        if sum(ind)==1
                           X = Coord_PK(ind).X;
                           Y = Coord_PK(ind).Y;
                           Z = Coord_PK(ind).Z;
                        else
                           X = NaN;
                           Y = NaN;
                           Z = NaN;
                        end
                           
                        % rt arousal valence
                        rt(1)=d.array(ntrial).info('rt');
                        
                        %comput
                        win1 = round(d.array(ntrial).info('rt')*512);
                        win2 = win1 + 1536;
                        
                        u = d.array(ntrial).values{1}(win1:win2,nelec);
                        ubl = d.array(ntrial).values{1}(:,nelec);
                        
                        movingwin = [0.5 0.05];
                        %params = struct('tapers',[3 5],'pad',1,'Fs',d.array(ntrial).Fs,'fpass',[2 100],'trialave',0);
                        params = struct('tapers',[1.5 2],'pad',1,'Fs',d.array(ntrial).Fs,'fpass',[2 100],'trialave',0);
                        [S,t,f] = mtspecgramc(u,movingwin,params);
                        [Sbl,tbl,fbl] = mtspecgramc(ubl,movingwin,params);
                        
                        for nfreq = 1:size(f,2)
                           for nbin = 1:size(t,2)
                              Snorm1bl(nbin,nfreq) = 10*log10(Sbl(nbin,nfreq));
                              Snorm1(nbin,nfreq) = 10*log10(S(nbin,nfreq));
                           end
                        end
                        clear S Sbl nbin nfreq u ubl
                        
                        tlim1bl = find(tbl>0.3);
                        tlim2bl = find(tbl<0.8);
                        
                        for nfreq = 1:size(f,2)
                           bl(nfreq)=nanmean(Snorm1bl(tlim1bl(1):tlim2bl(end),nfreq));
                           for nbin = 1:size(t,2)
                              Snorm(nbin,nfreq) = Snorm1(nbin,nfreq)-bl(nfreq);
                              if ~isreal(Snorm(nbin,nfreq))
                                 Snorm(nbin,nfreq) = NaN;
                              end
                           end
                        end
                        clear tlim1bl tlim2bl nfreq bl nbin Snorm1bl Snorm1
                        
                        if isempty(cond{1})
                           continue;
                        else
                           dat(count).Subject = patient{nindiv};
                           dat(count).Elec = elec{1};
                           dat(count).X = X;
                           dat(count).Y = Y;
                           dat(count).Z = Z;
                           dat(count).Emo = emo{1};
                           dat(count).Cond = cond{1};
                           dat(count).Treat = treat{ntreat};
                           dat(count).Hemi = hemi{1};
                           dat(count).RT = rt;
                           dat(count).Snorm = Snorm;
                           dat(count).t = t;
                           dat(count).f = f;
                           
                           count = count + 1;
                           %thevalue = [patient{nindiv} ' ' elec{1} ' ' emo{1} ' ' treat{ntreat} ' ' hemi{1} ' ' num2str(rt(1)) ' ' num2str(pow(1))];
                           %fprintf(fid,'%s\n',thevalue);
                        end
                     end
                  end
               end
               clear elec cond hemi u movingwin params S t f Snorm tlim1 tlim2 flim1 flim2 rt pow thevalue
            end
            clear ntrial
         end
      end
      clear nelec d
   end
   clear ntreat
   toc
   
   S = cat(3,dat.Snorm);
   save([savename 'TF_mov.mat'],'S','-v6');
   dat = rmfield(dat,'Snorm');
   
   t = dat(1).t;
   f = dat(1).f;
   save([savename 'TFind_mov.mat'],'t','f','-v6');
   
   dat = rmfield(dat,'t');
   dat = rmfield(dat,'f');
   
   tab = struct2table(dat);
   
   writetable(tab,[savename 'info_mov.csv']);
   clear S t f tab dat;
   
end
clear nindiv boucle patient treat
