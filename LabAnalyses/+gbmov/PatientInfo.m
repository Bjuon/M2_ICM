classdef PatientInfo < handle
   properties
      path
      clinicFile
      locFile
      clinicInfo
      locInfo
   end
   properties(Dependent)
      n
      patient
   end
   
   methods
      function self = PatientInfo(varargin)
         p = inputParser;
         p.KeepUnmatched= false;
         p.FunctionName = 'PatientInfo constructor';
         p.addParameter('path','/Volumes/Data/Human/STN',@ischar);
         p.addParameter('clinicFile','PatientInfo.xlsx',@ischar);
         p.addParameter('locFile','coordinatesInterPlots.txt',@ischar);
         p.parse(varargin{:});
         par = p.Results;
         
         self.path = par.path;
         self.clinicFile = par.clinicFile;
         self.locFile = par.locFile;

         self.load();
      end
      
      function set.clinicFile(self,clinicFile)
         if exist(fullfile(self.path,self.clinicFile),'file')
            self.clinicFile = clinicFile;
         else
            error('clinicFile does not exist');
         end
      end
      
      function set.locFile(self,locFile)
         if exist(fullfile(self.path,self.locFile),'file')
            self.locFile = locFile;
         else
            error('locFile does not exist');
         end
      end
      
      function n = get.n(self)
         n = numel(self.clinicInfo);
      end
      
      function patient = get.patient(self)
         patient = {self.clinicInfo.PATIENTID}';
      end
      
      function self = load(self)
         if ~isempty(self.clinicFile)
            self.clinicInfo = self.readClinicFile(fullfile(self.path,self.clinicFile));
            
            %% Adjust UPDRSIV
            
            %% Adjust AXIAL
         end
         if ~isempty(self.locFile)
            self.locInfo = self.readLocFile(fullfile(self.path,self.locFile));
         end
      end
      
      function info = info(self,patient)
         ind = getPatientIndex(self,patient);
         info = self.clinicInfo(ind);
      end
      
      function [x,y,z] = loc(self,patient,coord,dipole,side)
         if nargin == 4
            assert(numel(dipole)==3,'Three inputs requires the side to be specified along with contacts, e.g., ''01D''');
            temp = dipole;
            dipole = temp(1:end-1);
            side = temp(end);
         end
         
         patient = self.mapid(patient);

         ind = strncmpi(patient,self.locInfo.patients,numel(patient)) ...
            & strcmpi(self.locInfo.coords,coord) & strcmpi(self.locInfo.dipoles,dipole) ...
            & strcmpi(self.locInfo.sides,side);
         
         if sum(ind) == 1
            x = self.locInfo.X(ind);
            y = self.locInfo.Y(ind);
            z = self.locInfo.Z(ind);
         else
            x = NaN;
            y = NaN;
            z = NaN;
         end
      end
      
      function out = therapeutic(self,patient)
         temp = info(self,patient);
         dipoles = {'01' '12' '23'};
         
         side = [temp.C0D temp.C1D temp.C2D temp.C3D];
         side = find(side == 1) - 1;
         ind = [];
         for i = 1:numel(side)
            ind = cat(1,ind,cellfun(@(x) length(strfind(x,num2str(side(i)))>0),dipoles));
         end
         side = dipoles(sum(ind,1)>0);
         right = cellfun(@(x) [x 'D'],side,'uni',0);
         
         side = [temp.C0G temp.C1G temp.C2G temp.C3G];
         side = find(side == 1) - 1;
         ind = [];
         for i = 1:numel(side)
            ind = cat(1,ind,cellfun(@(x) length(strfind(x,num2str(side(i)))>0),dipoles));
         end
         side = dipoles(sum(ind,1)>0);
         left = cellfun(@(x) [x 'G'],side,'uni',0);
         
         out = cat(2,right,left);
      end
      
      % Return index matching patient (in our naming scheme)
      function ind = getPatientIndex(self,patient)
         ind = strncmpi({self.clinicInfo.PATIENTID},patient,length(patient));
         if sum(ind) == 1
            % pass, or find(ind)
         elseif sum(ind) > 1
            temp = self.patient;
            cellfun(@(x) disp(x),temp(ind));
            error('Non-unique id, provide enough of the id for a unique match');
         else
            error('ID not found');
         end
      end
      
      % Map our naming scheme to Sara's naming scheme
      function id = mapid(self,patient)
         ind = getPatientIndex(self,patient);
         temp = {self.clinicInfo.PATIENTID2}';
         id = temp{ind};
      end
      
      function [n,fname] = hasTask(self,patient,task,cond)
          d = dir([self.path filesep '*.mat']);
          matchPatient = contains({d.name},patient,'IgnoreCase',true);
          matchTask = contains({d.name},task,'IgnoreCase',true);
          matchCond = contains({d.name},cond,'IgnoreCase',true);
          
          ind = matchPatient&matchTask&matchCond;
          n = sum(ind);
          if n == 0
              fname = '';
          else
              fname  = d(ind).name;
          end
      end
   end

   methods(Static)
      % Read in data from PatientInfo.xlsx
      function info = readClinicFile(fname)
         [~,~,RAW] = xlsread(fname);
         labels = RAW(1,:);
         RAW(1,:) = [];
         n = size(RAW,1);
         for i = 1:numel(labels)
            ind = (strcmp(RAW(:,i),'#DIV/0!')) | (strcmp(RAW(:,i),'ActiveX VT_ERROR: '));
            RAW(ind,i)={Inf};
            ind = strcmp(RAW(:,i),'#VALUE!') | strcmp(RAW(:,i),'');
            RAW(ind,i)={NaN};
            
            if strcmp(labels{i},'EXTRALINES')
               temp = RAW(:,strcmp(labels,'EXTRALINES'));
               for k = 1:numel(temp)
                  if all(isnan(temp{k}))
                     temp{k} = [];
                  else
                     temp2 = strsplit(temp{k},'-');
                     temp{k} = cellfun(@(x) str2num(x),temp2);
                  end
               end
               
               [info(1:n).(labels{i})] = deal(temp{:});
            else
               % Assign raw values
               [info(1:n).(labels{i})] = deal(RAW{:,i});
            end
         end
      end
      
      % Read in data from Sara's coordinatesInterPlotst.txt
      function info = readLocFile(fname)
         text = [];
         fid = fopen(fname);
         text = {};
         while 1
            tline = fgetl(fid);
            if ~ischar(tline)
               fclose(fid);
               break;
            else
               text = cat(1,text,tline);
            end
         end
         
         patients = {};
         sides = {};
         coords = {};
         dipoles = {};
         for i = 1:numel(text)
            temp = strsplit(text{i});
            temp2 = strsplit(temp{2},'_');
            patients{i,1} = temp2{end};
            
            if numel(strfind(lower(temp{3}),'_rh_')) == 1
               sides{i,1} = 'D';
            elseif numel(strfind(lower(temp{3}),'_lh_')) == 1
               sides{i,1} = 'G';
            else
               error(' missing side information');
            end
%             if numel(strfind(temp{3},'_RH_')) == 1
%                sides{i,1} = 'D';
%             elseif numel(strfind(temp{3},'_LH_')) == 1
%                sides{i,1} = 'G';
%             else
%                error(' missing side information');
%             end
            temp2 = strsplit(temp{3},'_');
            
            try
               dipoles{i,1} = [temp2{end}(1) temp2{end}(3)];
            catch
               dipoles{i,1} = [temp2{end}(1)];
            end
            
            if strcmp(temp{4}(1),'A')
               coords{i,1} = 'ACPC';
            else
               coords{i,1} = 'STN';
            end
            
            X(i,1) = str2num(temp{6}(2:end));
            Y(i,1) = str2num(temp{8}(2:end));
            Z(i,1) = str2num(temp{10}(2:end));
         end
         
         info.patients = patients;
         info.coords = coords;
         info.sides = sides;
         info.dipoles = dipoles;
         info.X = X;
         info.Y = Y;
         info.Z = Z;
      end
   end
   
end