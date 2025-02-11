for (i in 1:3) {
  if (i==1) {
    a = unique(dataSTN_mov_theta$Subject);
    RT = matrix(NA,nrow=106,ncol=4);
    j = 0;
    treat = 'OFF'}
  else if (i==2)  {
    treat = 'ON'}
  else if (i==3) {
    treat = 'TOC'}

for (k in 1:length(a)) {
  subj = a[k]
  
  # neg
  emo = 'neg'
  test = dataSTN_mov_theta$RT[dataSTN_mov_theta$Subject==subj & dataSTN_mov_theta$Treat==treat & dataSTN_mov_theta$Emo==emo]
  if (length(test) != 0) {print('ok'); j=j+1; print(j);
  RT[j,1] = mean(dataSTN_mov_theta$RT[dataSTN_mov_theta$Subject==subj & dataSTN_mov_theta$Treat==treat & dataSTN_mov_theta$Emo==emo],na.rm=TRUE);
  RT[j,2] = subj;
  RT[j,3] = treat;
  RT[j,4] = emo}
  
  # neuneg
  emo = 'neuneg'
  test = dataSTN_mov_theta$RT[dataSTN_mov_theta$Subject==subj & dataSTN_mov_theta$Treat==treat & dataSTN_mov_theta$Emo==emo]
  if (length(test) != 0) {print('ok'); j=j+1; print(j);
  RT[j,1] = mean(dataSTN_mov_theta$RT[dataSTN_mov_theta$Subject==subj & dataSTN_mov_theta$Treat==treat & dataSTN_mov_theta$Emo==emo],na.rm=TRUE);
  RT[j,2] = subj;
  RT[j,3] = treat;
  RT[j,4] = emo}
  
  # pos
  emo = 'pos'
  test = dataSTN_mov_theta$RT[dataSTN_mov_theta$Subject==subj & dataSTN_mov_theta$Treat==treat & dataSTN_mov_theta$Emo==emo]
  if (length(test) != 0) {print('ok'); j=j+1; print(j);
  RT[j,1] = mean(dataSTN_mov_theta$RT[dataSTN_mov_theta$Subject==subj & dataSTN_mov_theta$Treat==treat & dataSTN_mov_theta$Emo==emo],na.rm=TRUE);
  RT[j,2] = subj;
  RT[j,3] = treat;
  RT[j,4] = emo}
  
  # neupos
  emo = 'neupos'
  test = dataSTN_mov_theta$RT[dataSTN_mov_theta$Subject==subj & dataSTN_mov_theta$Treat==treat & dataSTN_mov_theta$Emo==emo]
  if (length(test) != 0) {print('ok'); j=j+1; print(j);
  RT[j,1] = mean(dataSTN_mov_theta$RT[dataSTN_mov_theta$Subject==subj & dataSTN_mov_theta$Treat==treat & dataSTN_mov_theta$Emo==emo],na.rm=TRUE);
  RT[j,2] = subj;
  RT[j,3] = treat;
  RT[j,4] = emo}
}
}