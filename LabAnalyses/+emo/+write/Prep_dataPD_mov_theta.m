addpath(genpath('/Volumes/Ennanne2/LFP_Emo/PARK/paradigm/Ascript/LabTools'))
rmpath('/Volumes/Ennanne2/LFP_Emo/PARK/paradigm/Ascript/LabTools/Fieldtrip/external/signal/dpss_hack/')

cd('/Volumes/Ennanne2/LFP_Emo/PARK/paradigm')
boucle = dir('*PRETF.mat');

for nfile = 1:numel(boucle)
    prepatient{nfile} = boucle(nfile).name(1:5);
end
clear nfile

patient = unique(prepatient);
clear prepatient

treat {1}='OFF';
treat {2}='ON';

fid = fopen('/Volumes/Ennanne2/LFP_Emo/R_2018bis/dataPK_mov_theta.txt','w');
fprintf(fid,'%s\n','Subject Elec Emo Treat Hemi RT Power');

%load Coord_PK_tot.mat
% load CoordNorm_PK.mat
% for ncoord = 1:numel(CoordNorm_PK);
%     name{ncoord,1} = CoordNorm_PK{ncoord}.name;
% end
% clear ncoord

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
                        elec{1} = d.array(ntrial).labels{nelec}(1:2);
                        
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
                                if strcmp(d.array(ntrial).labels{nelec}(3),'D')
                                    hemi{1}='D';
                                else
                                    hemi{1}='G';
                                end
                                
                                % rt arousal valence
                                rt(1)=d.array(ntrial).info('rt');
%                                 arousal(1)=d.array(ntrial).info('arousal');
%                                 valence(1)=d.array(ntrial).info('valence');
                                
                                % localisation
%                                 goodpatient = find(strcmp(Coord_PK.names,patient{nindiv}(1:3)) & strcmp(Coord_PK.dipoles,elec{1}) & strcmp(Coord_PK.side,hemi{1}) & strcmp(Coord_PK.coord,'STN'));
%                                 X = Coord_PK.X(goodpatient);
%                                 Y = Coord_PK.Y(goodpatient);
%                                 Z = Coord_PK.Z(goodpatient);
                                
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
                                
                                tlim1 = find(t(1,:)>=1.75,1);
                                tlim2 = find(t(1,:)>=2.5,1);
                                
                                flim1 = find(f(1,:)>=3,1);
                                flim2 = find(f(1,:)>=8,1);
                                
%                                 flim3 = find(f(1,:)>=55);
%                                 flim4 = find(f(1,:)>=80);
%                                Snorm(:,flim2(1):flim3(1))= NaN;
                                pow(1)=nanmean(nanmean(Snorm(tlim1:tlim2,flim1:flim2)));
                                
                                if isempty(cond{1})
                                    continue;
                                else
                                    thevalue = [patient{nindiv} ' ' elec{1} ' ' emo{1} ' ' treat{ntreat} ' ' hemi{1} ' ' num2str(rt(1)) ' ' num2str(pow(1))];
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
    clear ntreat
end
clear nindiv boucle patient treat

fclose(fid);