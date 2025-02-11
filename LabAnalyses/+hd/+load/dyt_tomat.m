disease = 'PGD';
[NUM,TXT,RAW] = xlsread('dyt11_AR.xlsx');
RAW(1,:) = [];
names = RAW(:,2);
side = RAW(:,3);
depth = [RAW{:,4}]';
area = RAW(:,6);
nspk = [RAW{:,12}]';

cd(disease);
dn = dir('*.txt');

totalCount = 0;
for i = 1:numel(dn)
   m = importdata(dn(i).name);
   
   spk = strsplit(m.textdata{1,1});
   id = strsplit(dn(i).name,'.');
   
   if numel(spk) ~= size(m.data,2)
      error('mismatch');
   end
   
   dat.fileName = dn(i).name;
   
   for j = 1:numel(spk)
      temp = m.data(:,j);
      temp(isnan(temp)) = [];
      temp(temp>300) = []; % trap bizarre values
      dat.spkName = spk;
      dat.start_t(j) = min(temp);
      dat.end_t(j) = max(temp);
      temp = temp - min(temp);
      dat.spk{j} = temp;
      dat.spkwf{j} = [];
   end
   
   % filter out units with recordings < 20 s
   total_t = dat.end_t - dat.start_t;
   ind = total_t < 20;
   if sum(ind) > 0
      dat.spkName(ind) = [];
      dat.start_t(ind) = [];
      dat.end_t(ind) = [];
      dat.spk(ind) = [];
      dat.spkwf(ind) = [];
   end
      
   if ~isempty(dat.spk)
      indName = strncmpi(names,id{1},numel(id{1})-1);
      indName = indName&strcmpi(area,'gpi');
      
      ind = zeros(size(dat.spk));
      a = {};
      s = {};
      d = [];
      for j = 1:numel(dat.spk)
         indSpk = nspk == numel(dat.spk{j});
         if sum(indName&indSpk) == 1
            ind(j) = 1;
            a = cat(1,a,area{(indName&indSpk)});
            s = cat(1,s,side{(indName&indSpk)});
            d = cat(1,d,depth(indName&indSpk));
         end
      end
      totalCount = totalCount + sum(ind);
      if sum(ind) > 0
         ind = ~logical(ind);
         dat.spkName(ind) = [];
         dat.start_t(ind) = [];
         dat.end_t(ind) = [];
         dat.spk(ind) = [];
         dat.spkwf(ind) = [];
         
         dat.id = id{1};
         dat.area = a;%area(~ind)';
         dat.disease = disease;
         dat.side = s;%side(~ind)';
         dat.depth = d;%depth(~ind)';
         
         save([id{1} '_' disease '.mat' ],'dat');
      end
   end
   
   clear m dat temp;
end
cd ..;