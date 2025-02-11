%[~,~,RAW] = xlsread('/Users/brian/CloudStation/Work/Production/Papers/2019_PreSTOC2/Data/PreSTOC2_PostM14_resaved.xlsx');
[~,~,RAW] = xlsread('/Users/brian/ownCloud/2019_PreSTOC2/Data/PreSTOC2_PostM14_resaved4.xlsx');

varNames = RAW(2,:);

ind = RAW(:,2);
ind = cellfun(@(x) any(isnan(x)),ind);

RAW(ind,:) = [];

RAW(1,:) = [];


for i = 1:size(RAW,1)
   dat(i).Id = str2num(RAW{i,1}(2:end));
   dat(i).Arm = RAW{i,8};
   dat(i).Treatment = RAW{i,10};
   dat(i).Visit = RAW{i,2};
   dat(i).Period = RAW{i,3};
   dat(i).YBOCS = RAW{i,4};
   dat(i).YBOCS_OBSESSION = RAW{i,5};
   dat(i).YBOCS_COMPULSION = RAW{i,6};
   
   dat(i).Target = RAW{i,10};
   dat(i).Voltage = RAW{i,13};
end

tab = struct2table(dat);
tab = tab(~cellfun(@(x) all(isnan(x)),tab.YBOCS,'UniformOutput',1),:);
tab.Period=repmat('0',length(tab.Period),1);

writetable(tab,'data_extra4.csv')

%temp = cellfun(@(x) datestr(x2mdate(x),'mm/dd/yyyy'),RAW(:,8),'uni',false);

clear dat tab;
[~,~,RAW] = xlsread('/Users/brian/ownCloud/2019_PreSTOC2/Data/PreSTOC2_PostM14_resaved2.xlsx');

RAW(1:2,:) = [];


for i = 1:size(RAW,1)
   dat(i).Id = str2num(RAW{i,1}(2:end));
   dat(i).Treatment = RAW{i,10};
   dat(i).Visit = RAW{i,2};

   dat(i).Date = datestr(x2mdate(RAW{i,9}),'mm/dd/yyyy');
   %dat(i).ContactL = RAW{i,12};
   dat(i).FreqL = RAW{i,11};
   dat(i).AmpL = RAW{i,13};
   dat(i).PWL = RAW{i,14};
   

   %dat(i).ContactR = RAW{i,16};
   dat(i).FreqR = RAW{i,15};
   dat(i).AmpR = RAW{i,17};
   dat(i).PWR = RAW{i,18};
end

tab = struct2table(dat);

%tab(strcmp(tab.Visit,'M14'),:) = [];

tab.Treatment(strcmp(tab.Treatment,'NST')) = {'STN'};
tab.Treatment(strcmp(tab.Treatment,'NA')) = {'AcN'};
tab.Treatment(strcmp(tab.Treatment,'NA')) = {'AcN'};
tab.Treatment(strcmp(tab.Treatment,'NAc')) = {'AcN'};
tab.Treatment(strcmp(tab.Treatment,'Nac')) = {'AcN'};
tab.Treatment(strcmp(tab.Treatment,'NC')) = {'CN'};

uID = unique(tab.Id);

for i = 1:numel(uID)
   ind = tab.Id==uID(i);
   x = datetime(tab.Date(ind));
   temp = between(x(1),x,'Months');
   tab.RelativeMonth(ind) = calmonths(temp);
   temp = between(x(1),x,'Days');
   tab.RelativeDay(ind) = caldays(temp);
end

writetable(tab,'data_voltage.csv')
