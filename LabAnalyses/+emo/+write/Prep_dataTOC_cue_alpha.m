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

fid = fopen([savedir filesep 'dataTOC_cue_alpha.txt'],'w');
fprintf(fid,'%s\n','Subject Elec Emo Cond Hemi Treat Power');

% load Coord_OCD_tot.mat
% load CoordNorm_OCD.mat
% for ncoord = 1:numel(CoordNorm_OCD);
%     name{ncoord,1} = CoordNorm_OCD{ncoord}.name;
% end
% clear ncoord

for nindiv = 1:numel(patient)

    filename=[patient{nindiv} '_PRETF.mat'];
    load(filename)
    
    if strcmp(patient{nindiv},'SALSo')
        for ntrial = 1:numel(s)
            s(ntrial).quality(5:6) = 0;
        end
    elseif strcmp(patient{nindiv},'BENKa')
        for ntrial = 1:numel(s)
            s(ntrial).quality(4:6) = 0;
        end
    end
    clear ntrial
    
    for nelec = 1:6
        if ~s(1).quality(nelec) == 1
            continue
        else
            for ntrial = 1:numel(s)
                
                % verification artefact
                if s(ntrial).info('manureject')==1
                    continue
                else
                    % elec
                    elec{1} =  s(ntrial).labels(nelec).name(1:2);
                    
                    if ~strcmp(s(ntrial).info('bloc'),'pleasant') && ~strcmp(s(ntrial).info('bloc'),'unpleasant')
                        continue;
                    else
                        % emo
                        if strcmp(s(ntrial).info('im'),'neu') && strcmp(s(ntrial).info('bloc'),'pleasant')
                            emo{1} = 'neupos';
                        elseif strcmp(s(ntrial).info('im'),'neu') && strcmp(s(ntrial).info('bloc'),'unpleasant')
                            emo{1} = 'neuneg';
                        else
                            emo(1) = s(ntrial).info('im');
                        end
                        
                        % cond
                        if strcmp(s(ntrial).info('cond'),'passif')
                            cond(1) = s(ntrial).info('cond');
                        elseif (strcmp(s(ntrial).info('cond'),'go') && strcmp(s(ntrial).info('im'),'neg') && s(ntrial).info('response')==1 && s(ntrial).info('rt')>0 && s(ntrial).info('rt')<2) ...
                                || (strcmp(s(ntrial).info('cond'),'go') && strcmp(s(ntrial).info('im'),'pos') && s(ntrial).info('response')==1 && s(ntrial).info('rt')>0 && s(ntrial).info('rt')<2)...
                                || (strcmp(s(ntrial).info('cond'),'nogo') && strcmp(s(ntrial).info('im'),'neu') && s(ntrial).info('response')==1 && s(ntrial).info('rt')>0 && s(ntrial).info('rt')<2)
                            cond{1} = 'mot';
                        elseif (strcmp(s(ntrial).info('cond'),'nogo') && strcmp(s(ntrial).info('im'),'neg') && s(ntrial).info('response')==0) ...
                                || (strcmp(s(ntrial).info('cond'),'nogo') && strcmp(s(ntrial).info('im'),'pos') && s(ntrial).info('response')==0)...
                                || (strcmp(s(ntrial).info('cond'),'go') && strcmp(s(ntrial).info('im'),'neu') && s(ntrial).info('response')==0)
                            cond{1} = 'nonmot';
                        else
                            cond{1} = '';
                        end
                        
                        % hemi
                        if strcmp(s(ntrial).labels(nelec).name(3),'D')
                            hemi{1}='D';
                        else
                            hemi{1}='G';
                        end
                        
                        % treat
                        treat{1} = 'TOC';
                        
                        %comput
                        u = s(ntrial).values{1}(:,nelec);
                        
                        movingwin = [0.5 0.05];
                        params = struct('tapers',[3 5],'pad',1,'Fs',s(ntrial).Fs,'fpass',[3 100],'trialave',0);
                        [S,t,f] = mtspecgramc(u,movingwin,params);
                        
                        tlim1bl = find(t>0.3);
                        tlim2bl = find(t<0.8);
                        
                        for nfreq = 1:size(f,2)
                            for nbin = 1:size(t,2)
                                Snorm1(nbin,nfreq) = 10*log10(S(nbin,nfreq));
                            end
                        end
                        clear nfreq nbin S
                        
                        for nfreq = 1:size(f,2)
                            bl(nfreq)=nanmean(Snorm1(tlim1bl(1):tlim2bl(end),nfreq));
                            for nbin = 1:size(t,2)
                                Snorm(nbin,nfreq) = Snorm1(nbin,nfreq)-bl(nfreq);
                                if ~isreal(Snorm(nbin,nfreq))
                                    Snorm(nbin,nfreq) = NaN;
                                end
                            end
                        end
                        clear nfreq bl nbin Snorm1
                        
                        tlim1 = find(t(1,:)>=1,1);
                        tlim2 = find(t(1,:)>=1.75,1);
                        
                        flim1 = find(f(1,:)>=8,1);
                        flim2 = find(f(1,:)>=12,1);
                        
%                         flim3 = find(f(1,:)>=55);
%                         flim4 = find(f(1,:)>=80);
%                         Snorm(:,flim2(1):flim3(1))=NaN;
                        
                        pow(1)=nanmean(nanmean(Snorm(tlim1:tlim2,flim1+1:flim2)));
                        
                        if isempty(cond{1})
                            continue;
                        else
                            thevalue = [patient{nindiv} ' ' elec{1} ' ' emo{1} ' ' cond{1} ' ' hemi{1} ' ' treat{1} ' ' num2str(pow(1))];
                            fprintf(fid,'%s\n',thevalue);
                        end
                    end
                end
                clear elec cond hemi u movingwin params S t f tlim1bl tlim2bl Snorm tlim1 tlim2 flim1 flim2 pow thevalue
            end
            clear ntrial
        end
    end
    clear nelec s
end
clear nindiv boucle patient

fclose(fid);