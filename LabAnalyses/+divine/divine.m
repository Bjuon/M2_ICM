classdef divine < metadata.Trial
    properties
        
        patient       % recodrind ID
        medication    % medication: ON, OFF, TRANS
        run           % run of the task + condition
        nTrial        % trial number of the run
        task          % vgrasp or rgrasp
        condition     % coin, token or nothing
        isValid       % is trial valid?
        isBslValid    % is baseline long enough > 0.5s
        quality       % if good : 1, if presence of artefact during trial : 0
        MovieQuality  % is artefact during movie or patient's mouvement
        BslQuality    % is artefact during baseline
    end
    
    properties(SetAccess=protected)
        version = '0.1.0'
    end
    
    methods
        function self = divine(varargin)
            self = self@metadata.Trial;
            p = inputParser;
            p.KeepUnmatched= true;
            p.FunctionName = 'divine constructor';
            p.addParameter('patient',[],@(x) ischar(x));
            p.addParameter('medication',[],@(x) ischar(x));
            p.addParameter('run',[],@(x) isscalar(x));
            p.addParameter('nTrial',[],@(x) isscalar(x));
            p.addParameter('task',[],@(x) ischar(x));
            p.addParameter('condition',[],@(x) ischar(x));
            p.addParameter('isValid',[],@(x) isscalar(x));
            p.addParameter('isBslValid',[],@(x) isscalar(x));
            p.addParameter('quality',[],@(x) isscalar(x));
            p.addParameter('MovieQuality',[],@(x) isscalar(x));
            p.addParameter('BslQuality',[],@(x) isscalar(x));
            p.parse(varargin{:});
            par = p.Results;
            
            self.patient        = par.patient;
            self.medication     = par.medication;
            self.run            = par.run;
            self.nTrial         = par.nTrial;
            self.task           = par.task;
            self.condition      = par.condition;
            self.isValid        = par.isValid;
            self.isBslValid     = par.isBslValid;
            self.quality        = par.quality;
            self.MovieQuality   = par.MovieQuality;
            self.BslQuality     = par.BslQuality;
            
        end
    end
end