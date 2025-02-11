function batch_spikeana1_Stacie
% Input
%   - pathology : character array to identify the mat files containing the
%   dat structures (output from plxtomat, filename format should be
%   PatientID_Pathology_Side_Section_depth.mat)

pathology = {'PGD','DYT1','DYT11','DYTc'};

for npatho = 1:numel(pathology)
    boucle = dir(['*' pathology{npatho} '*.mat']);
    
    for nfile = 1:numel(boucle);
        load(boucle(nfile).name)
        import spk.*
        
        disp(boucle(nfile).name)
        
        nspk= numel (dat.spk);
        for indspk = 1:nspk
            
            cut_off = 0.500;  % in sec
            resol = 0.005; % in sec
            lim = 0.002; % in sec
            bw = 0.5; % in sec
            
            [p] = plx.spikeana1_AB(dat,indspk,cut_off,resol,lim,bw);
            
            indsec = strfind(boucle(nfile).name,'_');
            section = boucle(nfile).name(indsec(end-1)+1:indsec(end)-1);
            p.info('section') = section;
            p.info('pathology') = pathology{npatho};
            
            figname = [p.info('patient') '_' p.info('side') '_' section '_' num2str(p.info('depth'),3) '_' p.info('spkname') '.png'];
            g = gcf;
            print(g,'-dpng',figname);
            close;
            
            processname = [p.info('patient') '_' p.info('side') '_' section '_' num2str(p.info('depth'),3) '_' p.info('spkname') '.mat'];
            eval(['save ' processname ' p;'])
            
            clearvars -except boucle indspk nspk dat nfile pathology npatho
        end
    end
    clear boucle
end



