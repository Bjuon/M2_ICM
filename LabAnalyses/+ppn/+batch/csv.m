clear all;
d = dir('*coord*.txt');
[~,~,xls] = xlsread('sexage.xlsx');
xls(:,1) = cellfun(@(x) num2str(x),xls(:,1),'uni',0);
for i = 1:numel(d)
   
   fid = fopen(d(i).name);
   
   data(i).id = fgetl(fid);
   data(i).group = fgetl(fid);
   fgetl(fid);
   
   %ind = strcmp(xls(:,1),data(i).id);
   ind = cellfun(@(x) strfind(data(i).id,x),xls(:,1),'uni',0);
   ind = ~cellfun(@(x) isempty(x),ind);
   data(i).sex = xls{ind,2};
   data(i).age = xls{ind,3};
   
   temp = textscan(fid,'%f%f%f','CollectOutput',true,'Delimiter',' ');
   if strfind(data(i).id,'RH')
      data(i).loc = temp{1};
      data(i).loc(:,1) = -data(i).loc(:,1);
   else
      data(i).loc = temp{1};
   end
   
   % bin counts by AP ("binned" by section)
   uloc = unique(data(i).loc(:,3));
   data(i).ap = uloc;
   for j = 1:numel(uloc)
      data(i).binned(j,1) = sum(data(i).loc(:,3)==uloc(j));
   end
   
   % bin counts by ML/DV, for each AP section
   for j = 1:numel(uloc)
      data(i).x = linspace(-10,0,15);
      data(i).y = linspace(0,13,15);
      ind = data(i).loc(:,3) == uloc(j);
      [data(i).binnedxy(:,:,j)] = hist3(data(i).loc(ind,1:2),...
         {data(i).x data(i).y});
   end

   fclose(fid);
end

fid = fopen('binnedAP.txt','w');
fprintf(fid,'id,group,sex,age,ap,count\n');
for i = 1:numel(data)
   for j = 1:numel(data(i).ap)
      fprintf(fid,'%s,%s,%s,%g,%1.3f,%g\n',data(i).id,data(i).group,...
         data(i).sex,data(i).age,data(i).ap(j),data(i).binned(j));
   end
end
fclose(fid);

fid = fopen('binnedXY.txt','w');
fprintf(fid,'id,group,sex,age,x,y,count\n');
for i = 1:numel(data)
   ind = (data(i).ap <= 37.5) & (data(i).ap >= 32.5);
   xy = data(i).binnedxy(:,:,ind);
   
   for x = 1:numel(data(i).x)
      for y = 1:numel(data(i).y)
         fprintf(fid,'%s,%s,%s,%g,%1.3f,%1.3f,%g\n',data(i).id,data(i).group,...
            data(i).sex,data(i).age,data(i).x(x),data(i).y(y),xy(x,y));
      end
   end
end
fclose(fid);

fid = fopen('binnedXYZ.txt','w');
fprintf(fid,'id,group,x,y,z,count\n');
for i = 1:numel(data)
   for j = 1:numel(data(i).ap)
      for x = 1:numel(data(i).x)
         for y = 1:numel(data(i).y)
            fprintf(fid,'%s,%s,%1.3f,%1.3f,%1.3f,%g\n',...
               data(i).id,data(i).group,...
               data(i).x(x),data(i).y(y),data(i).ap(j),...
               data(i).binnedxy(x,y,j));
         end
      end
   end
end
fclose(fid);

fid = fopen('binned.txt','w');
fprintf(fid,'id,group,ap,count\n');
for i = 1:numel(data)
   for j = 1:numel(data(i).ap)
      fprintf(fid,'%s,%s,%1.3f,%g\n',data(i).id,data(i).group,data(i).ap(j),data(i).binned(j));
   end
end
fclose(fid);

group = {data.group};
id = {data.id};
uGroup = unique(group);

