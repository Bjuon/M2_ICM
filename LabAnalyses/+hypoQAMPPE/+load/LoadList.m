function [ClinicalData, OFF_list, ON_list] = LoadList(varargin)
    
    warning("off",'MATLAB:InputParser:ArgumentFailedValidation')
        
    if ~nargin
        Projet = 'hQ_Spectrum' ;
    else 
        Projet = varargin{1};
    end
    
    % Paths
    if strcmp(getenv('COMPUTERNAME'),'UMR-LAU-WP011')
        startpath = 'C:\LustreSync\hypoQAMPPE';
    elseif ispc
        startpath = '';
    elseif isunix
        startpath = '';
    end
    
    %% Load Spectrum
    if strcmp(Projet,'hQ_Spectrum')
        ClinicalData.Old = readtable([startpath filesep 'PatientInfo.xlsx']) ;  
        ClinicalData.New = readtable([startpath filesep 'PatientInfo2.xlsx']) ;  
        ClinicalData.Fusion = readtable([startpath filesep 'PatientInfo3.xlsx']) ;  
        list_of_file  = dir([startpath filesep 'Spectrum4']) ;
        list_of_name = {list_of_file.name} ;
        
        ON_list  = {};
        OFF_list = {};
        
        % For each .mat file in the folder
        for file = 1:length(list_of_name)
            if endsWith(list_of_name{file}, 'PSD.mat') && ~startsWith(list_of_name{file}, '.')
                clear PSD
                load([startpath filesep 'Spectrum4' filesep list_of_name{file}],'PSD')
                
                if contains(list_of_name{file},'_OFF_')
                    OFF_list{end+1} = PSD;
                elseif contains(list_of_name{file},'_ON_')
                    ON_list{end+1}  = PSD;
                else
                    fprintf(2,list_of_name{file})
                    error('Not ON or OFF patient...')
                end
            end
        end
    end

    warning("on",'MATLAB:InputParser:ArgumentFailedValidation')

end

