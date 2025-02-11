classdef VG < metadata.Trial
    properties
        
        patient       % recodrind ID
        medication    % medication: ON, OFF, TRANS
        run           % run of the task + condition
        nTrial        % trial number of the run
        condition     % marche or tapis
        speed         % speed of trial
        isRest        % resting time during the trial 
        isRestValid % no button press during rest = 1, else 0 isRestValid?
        isDoor        % door during the trial
        distDoor          % door position in milliseconds
        isGaitValid % no abortion during gait = 1, else 0 ou plutôt, isGaitValid?
        quality       % 1 if good : 1, if presence of artefact during trial : 0
        RestQuality       % 1 if good : 1, if presence of artefact during rest : 0
        GaitQuality       % 1 if good : 1, if presence of artefact during gait : 0
        DoorCond        % P=0, P=1, ...
%         task          % task of the protocol: Marche, tapis, etc...
%         instruction   % with or without door
%         trial         % 
%         obs           % door position
        
    end
    
    properties(SetAccess=protected)
        version = '0.1.0'
    end
    
    methods
        function self = VG(varargin)
            self = self@metadata.Trial;
            p = inputParser;
            p.KeepUnmatched= true;
            p.FunctionName = 'Virtual Gait constructor';
            p.addParameter('patient',[],@(x) ischar(x));
            p.addParameter('medication',[],@(x) ischar(x));
            p.addParameter('run',[],@(x) isscalar(x));
            p.addParameter('nTrial',[],@(x) isscalar(x));
            p.addParameter('condition',[],@(x) ischar(x));
            p.addParameter('speed',[],@(x) isnumeric(x));
            p.addParameter('isRest',[],@(x) isscalar(x));
            p.addParameter('isRestValid',[],@(x) isscalar(x));
            p.addParameter('isDoor',[],@(x) isscalar(x));
            p.addParameter('distDoor',[],@(x) isnumeric(x));
            p.addParameter('isGaitValid',[],@(x) isscalar(x));
            p.addParameter('quality',[],@(x) isscalar(x));
            p.addParameter('RestQuality',[],@(x) isscalar(x));
            p.addParameter('GaitQuality',[],@(x) isscalar(x));
            p.addParameter('DoorCond',[],@(x) ischar(x));
            p.parse(varargin{:});
            par = p.Results;
            
            self.patient        = par.patient;
            self.medication     = par.medication;
            self.run            = par.run;
            self.nTrial         = par.nTrial;
            self.condition      = par.condition;
            self.speed          = par.speed;
            self.isRest         = par.isRest;
            self.isRestValid    = par.isRestValid;
            self.isDoor         = par.isDoor;
            self.distDoor       = par.distDoor;
            self.isGaitValid    = par.isGaitValid;
            self.quality        = par.quality;
            self.RestQuality    = par.RestQuality;
            self.GaitQuality    = par.GaitQuality;
            self.DoorCond       = par.DoorCond;
            
        end
    end
end