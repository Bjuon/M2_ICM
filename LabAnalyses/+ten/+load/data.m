function dat = data(fname)

if nargin == 0
   [NUM,TXT,RAW] = xlsread('10ansSurvie3_CLEAN19.xlsx');
else
   [NUM,TXT,RAW] = xlsread(fname);
end

id = RAW(3:end,1);
id = strrep(id,' ','');
id = strrep(id,'''','');

temp = strrep(id,'.V00','');
temp = strrep(temp,'.V01','');
temp = strrep(temp,'.V02','');
temp = strrep(temp,'.V03','');
temp = strrep(temp,'.V04','');

uid = unique(temp);

labels = RAW(1,:);
RAW(1,:) = [];
TXT(1,:) = [];
ranges = RAW(1,:);
RAW(1,:) = [];
TXT(1,:) = [];

shift = 2;

for i = 1:numel(uid)
   str = [uid{i} '.V00'];
   ind = strcmp(id,str);
   if sum(ind) == 1
      dat(i).id = uid{i};
      dat(i).age = RAW{ind,7+shift};
      dat(i).sex = RAW{ind,5+shift};
      % There is a problem with reading dates, both with month and year
      if isnumeric(RAW{ind,4+shift})
         temp = datevec(RAW{ind,4+shift});
         temp(1) = temp(1) + 1900;
         if temp(1) >= 2000
            temp(3) = temp(3) - 1;
         end
         dat(i).dob = datestr(temp,'dd/mm/yyyy');
      else
         dat(i).dob = '';
      end
      if isnumeric(RAW{ind,9+shift})
         temp = datevec(RAW{ind,9+shift});
         temp(1) = temp(1) + 1900;
         if temp(1) >= 2000
            temp(3) = temp(3) - 1;
         end
         dat(i).doi = datestr(temp,'dd/mm/yyyy');
      else
         dat(i).doi = '';
      end
      if shift > 0
         if isnumeric(RAW{ind,3})
            temp = datevec(RAW{ind,3});
            temp(1) = temp(1) + 1900;
            if temp(1) >= 2000
               temp(3) = temp(3) - 1;
            end
            dat(i).dolv = datestr(temp,'dd/mm/yyyy');
         elseif numel(strfind(RAW{ind,3},'/')) == 2
            dat(i).dolv = datestr(datenum(RAW{ind,3},'dd/mm/yyyy'),'dd/mm/yyyy');
         else
            dat(i).dolv = '';
         end
      end
      if isnumeric(RAW{ind,10+shift})
         temp = datevec(RAW{ind,10+shift});
         temp(1) = temp(1) + 1900;
         if temp(1) >= 2000
            temp(3) = temp(3) - 1;
         end
         try
         dat(i).dod = datestr(temp,'dd/mm/yyyy');
         catch, keyboard; end
         if strncmp(RAW{ind,11+shift},'POST',4)
            dat(i).deceased = true;
            dat(i).deceasedPost = true;
         else
            dat(i).deceased = true;
            dat(i).deceasedPost = false;
         end
         dat(i).causeOfDeath = RAW{ind,11+shift};
         if (~isempty(strfind(lower(dat(i).causeOfDeath),'park'))) ...
               || (~isempty(strfind(lower(dat(i).causeOfDeath),'fausse'))) ...
               || (~isempty(strfind(lower(dat(i).causeOfDeath),'occlusion'))) ...
               %|| (~isempty(strfind(lower(dat(i).causeOfDeath),'msa'))) ...
               %|| (~isempty(strfind(lower(dat(i).causeOfDeath),'?'))) ...
               %|| (~isempty(strfind(lower(dat(i).causeOfDeath),'subite'))) %
            dat(i).deceasedPark = true;
            dat(i).deceasedNonPark = false;
         else
            dat(i).deceasedPark = false;
            dat(i).deceasedNonPark = true;
         end
         dat(i).survival = between(datetime(dat(i).doi,'format','dd/MM/yyyy'),datetime(dat(i).dod,'format','dd/MM/yyyy'));
      else
         dat(i).dod = '';
         dat(i).deceased = false;
         dat(i).deceasedPost = false;
         dat(i).causeOfDeath = '';
         dat(i).deceasedPark = false;
         dat(i).deceasedNonPark = false;
         dat(i).survival = inf;
      end
      
      dat(i).ageCurrent = year(between(datetime(dat(i).dob,'format','dd/MM/yyyy'),datetime('now')));
      dat(i).ageAtIntervention = year(between(datetime(dat(i).dob,'format','dd/MM/yyyy'),datetime(dat(i).doi,'format','dd/MM/yyyy')));
      
      dat(i).ageDebut = RAW{ind,6+shift};
      dat(i).dureeEvolution = RAW{ind,8+shift};
      dat(i).dureeEvolution2 = dat(i).ageAtIntervention - dat(i).ageDebut;

      for j = 1:5
         str = [uid{i} '.V0' num2str(j-1)];
         ind = strcmp(id,str);
         if isnumeric(RAW{ind,12+shift})
            temp = datevec(RAW{ind,12+shift});
            temp(1) = temp(1) + 1900;
            if temp(1) >= 2000
               temp(3) = temp(3) - 1;
            end
            try
            dat(i).visit(j).date = datestr(temp,'dd/mm/yyyy');
            catch, keyboard; end
            temp = ...
               between(datetime(dat(i).doi,'format','dd/MM/yyyy'),datetime(dat(i).visit(j).date,'format','dd/MM/yyyy'));
            dat(i).visit(j).monthsReIntervention = calmonths(temp);
            dat(i).visit(j).valid = true;
            dat(i).visit(j).dropReason = '';
            
            dat(i).visit(j).dementia = iif(isnumeric(RAW{ind,13+shift}),RAW{ind,13+shift},NaN);
            dat(i).visit(j).hallucinations = iif(isnumeric(RAW{ind,14+shift}),RAW{ind,14+shift},NaN);
            dat(i).visit(j).apathy = iif(isnumeric(RAW{ind,15+shift}),RAW{ind,15+shift},NaN);
            dat(i).visit(j).updrsI = iif(isnumeric(RAW{ind,16+shift}),RAW{ind,16+shift},NaN);
            dat(i).visit(j).swallowingOff = iif(isnumeric(RAW{ind,17+shift}),RAW{ind,17+shift},NaN);
            dat(i).visit(j).fallsOff = iif(isnumeric(RAW{ind,18+shift}),RAW{ind,18+shift},NaN);
            dat(i).visit(j).freezingOff = iif(isnumeric(RAW{ind,19+shift}),RAW{ind,19+shift},NaN);
            dat(i).visit(j).marcheADLOff = iif(isnumeric(RAW{ind,20+shift}),RAW{ind,20+shift},NaN);
            dat(i).visit(j).updrsIIOff = iif(isnumeric(RAW{ind,21+shift}),RAW{ind,21+shift},NaN);
            dat(i).visit(j).swallowingOn = iif(isnumeric(RAW{ind,22+shift}),RAW{ind,22+shift},NaN);
            dat(i).visit(j).fallsOn = iif(isnumeric(RAW{ind,23+shift}),RAW{ind,23+shift},NaN);
            dat(i).visit(j).freezingOn = iif(isnumeric(RAW{ind,24+shift}),RAW{ind,24+shift},NaN);
            dat(i).visit(j).marcheADLOn = iif(isnumeric(RAW{ind,25+shift}),RAW{ind,25+shift},NaN);
            dat(i).visit(j).updrsIIOn = iif(isnumeric(RAW{ind,26+shift}),RAW{ind,26+shift},NaN);
            
            dat(i).visit(j).tremorOnSOffM = iif(isnumeric(RAW{ind,27+shift}),RAW{ind,27+shift},NaN);
            dat(i).visit(j).tremorOffSOffM = iif(isnumeric(RAW{ind,28+shift}),RAW{ind,28+shift},NaN);
            dat(i).visit(j).tremorOffSOnM = iif(isnumeric(RAW{ind,29+shift}),RAW{ind,29+shift},NaN);
            dat(i).visit(j).tremorOnSOnM = iif(isnumeric(RAW{ind,30+shift}),RAW{ind,30+shift},NaN);
            
            dat(i).visit(j).rigidityOnSOffM = iif(isnumeric(RAW{ind,31+shift}),RAW{ind,31+shift},NaN);
            dat(i).visit(j).rigidityOffSOffM = iif(isnumeric(RAW{ind,32+shift}),RAW{ind,32+shift},NaN);
            dat(i).visit(j).rigidityOffSOnM = iif(isnumeric(RAW{ind,33+shift}),RAW{ind,33+shift},NaN);
            dat(i).visit(j).rigidityOnSOnM = iif(isnumeric(RAW{ind,34+shift}),RAW{ind,34+shift},NaN);

            dat(i).visit(j).akinesiaOnSOffM = iif(isnumeric(RAW{ind,35+shift}),RAW{ind,35+shift},NaN);
            dat(i).visit(j).akinesiaOffSOffM = iif(isnumeric(RAW{ind,36+shift}),RAW{ind,36+shift},NaN);
            dat(i).visit(j).akinesiaOffSOnM = iif(isnumeric(RAW{ind,37+shift}),RAW{ind,37+shift},NaN);
            dat(i).visit(j).akinesiaOnSOnM = iif(isnumeric(RAW{ind,38+shift}),RAW{ind,38+shift},NaN);

            dat(i).visit(j).paroleOnSOffM = iif(isnumeric(RAW{ind,39+shift}),RAW{ind,39+shift},NaN);
            dat(i).visit(j).paroleOffSOffM = iif(isnumeric(RAW{ind,44+shift}),RAW{ind,44+shift},NaN);
            dat(i).visit(j).paroleOffSOnM = iif(isnumeric(RAW{ind,49+shift}),RAW{ind,49+shift},NaN);
            dat(i).visit(j).paroleOnSOnM = iif(isnumeric(RAW{ind,54+shift}),RAW{ind,54+shift},NaN);

            dat(i).visit(j).leverOnSOffM = iif(isnumeric(RAW{ind,40+shift}),RAW{ind,40+shift},NaN);
            dat(i).visit(j).leverOffSOffM = iif(isnumeric(RAW{ind,45+shift}),RAW{ind,45+shift},NaN);
            dat(i).visit(j).leverOffSOnM = iif(isnumeric(RAW{ind,50+shift}),RAW{ind,50+shift},NaN);
            dat(i).visit(j).leverOnSOnM = iif(isnumeric(RAW{ind,55+shift}),RAW{ind,55+shift},NaN);

            dat(i).visit(j).postureOnSOffM = iif(isnumeric(RAW{ind,41+shift}),RAW{ind,41+shift},NaN);
            dat(i).visit(j).postureOffSOffM = iif(isnumeric(RAW{ind,46+shift}),RAW{ind,46+shift},NaN);
            dat(i).visit(j).postureOffSOnM = iif(isnumeric(RAW{ind,51+shift}),RAW{ind,51+shift},NaN);
            dat(i).visit(j).postureOnSOnM = iif(isnumeric(RAW{ind,56+shift}),RAW{ind,56+shift},NaN);

            dat(i).visit(j).marcheOnSOffM = iif(isnumeric(RAW{ind,42+shift}),RAW{ind,42+shift},NaN);
            dat(i).visit(j).marcheOffSOffM = iif(isnumeric(RAW{ind,47+shift}),RAW{ind,47+shift},NaN);
            dat(i).visit(j).marcheOffSOnM = iif(isnumeric(RAW{ind,52+shift}),RAW{ind,52+shift},NaN);
            dat(i).visit(j).marcheOnSOnM = iif(isnumeric(RAW{ind,57+shift}),RAW{ind,57+shift},NaN);

            dat(i).visit(j).equilibreOnSOffM = iif(isnumeric(RAW{ind,43+shift}),RAW{ind,43+shift},NaN);
            dat(i).visit(j).equilibreOffSOffM = iif(isnumeric(RAW{ind,48+shift}),RAW{ind,48+shift},NaN);
            dat(i).visit(j).equilibreOffSOnM = iif(isnumeric(RAW{ind,53+shift}),RAW{ind,53+shift},NaN);
            dat(i).visit(j).equilibreOnSOnM = iif(isnumeric(RAW{ind,58+shift}),RAW{ind,58+shift},NaN);

            dat(i).visit(j).axeOnSOffM = iif(isnumeric(RAW{ind,59+shift}),RAW{ind,59+shift},NaN);
            dat(i).visit(j).axeOffSOffM = iif(isnumeric(RAW{ind,60+shift}),RAW{ind,60+shift},NaN);
            dat(i).visit(j).axeOffSOnM = iif(isnumeric(RAW{ind,61+shift}),RAW{ind,61+shift},NaN);
            dat(i).visit(j).axeOnSOnM = iif(isnumeric(RAW{ind,62+shift}),RAW{ind,62+shift},NaN);

            dat(i).visit(j).updrsIIIOnSOffM = iif(isnumeric(RAW{ind,63+shift}),RAW{ind,63+shift},NaN);
            dat(i).visit(j).updrsIIIOffSOffM = iif(isnumeric(RAW{ind,64+shift}),RAW{ind,64+shift},NaN);
            dat(i).visit(j).updrsIIIOffSOnM = iif(isnumeric(RAW{ind,65+shift}),RAW{ind,65+shift},NaN);
            dat(i).visit(j).updrsIIIOnSOnM = iif(isnumeric(RAW{ind,66+shift}),RAW{ind,66+shift},NaN);

            dat(i).visit(j).DSK = iif(isnumeric(RAW{ind,67+shift}),RAW{ind,67+shift},NaN);
            dat(i).visit(j).OFF = iif(isnumeric(RAW{ind,68+shift}),RAW{ind,68+shift},NaN);
            dat(i).visit(j).updrsIV = iif(isnumeric(RAW{ind,69+shift}),RAW{ind,69+shift},NaN);

            dat(i).visit(j).SEOff = iif(isnumeric(RAW{ind,70+shift}),RAW{ind,70+shift},NaN);
            dat(i).visit(j).SEOn = iif(isnumeric(RAW{ind,71+shift}),RAW{ind,71+shift},NaN);

            dat(i).visit(j).HYOff = iif(isnumeric(RAW{ind,72+shift}),RAW{ind,72+shift},NaN);
            dat(i).visit(j).HYOn = iif(isnumeric(RAW{ind,73+shift}),RAW{ind,73+shift},NaN);

            dat(i).visit(j).agonists = iif(isnumeric(RAW{ind,74+shift}),RAW{ind,74+shift},NaN);
            dat(i).visit(j).ldopa = iif(isnumeric(RAW{ind,75+shift}),RAW{ind,75+shift},NaN);
            dat(i).visit(j).ldopaEquiv = iif(isnumeric(RAW{ind,76+shift}),RAW{ind,76+shift},NaN);

            dat(i).visit(j).MMS = iif(isnumeric(RAW{ind,77+shift}),RAW{ind,77+shift},NaN);
            dat(i).visit(j).Mattis = iif(isnumeric(RAW{ind,78+shift}),RAW{ind,78+shift},NaN);
            dat(i).visit(j).attention = iif(isnumeric(RAW{ind,79+shift}),RAW{ind,79+shift},NaN);
            dat(i).visit(j).initiation = iif(isnumeric(RAW{ind,80+shift}),RAW{ind,80+shift},NaN);
            dat(i).visit(j).construction = iif(isnumeric(RAW{ind,81+shift}),RAW{ind,81+shift},NaN);
            dat(i).visit(j).concepts = iif(isnumeric(RAW{ind,82+shift}),RAW{ind,82+shift},NaN);
            dat(i).visit(j).memory = iif(isnumeric(RAW{ind,83+shift}),RAW{ind,83+shift},NaN);

            dat(i).visit(j).RLT = iif(isnumeric(RAW{ind,84+shift}),RAW{ind,84+shift},NaN);
            dat(i).visit(j).RT = iif(isnumeric(RAW{ind,85+shift}),RAW{ind,85+shift},NaN);
            dat(i).visit(j).RLD = iif(isnumeric(RAW{ind,86+shift}),RAW{ind,86+shift},NaN);
            dat(i).visit(j).RTD = iif(isnumeric(RAW{ind,87+shift}),RAW{ind,87+shift},NaN);
            dat(i).visit(j).reconnaissance = iif(isnumeric(RAW{ind,88+shift}),RAW{ind,88+shift},NaN);

            dat(i).visit(j).Wisconsin = iif(isnumeric(RAW{ind,89+shift}),RAW{ind,89+shift},NaN);
            dat(i).visit(j).criteria = iif(isnumeric(RAW{ind,90+shift}),RAW{ind,90+shift},NaN);
            dat(i).visit(j).errors = iif(isnumeric(RAW{ind,91+shift}),RAW{ind,91+shift},NaN);
            dat(i).visit(j).perseverations = iif(isnumeric(RAW{ind,92+shift}),RAW{ind,92+shift},NaN);
            dat(i).visit(j).abandons = iif(isnumeric(RAW{ind,93+shift}),RAW{ind,93+shift},NaN);

            dat(i).visit(j).recallLexical = iif(isnumeric(RAW{ind,94+shift}),RAW{ind,94+shift},NaN);
            dat(i).visit(j).recallCategorical = iif(isnumeric(RAW{ind,95+shift}),RAW{ind,95+shift},NaN);
            dat(i).visit(j).recallLiteral = iif(isnumeric(RAW{ind,96+shift}),RAW{ind,96+shift},NaN);

            dat(i).visit(j).sequenceGraphical = iif(isnumeric(RAW{ind,97+shift}),RAW{ind,97+shift},NaN);
            dat(i).visit(j).sequenceMotor = iif(isnumeric(RAW{ind,98+shift}),RAW{ind,98+shift},NaN);

            dat(i).visit(j).frontal50 = iif(isnumeric(RAW{ind,99+shift}),RAW{ind,99+shift},NaN);
            dat(i).visit(j).MADRS = iif(isnumeric(RAW{ind,100+shift}),RAW{ind,100+shift},NaN);
         else
            dat(i).visit(j).date =  '';
            dat(i).visit(j).monthsReIntervention = NaN;
            dat(i).visit(j).valid = false;
            dat(i).visit(j).dropReason = RAW{ind,12+shift};
            
            dat(i).visit(j).dementia = NaN;
            dat(i).visit(j).hallucinations = NaN;
            dat(i).visit(j).apathy = NaN;
            dat(i).visit(j).updrsI = NaN;
            dat(i).visit(j).swallowingOff = NaN;
            dat(i).visit(j).fallsOff = NaN;
            dat(i).visit(j).freezingOff = NaN;
            dat(i).visit(j).marcheADLOff = NaN;
            dat(i).visit(j).updrsIIOff = NaN;
            dat(i).visit(j).swallowingOn = NaN;
            dat(i).visit(j).fallsOn = NaN;
            dat(i).visit(j).freezingOn = NaN;
            dat(i).visit(j).marcheADLOn = NaN;
            dat(i).visit(j).updrsIIOn = NaN;
            
            dat(i).visit(j).tremorOnSOffM = NaN;
            dat(i).visit(j).tremorOffSOffM = NaN;
            dat(i).visit(j).tremorOffSOnM = NaN;
            dat(i).visit(j).tremorOnSOnM = NaN;
            
            dat(i).visit(j).rigidityOnSOffM = NaN;
            dat(i).visit(j).rigidityOffSOffM = NaN;
            dat(i).visit(j).rigidityOffSOnM = NaN;
            dat(i).visit(j).rigidityOnSOnM = NaN;

            dat(i).visit(j).akinesiaOnSOffM = NaN;
            dat(i).visit(j).akinesiaOffSOffM = NaN;
            dat(i).visit(j).akinesiaOffSOnM = NaN;
            dat(i).visit(j).akinesiaOnSOnM = NaN;

            dat(i).visit(j).paroleOnSOffM = NaN;
            dat(i).visit(j).paroleOffSOffM = NaN;
            dat(i).visit(j).paroleOffSOnM = NaN;
            dat(i).visit(j).paroleOnSOnM = NaN;

            dat(i).visit(j).leverOnSOffM = NaN;
            dat(i).visit(j).leverOffSOffM = NaN;
            dat(i).visit(j).leverOffSOnM = NaN;
            dat(i).visit(j).leverOnSOnM = NaN;

            dat(i).visit(j).postureOnSOffM = NaN;
            dat(i).visit(j).postureOffSOffM = NaN;
            dat(i).visit(j).postureOffSOnM = NaN;
            dat(i).visit(j).postureOnSOnM = NaN;

            dat(i).visit(j).marcheOnSOffM = NaN;
            dat(i).visit(j).marcheOffSOffM = NaN;
            dat(i).visit(j).marcheOffSOnM = NaN;
            dat(i).visit(j).marcheOnSOnM = NaN;

            dat(i).visit(j).equilibreOnSOffM = NaN;
            dat(i).visit(j).equilibreOffSOffM = NaN;
            dat(i).visit(j).equilibreOffSOnM = NaN;
            dat(i).visit(j).equilibreOnSOnM = NaN;

            dat(i).visit(j).axeOnSOffM = NaN;
            dat(i).visit(j).axeOffSOffM = NaN;
            dat(i).visit(j).axeOffSOnM = NaN;
            dat(i).visit(j).axeOnSOnM = NaN;

            dat(i).visit(j).updrsIIIOnSOffM = NaN;
            dat(i).visit(j).updrsIIIOffSOffM = NaN;
            dat(i).visit(j).updrsIIIOffSOnM = NaN;
            dat(i).visit(j).updrsIIIOnSOnM = NaN;

            dat(i).visit(j).DSK = NaN;
            dat(i).visit(j).OFF = NaN;
            dat(i).visit(j).updrsIV = NaN;

            dat(i).visit(j).SEOff = NaN;
            dat(i).visit(j).SEOn = NaN;

            dat(i).visit(j).HYOff = NaN;
            dat(i).visit(j).HYOn = NaN;

            dat(i).visit(j).agonists = NaN;
            dat(i).visit(j).ldopa = NaN;
            dat(i).visit(j).ldopaEquiv = NaN;

            dat(i).visit(j).MMS = NaN;
            dat(i).visit(j).Mattis = NaN; 
            dat(i).visit(j).attention = NaN;
            dat(i).visit(j).initiation = NaN;
            dat(i).visit(j).construction = NaN;
            dat(i).visit(j).concepts = NaN;
            dat(i).visit(j).memory = NaN;

            dat(i).visit(j).RLT = NaN;
            dat(i).visit(j).RT = NaN;
            dat(i).visit(j).RLD = NaN;
            dat(i).visit(j).RTD = NaN;
            dat(i).visit(j).reconnaissance = NaN;

            dat(i).visit(j).Wisconsin = NaN;
            dat(i).visit(j).criteria = NaN;
            dat(i).visit(j).errors = NaN;
            dat(i).visit(j).perseverations = NaN;
            dat(i).visit(j).abandons = NaN;

            dat(i).visit(j).recallLexical = NaN;
            dat(i).visit(j).recallCategorical = NaN;
            dat(i).visit(j).recallLiteral = NaN;

            dat(i).visit(j).sequenceGraphical = NaN;
            dat(i).visit(j).sequenceMotor = NaN;

            dat(i).visit(j).frontal50 = NaN;
            dat(i).visit(j).MADRS = NaN;
         end
      end
      
      %% determine censoring
      if shift == 0
         if dat(i).deceased || dat(i).deceasedPost % death
            dat(i).survival2 = calmonths(dat(i).survival);
         else
            %q = linq();
            indValid = find([dat(i).visit.valid]');
            if numel(indValid) == 0
               dat(i).survival2 = NaN;
            else
               vdate = {dat(i).visit.date}';
               drop = {dat(i).visit.dropReason}';
               if any(strncmpi(drop,'pdv',3)) % lost to followup
                  % censor at last visit
                  temp = between(datetime(dat(i).doi,'format','dd/MM/yyyy'),datetime(vdate{indValid(end)},'format','dd/MM/yyyy'));
                  dat(i).survival2 = calmonths(temp);
               else % patient alive, possibly missing data
                  %temp = between(datetime(dat(i).doi,'format','dd/MM/yyyy'),date);
                  temp = between(datetime(dat(i).doi,'format','dd/MM/yyyy'),'30-Sep-2015');
                  dat(i).survival2 = calmonths(temp);
               end
            end
         end
      else
         if dat(i).deceased || dat(i).deceasedPost % death
            dat(i).survival2 = calmonths(dat(i).survival);
         else
            indValid = find([dat(i).visit.valid]');
            if numel(indValid) == 0
               dat(i).survival2 = NaN;
            else
               temp = between(datetime(dat(i).doi,'format','dd/MM/yyyy'),datetime(dat(i).dolv,'format','dd/MM/yyyy'));
               dat(i).survival2 = calmonths(temp);
%                vdate = {dat(i).visit.date}';
%                drop = {dat(i).visit.dropReason}';
%                keyboard
%                if any(strncmpi(drop,'pdv',3)) % lost to followup
%                   % censor at last visit
%                   temp = between(datetime(dat(i).doi,'format','dd/MM/yyyy'),datetime(vdate{indValid(end)},'format','dd/MM/yyyy'));
%                   dat(i).survival2 = calmonths(temp);
%                else % patient alive, possibly missing data
%                   %temp = between(datetime(dat(i).doi,'format','dd/MM/yyyy'),date);
%                   temp = between(datetime(dat(i).doi,'format','dd/MM/yyyy'),'30-Sep-2015');
%                   dat(i).survival2 = calmonths(temp);
%                end
            end
         end
      end
      
      temp = num2str([dat(i).visit.valid]);
      temp = strrep(temp,' ','');
      dat(i).pattern = temp;
   else
      i
      str
   end
end

for i = 1:numel(dat)
   fprintf('%s - %g - %s\n',dat(i).pattern,dat(i).deceased,dat(i).id);
end

patterns = {dat.pattern}';
ind = strcmp(patterns,'00000');
%ind = strcmp(patterns,'00000') | strcmp(patterns,'00010');
dat(ind) = [];

deceased = [dat.deceased]';
patterns = {dat.pattern}';
upatterns = unique(patterns);
for i = 1:numel(upatterns)
   fprintf('%s : %g\t',upatterns{i},sum(deceased&strcmp(patterns,upatterns{i})));
   fprintf('%s : %g\n',upatterns{i},sum((~deceased)&strcmp(patterns,upatterns{i})));
end
fprintf('      : %g\t      : %g\n',sum(deceased),sum(~deceased));
