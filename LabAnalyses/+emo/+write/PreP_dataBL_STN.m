cd('/Volumes/Ennanne2/LFP_Emo/R_2018bis')

boucle = dir('/Volumes/Ennanne2/LFP_Emo/PARK/seatedbaseline/*WINPSD.mat');

fid = fopen('data_WINPSD_STN3.txt','w');
fprintf(fid,'%s\n','Subject Elec Theta Alpha Betalow Betahigh Gamma Patho Hemi Treat');

for nfile = 1:numel(boucle)
    
    i = findstr(boucle(nfile).name,'_');
    if numel(i)<=1
        continue
    else
        load([boucle(nfile).folder '/' boucle(nfile).name]);
    end
    
    Subject  = boucle(nfile).name(1:3);
    Treat    = boucle(nfile).name(i(end-1)+1:i(end)-1);
    Patho    = 'PD';
    
    for nelec = 1:6
        
        if strcmp(Subject,'BEN') && (nelec==4 || nelec==5 || nelec==6)
            continue
        else
            
            % Elec
            if nelec == 1 || nelec == 4
                Elec = '01';
            elseif nelec == 2 || nelec == 5
                Elec = '12';
            elseif nelec == 3 || nelec == 6
                Elec = '23';
            end
            
            % Hemi
            if nelec <= 3
                Hemi = 'D';
            else
                Hemi = 'G';
            end
                        
            % Power
            n1  = find(F>=3,1);
            n2  = find(F>=8,1);
            Theta = nanmean(meanPlognorm(n1:n2,nelec));
            n4  = find(F>=12,1);
            Alpha = nanmean(meanPlognorm(n2+1:n4,nelec));
            n6  = find(F>=25,1);
            Betalow = nanmean(meanPlognorm(n4+1:n6,nelec));
            n6bis  = find(F>=35,1);
            Betahigh = nanmean(meanPlognorm(n6+1:n6bis,nelec));
            n7  = find(F>=40,1);
            n8  = find(F>=47,1);
            n9  = find(F>=53,1);
            n10 = find(F>=80,1);
            Gamma = nanmean([meanPlognorm(n7:n8,nelec); meanPlognorm(n9:n10,nelec)]);
            
            thevalue = [Subject ' ' Elec ' ' num2str(Theta) ' ' num2str(Alpha) ' ' num2str(Betalow) ' ' num2str(Betahigh) ' ' num2str(Gamma) ' ' Patho ' ' Hemi ' ' Treat];
            fprintf(fid,'%s\n',thevalue);
        end
        clearvars -except boucle fid nelec nfile Patho Treat Subject F meanPlognorm
    end
    clearvars -except boucle fid nfile
end
fclose(fid);


%%
cd('/Volumes/Ennanne2/LFP_Emo/R_2018bis')

boucle = dir('/Volumes/Ennanne2/LFP_Emo/TOC/STN/seatedbaseline/*WINPSD.mat');

fid = fopen('data_WINPSD_STN3.txt','a');
%fprintf(fid,'%s\n','Subject Elec Theta Alpha Beta Gamma Patho Hemi Treat');

for nfile = 1:numel(boucle)
    
    i = findstr(boucle(nfile).name,'_');
    if numel(i)<=1
        continue
    else
        load([boucle(nfile).folder '/' boucle(nfile).name]);
    end
    
    Subject  = boucle(nfile).name(1:3);
    %Treat    = boucle(nfile).name(i(end-1)+1:i(end)-1);
    Treat    = 'TOC';
    Patho    = 'TOC';
    
    for nelec = 1:6
        
        if strcmp(Subject,'BEN') && (nelec==4 || nelec==5 || nelec==6)
            continue
        else
            
            % Elec
            if nelec == 1 || nelec == 4
                Elec = '01';
            elseif nelec == 2 || nelec == 5
                Elec = '12';
            elseif nelec == 3 || nelec == 6
                Elec = '23';
            end
            
            % Hemi
            if nelec <= 3
                Hemi = 'D';
            else
                Hemi = 'G';
            end
                        
            % Power
            n1  = find(F>=3,1);
            n2  = find(F>=8,1);
            Theta = nanmean(meanPlognorm(n1:n2,nelec));
            n4  = find(F>=12,1);
            Alpha = nanmean(meanPlognorm(n2+1:n4,nelec));
            n6  = find(F>=25,1);
            Betalow = nanmean(meanPlognorm(n4+1:n6,nelec));
            n6bis  = find(F>=35,1);
            Betahigh = nanmean(meanPlognorm(n6+1:n6bis,nelec));
            n7  = find(F>=40,1);
            n8  = find(F>=47,1);
            n9  = find(F>=53,1);
            n10 = find(F>=80,1);
            Gamma = nanmean([meanPlognorm(n7:n8,nelec); meanPlognorm(n9:n10,nelec)]);
            
            thevalue = [Subject ' ' Elec ' ' num2str(Theta) ' ' num2str(Alpha) ' ' num2str(Betalow) ' ' num2str(Betahigh) ' ' num2str(Gamma) ' ' Patho ' ' Hemi ' ' Treat];
            fprintf(fid,'%s\n',thevalue);
        end
        clearvars -except boucle fid nelec nfile Patho Treat Subject F meanPlognorm
    end
    clearvars -except boucle fid nfile
end
fclose(fid);


