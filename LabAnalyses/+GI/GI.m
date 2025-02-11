classdef GI < metadata.Trial
    properties
        
        patient       % recodrind ID
        medication    % medication: ON, OFF, TRANS
        run           % run of the task + condition
        nTrial        % trial number of the run
        task          % here it's GI
        condition     % fast, spon or aispon
%         condition     % 1st step, steps, return, FOG
        segment       % 1st step, steps, return, FOG
        side          % left, right foot
        nStep         % number of step after APA
        isValid       % no button press during rest = 1, else 0 isRestValid?
        quality       % 1 if good : 1, if presence of artefact during trial : 0
        
    end
    
    properties(SetAccess=protected)
        version = '0.1.0'
    end
    
    methods
        function self = GI(varargin)
            self = self@metadata.Trial;
            p = inputParser;
            p.KeepUnmatched= true;
            p.FunctionName = 'Virtual Gait constructor';
            p.addParameter('patient',[],@(x) ischar(x));
            p.addParameter('medication',[],@(x) ischar(x));
            p.addParameter('run',[],@(x) isscalar(x));
            p.addParameter('nTrial',[],@(x) isscalar(x));
            p.addParameter('task',[],@(x) ischar(x));
            p.addParameter('condition',[],@(x) ischar(x));
            p.addParameter('segment',[],@(x) ischar(x));
            p.addParameter('side',[],@(x) ischar(x));
            p.addParameter('nStep',[],@(x) isscalar(x));
            p.addParameter('isValid',[],@(x) isscalar(x));
            p.addParameter('quality',[],@(x) isscalar(x));
            p.parse(varargin{:});
            par = p.Results;
            
            self.patient        = par.patient;
            self.medication     = par.medication;
            self.run            = par.run;
            self.nTrial         = par.nTrial;
            self.condition      = par.condition;
            self.side           = par.side;
            self.nStep          = par.nStep;
            self.isValid        = par.isValid;
            self.quality        = par.quality;
            
        end
    end
end