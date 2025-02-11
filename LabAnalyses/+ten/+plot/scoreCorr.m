%varStr = {'Mattis' 'updrsIIIOffSOffM'};
function scoreCorr(dat,varStr,visit)

n = numel(varStr);
X = [];
for i = 1:n
   q = linq(dat);
   x = (q.select(@(x) cat(1,x.visit(visit).(varStr{i}))).toArray)';
   X = [X , x];
end

C = nan(n,n);
P = nan(n,n);
N = nan(n,n);
for i = 1:n
   for j = (i+1):n
      [c,p,num] = stat.nancorr(X(:,[i j]),'type','Spearman');
      C(i,j) = c(1,2);
      P(i,j) = p(1,2);
      N(i,j) = num;
   end
end


figure; hold on
C2 = C;
%C2(P>0.05) = NaN;
N2 = N;
N2 = N2./size(X,1);
C2(isnan(C2)) = 0;
N2(isnan(N2)) = 0;
imagesc(C2'+N2);
for i = 1:n
   for j = (i+1):n
      if P(i,j) < 0.05
         plot(i,j,'w.');
      end
   end
end
set(gca,'xtick',1:n,'xticklabel',varStr,'xticklabelrotation',90);
set(gca,'ytick',1:n,'yticklabel',varStr);
axis square; axis tight
colorbar;
colormap jet;
set(gca,'YDir','reverse');
caxis([-.8 .8]);
title(['Visit ' num2str(visit)]);

% temp = X;
% temp(any(isnan(X),2),:) = [];
% corrcoef(temp)
% keyboard
% figure
% [H,AX,BigAx,P,PAx] = plotmatrix(X);
% 
% for i = 1:size(X,2)
%    title(AX(1,i),varStr{i});
%    ylabel(AX(i,1),varStr{i},'FontWeight','bold','Rotation',0,'HorizontalAlignment','right');
% end
% %suptitle(varStr)
% %title(BigAx,varStr)
