[NUM,TXT,RAW] = xlsread('/Volumes/Data/Human/STN_intrasurgical_PD_clara.xlsx');

savedir = '/Volumes/Data/Human/CLARA/';

RAW(1,:) = [];
q = linq();

for i = 1:size(RAW,1)
   if ~isnan(RAW{i,1})
      fprintf('%s\n',RAW{i,1});
      
      id = RAW{i,1};
      cd('/Volumes/Data/Human/STN');
      
      dirs = dir;
      dirs = q(dirs).where(@(x) x.isdir==1).select(@(x) x.name).toList;
      d = strcmp(id,dirs);
      cd([ dirs{d} filesep 'Intraop']);
      
      area = RAW{i,3};
      disease = 'PD';
      side = RAW{i,4};
      if strcmp(side,'L')
         side = 'Left';
      elseif strcmp(side,'R')
         side = 'Right';
      else
         side = '';
      end
      section = NaN;
      depth = RAW{i,5};
      
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
         fprintf([id '_' side '_' num2str(depth) '\n']);
         continue;
      elseif numel(f) > 1
         t = [f.datenum];
         [Y,I] = sort(t,'descend');
         f = f(I(1));
      end
      
      ind = 6;
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
            fprintf([id '_' side '_' num2str(depth) '\n']);
            continue;
         end
      catch
         warning('Problem reading plexon file!');
         fprintf([id '_' side '_' num2str(depth) '\n']);
         continue;
      end
      
      if isempty(side)
         if isnan(section)
            save([savedir id '_' disease '_0_' num2str(depth) '.mat' ],'dat');
         else
            save([savedir id '_' disease '_' num2str(section) '_' num2str(depth) '.mat' ],'dat');
         end
      else
         if isnan(section)
            save([savedir id '_' disease '_' side(1) '_0_' num2str(depth) '.mat' ],'dat');
         else
            save([savedir id '_' disease '_' side(1) '_' num2str(section) '_' num2str(depth) '.mat' ],'dat');
         end
      end
      
      cd('..');
      clear spkname start_t end_t
   end
end