figure; hold on
for i = 1:numel(uGroup)
   ind = strcmp(group,uGroup{i});
   loc = cat(1,data(ind).loc);
   
   plot3(loc(:,1),loc(:,2),loc(:,3),'.');
end

figure; hold on
for i = 1:numel(uGroup)
   ind = strcmp(group,uGroup{i});
   x = cat(1,data(ind).ap);
   n = cat(1,data(ind).binned);
   
   plot(x,n,'o');
end

figure; hold on
for i = 1:numel(uGroup)
   ind = strcmp(group,uGroup{i});
   temp = data(ind);
   
   xy = [];
   for j = 1:numel(temp)
      ind2 = (temp(j).ap <= 37) & (temp(j).ap >= 32.5);
      %ind2 = (temp(j).ap <= 33.5) & (temp(j).ap >= 25);
      %ind2 = (temp(j).ap <= 38) & (temp(j).ap >= 32.5);
      xy = cat(3,xy,temp(j).binnedxy(:,:,ind2));
   end
   subplot(2,4,i);
   pcolor(temp(1).x,temp(1).y,mean(xy,3)); caxis([0 8]); shading interp
   %imagesc(temp(1).x,temp(1).y,mean(xy,3)); caxis([0 8]); %colorbar
   set(gca,'Ydir','reverse')
   axis square;
end
for i = 1:numel(uGroup)
   ind = strcmp(group,uGroup{i});
   temp = data(ind);
   
   xy = [];
   for j = 1:numel(temp)
      %ind2 = (temp(j).ap <= 37.5) & (temp(j).ap >= 32.5);
      ind2 = (temp(j).ap < 32.5) & (temp(j).ap >= 27);
      %ind2 = (temp(j).ap <= 38) & (temp(j).ap >= 32.5);
      xy = cat(3,xy,temp(j).binnedxy(:,:,ind2));
   end
   subplot(2,4,i+4);
   %imagesc(temp(1).x,temp(1).y,mean(xy,3)); caxis([0 8]); %colorbar
   pcolor(temp(1).x,temp(1).y,mean(xy,3)); caxis([0 8]); shading interp
   set(gca,'Ydir','reverse')
   axis square;
end

figure; hold on
c = get(gca,'colororder');
for i = 1:numel(uGroup)
   ind = strcmp(group,uGroup{i});
   uId = unique(id(ind));
   for j = 1:numel(uId)
      ind2 = strcmp(id,uId{j});
      x = data(ind2).ap;
      n = data(ind2).binned;
      
      plot(x,n,'o','Color',c(i,:));
      plot(x,n,'-','Color',c(i,:));
      if strcmp(id{ind2},'983')
         plot(x,n,'o','Color',c(i,:),'MarkerFaceColor',c(i,:));
      end
   end
end
xlabel('ap');

figure;
for i = 1:numel(uGroup)
   ind = strcmp(group,uGroup{i});
   loc = cat(1,data(ind).loc);
   
   h(i) = subplot(1,numel(uGroup),i);
   plot3(loc(:,1),loc(:,2),loc(:,3),'.');
end
xlabel('ml');
ylabel('dv');
linkprop(h, 'xlim');
linkprop(h, 'ylim');
linkprop(h, 'zlim');
linkprop(h, 'CameraPosition');

figure;
for i = 1:numel(uGroup)
   ind = strcmp(group,uGroup{i});
   loc = cat(1,data(ind).loc);
   
   h(i) = subplot(1,numel(uGroup),i);
   hist3(loc(:,1:2),{linspace(4,8,30) linspace(1.5,6.5,30)});
end
xlabel('ml');
ylabel('dv');
linkprop(h, 'xlim');
linkprop(h, 'ylim');
linkprop(h, 'zlim');
linkprop(h, 'CameraPosition');
for i = 1:numel(h)
   %set(get(h(i),'child'),'FaceColor','interp','CDataMode','manual','CData',colormap(parula));
   set(get(h(i),'child'),'FaceColor','interp','CDataMode','auto');
end