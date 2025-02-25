function [varargout] = Update_Struct_TrialName(varargin)

%REMOVEBADTRIALS Update the input structures by matching the trials shared 
% by all input structures.
% 
% varargin : structures to update
% varargout : updated structures
% 


for i = 1 : nargin
    eval(['struct_in = varargin{' num2str(i) '};'])
    if isfield(struct_in.Trial(1),'TrialName') && ~iscell(struct_in.Trial(1).TrialName)
        list_struct = arrayfun(@(i) upper(struct_in.Trial(i).TrialName),1:length(struct_in.Trial),'uni',0);
    elseif isfield(struct_in.Trial(1),'TrialName') && iscell(struct_in.Trial(1).TrialName)
        list_struct = arrayfun(@(i) upper(struct_in.Trial(i).TrialName{1}),1:length(struct_in.Trial),'uni',0);
    else
        champs = fieldnames(struct_in.Trial(1));
        ind = find(arrayfun(@(i) isa(struct_in.Trial(1).(champs{i}),'Signal'),1:length(champs)),1);
        list_struct = arrayfun(@(i) upper(struct_in.Trial(i).(champs{ind}).TrialName),1:length(struct_in.Trial),'uni',0);
    end
    eval(['list_struct' num2str(i) ' = list_struct;'])
    
end

list_good = list_struct1;
for i = 2 : nargin
    eval(['ind_good = matchcells(list_good,list_struct' num2str(i) ');'])
    list_good = list_good(ind_good);
end

for i = 1 : nargin
    eval(['struct_in = varargin{' num2str(i) '};'])
    eval(['list_struct = list_struct' num2str(i) ';'])
    ind_good = matchcells(list_struct,list_good);
    ind_bad = setdiff(1:length(struct_in.Trial),ind_good);
    struct_out = struct_in;
    struct_out.Trial = struct_in.Trial(ind_good);
    struct_out.removedTrials = struct_in.Trial(ind_bad);
    eval(['varargout{' num2str(i) '} = struct_out;'])
end

end


