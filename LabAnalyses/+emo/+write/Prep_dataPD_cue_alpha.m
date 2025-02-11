addpath(genpath('/Volumes/Ennanne2/LFP_Emo/PARK/paradigm/Ascript/LabTools'))
rmpath('/Volumes/Ennanne2/LFP_Emo/PARK/paradigm/Ascript/LabTools/Fieldtrip/external/signal/dpss_hack/')  

cd('/Volumes/Ennanne2/LFP_Emo/PARK/paradigm')
boucle = dir('/Volumes/Ennanne2/LFP_Emo/PARK/paradigm/*PRETF.mat');

for nfile = 1:numel(boucle)
    prepatient{nfile} = boucle(nfile).name(1:5);
end
clear nfile

patient = unique(prepatient);
clear prepatient

treat {1}='OFF';
treat {2}='ON';

fid = fopen('/Volumes/Ennanne2/LFP_Emo/R_2018bis/dataPK_cue_alpha.txt','w');
fprintf(fid,'%s\n','Subject Elec Emo Cond Treat Hemi Power');

for nindiv = 1:numel(patient)
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
                        elec{1} = s(ntrial).labels{nelec}(1:2);
                        
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
                            if strcmp(s(ntrial).labels{nelec}(3),'D')
                                hemi{1}='D';
                            else
                                hemi{1}='G';
                            end
                            
                            % rt arousal valence
                            %rt(1)=s(ntrial).info('rt');
                            %arousal(1)=s(ntrial).info('arousal');
                            %valence(1)=s(ntrial).info('valence');
                            
                            % localisation
%                             goodpatient = find(strcmp(Coord_PK.names,patient{nindiv}(1:3)) & strcmp(Coord_PK.dipoles,elec{1}) & strcmp(Coord_PK.side,hemi{1}) & strcmp(Coord_PK.coord,'STN'));
%                             X = Coord_PK.X(goodpatient);
%                             Y = Coord_PK.Y(goodpatient);
%                             Z = Coord_PK.Z(goodpatient);
                            
                            %goodpatient = find(strcmp(name,patient{nindiv}(1:3)));
                            %for i=1:numel(goodpatient);
                            %namelec{i,1} = CoordNorm_PK{goodpatient(i)}.elec;
                            %end
                            %clear i
                            %goodelec = find(strcmp(elec,namelec));
                            %X = CoordNorm_PK{goodpatient(1)+goodelec-1}.X;
                            %Y = CoordNorm_PK{goodpatient(1)+goodelec-1}.Y;
                            %Z = CoordNorm_PK{goodpatient(1)+goodelec-1}.Z;
                            %ML = CoordNorm_PK{goodpatient(1)+goodelec-1}.ML;
                            %AP = CoordNorm_PK{goodpatient(1)+goodelec-1}.AP;
                            %DV = CoordNorm_PK{goodpatient(1)+goodelec-1}.DV;
                            %clear goodpatient goodelec namelec
                            
                            %comput spectrogram
                            u = s(ntrial).values{1}(:,nelec);
                            
                            movingwin = [0.5 0.05];
                            params = struct('tapers',[3 5],'pad',1,'Fs',s(ntrial).Fs,'fpass',[3 100],'trialave',0);
                            [S,t,f] = mtspecgramc(u,movingwin,params);
                            
                            % define bl timing
                            tlim1bl = find(t>0.3);
                            tlim2bl = find(t<0.8);
                            
                            % normalize applying log10 transformation
                            for nfreq = 1:size(f,2)
                                for nbin = 1:size(t,2)
                                    Snorm1(nbin,nfreq) = 10*log10(S(nbin,nfreq));
                                end
                            end
                            clear nfreq nbin
                            
                            % baseline correction
                            for nfreq = 1:size(f,2)
                                bl(nfreq)=nanmean(Snorm1(tlim1bl(1):tlim2bl(end),nfreq));
                                for nbin = 1:size(t,2)
                                    Snorm(nbin,nfreq) = Snorm1(nbin,nfreq)-bl(nfreq);
                                    if ~isreal(Snorm(nbin,nfreq))
                                        Snorm(nbin,nfreq) = NaN;
                                    end
                                end
                            end
                            clear nfreq bl nbin
                            
                            tlim1 = find(t(1,:)>=1,1);
                            tlim2 = find(t(1,:)>1.75,1);
                            
                            flim1 = find(f(1,:)>=8,1);
                            flim2 = find(f(1,:)>=12,1);
                            
%                             flim3 = find(f(1,:)>=45);
%                             flim4 = find(f(1,:)>=80);
                            
                            %Snormcut(:,flim2(1):flim3(1)) = NaN;
                            pow(1)=nanmean(nanmean(Snorm(tlim1:tlim2,flim1+1:flim2)));
                            
                            if isempty(cond{1})
                                continue;
                            else
                                thevalue = [patient{nindiv} ' ' elec{1} ' ' emo{1} ' ' cond{1} ' ' treat{ntreat} ' ' hemi{1} ' ' num2str(pow(1))];
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
    clear ntreat
end
clear nindiv boucle patient treat

fclose(fid);