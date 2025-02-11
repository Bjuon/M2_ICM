%varStr = 'Mattis';
function scoreRepeated(dat,varStr)


q = linq(dat);
X = (q.select(@(x) cat(1,x.visit.(varStr))).toArray)';

figure
[H,AX,BigAx,P,PAx] = plotmatrix(X);

for i = 1:size(X,2)
   title(AX(1,i),['t' num2str(i-1)]);
   ylabel(AX(i,1),['t' num2str(i-1)],'FontWeight','bold','Rotation',0,'HorizontalAlignment','right');
end
suptitle(varStr)
%title(BigAx,varStr)
