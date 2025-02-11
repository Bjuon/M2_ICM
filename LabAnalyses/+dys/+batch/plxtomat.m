[NUM,TXT,RAW] = xlsread('/Volumes/Data/Human/GPI/GPi_Intrasurgical_Dystonia_firstpass10.xlsx');
%[NUM,TXT,RAW] = xlsread('/Volumes/Data/Human/GPI/GPi_Intrasurgical_Dystonia_firstpass9.xlsx');
%[NUM,TXT,RAW] = xlsread('/Volumes/Data/Human/GPI/GPi_intrasurgical_Parkinson_secondpass.xlsx');


RAW(1,:) = [];
q = linq();

for i = 1:size(RAW,1)
   if ~isnan(RAW{i,1})
      fprintf('%s\n',RAW{i,1});
      
      id = RAW{i,1};
%       if any(strcmp(id,{'LEFP','CAPV'}))
%          cd('/Volumes/Data/Human/HUNTINGTON');
%       else
         cd('/Volumes/Data/Human/GPI');
%       end
      
      dirs = dir;
      dirs = q(dirs).where(@(x) x.isdir==1).select(@(x) x.name).toList;
      d = strncmp(id,dirs,numel(id));
      cd(dirs{d});
      
      area = RAW{i,4};
      disease = RAW{i,5};
      side = RAW{i,6};
      if strcmp(side,'L')
         side = 'Left';
      elseif strcmp(side,'R')
         side = 'Right';
      else
         side = '';
      end
      section = RAW{i,7};
      depth = RAW{i,8};
      
      if isnan(section)
         f = dir(['*' side '*' 'sec_*' num2str(depth) '*plx']);
      else
         f = dir(['*' side '*' 'sec ' num2str(section) '*' num2str(depth) '*plx']);
      end

      if numel(f) == 0
         if isnan(section)
            f = dir(['*' side '*' 'sec *' num2str(depth) '*plx']);
         else
            f = dir(['*' side '*' 'sec ' num2str(section) '*' num2str(depth) '*plx']);
         end
      end
      
      if numel(f) == 0
         warning('No matching files found!');
         keyboard
         continue;
      elseif numel(f) > 1
         t = [f.datenum];
         [Y,I] = sort(t,'descend');
         f = f(I(1));
      end
      
      ind = 9;
      count = 1;
      spkname = {};
      start_t = [];
      end_t = [];
      while 1
         if ~isnan(RAW{i,ind})
            spkname{count} = RAW{i,ind};
            start_t(count) = RAW{i,ind+1};
            end_t(count) = RAW{i,ind+2};
            
            ind = ind + 3;
            count = count + 1;
         else
            break;
         end
      end

      try
         dat = hd.load.plexon2(f.name,spkname,start_t,end_t);
         dat.id = id;
         dat.area = area;
         dat.disease = disease;
         dat.side = side;
         dat.depth = depth;
         
         if any(cellfun(@(x) isempty(x),dat.spk))
            warning('There should not be empty spikes!');
            keyboard
            continue;
         end
      catch
         warning('Problem reading plexon file!');
         continue;
      end
      
      if isempty(side)
         if isnan(section)
            save([id '_' disease '_0_' num2str(depth) '.mat' ],'dat');
         else
            save([id '_' disease '_' num2str(section) '_' num2str(depth) '.mat' ],'dat');
         end
      else
         if isnan(section)
            save([id '_' disease '_' side(1) '_0_' num2str(depth) '.mat' ],'dat');
         else
            save([id '_' disease '_' side(1) '_' num2str(section) '_' num2str(depth) '.mat' ],'dat');
         end
      end
      
      cd('..');
      clear spkname start_t end_t
   end
end