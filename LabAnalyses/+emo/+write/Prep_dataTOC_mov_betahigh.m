basedir = '/Users/brian/ownCloud/LFP_PD_OCD/TOC/STN/paradigm/';
savedir = '/Users/brian/ownCloud/LFP_PD_OCD/R_2020';
cd(basedir)
boucle = dir([basedir filesep '*PRETF.mat']);

for nfile = 1:numel(boucle)
    prepatient{nfile} = boucle(nfile).name(1:5);
end
clear nfile

patient = unique(prepatient);
clear prepatient

fid = fopen([savedir filesep 'dataTOC_mov_betahigh.txt'],'w');
fprintf(fid,'%s\n','Subject Elec Emo Treat Hemi RT Power');

for nindiv = 1:numel(patient)
    filename=[patient{nindiv} '_PRETF.mat'];
    load(filename)
    
    if strcmp(patient{nindiv},'SALSo')
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
                                || (strcmp(d.array(ntrial).info('cond'),'nogo') && strcmp(d.array(ntrial).info('im'),'neu') && d.array(ntrial).info('response')==1 && d.array(ntrial).info('rt')>0 && d.array(ntrial).info('rt')<2);
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
                            
                            % rt arousal valence
                            rt(1)=d.array(ntrial).info('rt');
%                             arousal(1)=d.array(ntrial).info('arousal');
%                             valence(1)=d.array(ntrial).info('valence');
                            
                            % treat
                            treat{1} = 'TOC';
                            
                            %comput
                            win1 = round(d.array(ntrial).info('rt')*512);
                            win2 = win1 + 1536;
                            
                            u = d.array(ntrial).values{1}(win1:win2,nelec);
                            ubl = d.array(ntrial).values{1}(:,nelec);
                            
                            
                            movingwin = [0.5 0.05];
                            params = struct('tapers',[3 5],'pad',1,'Fs',d.array(ntrial).Fs,'fpass',[3 100],'trialave',0);
                            [S,t,f] = mtspecgramc(u,movingwin,params);
                            [Sbl,tbl,fbl] = mtspecgramc(ubl,movingwin,params);
                            
                            for nfreq = 1:size(f,2)
                                for nbin = 1:size(t,2)
                                    Snorm1(nbin,nfreq) = 10*log10(S(nbin,nfreq));
                                    Snorm1bl(nbin,nfreq) = 10*log10(Sbl(nbin,nfreq));
                                end
                            end
                            clear nfreq nbin S Sbl u ubl
                            
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
                            clear tlim1bl tlim2bl nfreq bl nbin Snorm1 Snorm1bl
                            
                            tlim1 = find(t(1,:)>=1.75,1);
                            tlim2 = find(t(1,:)>=2.5,1);
                            
                            flim1 = find(f(1,:)>=25,1);
                            flim2 = find(f(1,:)>=35,1);
                            
%                             flim3 = find(f(1,:)>=55);
%                             flim4 = find(f(1,:)>=80);
                            
                            %Snorm(:,flim2(1):flim3(1)) = NaN;
                            
                            pow(1)=nanmean(nanmean(Snorm(tlim1:tlim2,flim1+1:flim2)));
                            
                            if isempty(cond{1})
                                continue;
                            else
                                thevalue = [patient{nindiv} ' ' elec{1} ' ' emo{1} ' ' treat{1} ' ' hemi{1} ' ' num2str(rt(1)) ' ' num2str(pow(1))];
                                fprintf(fid,'%s\n',thevalue);
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
clear nindiv boucle patient

fclose(fid);