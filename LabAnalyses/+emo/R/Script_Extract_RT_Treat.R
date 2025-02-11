for (i in 1:3) {
  if (i==1) {
    a = unique(dataSTN_mov_theta$Subject);
    RTtreat = matrix(NA,nrow=28,ncol=3);
    j = 0;
    treat = 'OFF'}
  else if (i==2) {
    treat = 'ON'}
  else if (i==3) {
    treat = 'TOC'}
  
  for (k in 1:length(a)) {
    subj = a[k];
    
    test = dataSTN_mov_theta$RT[dataSTN_mov_theta$Subject == subj & dataSTN_mov_theta$Treat == treat];
    if (length(test) != 0) {
      print('ok'); j=j+1; print(j);
      RTtreat[j,1] = mean(dataSTN_mov_theta$RT[dataSTN_mov_theta$Subject==subj & dataSTN_mov_theta$Treat==treat], na.rm=TRUE);
      RTtreat[j,2] = subj;
      RTtreat[j,3] = treat}
   }
}
