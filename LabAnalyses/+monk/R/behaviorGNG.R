setwd('/Users/brian/ownCloud/behaviordata/')
#setwd('/Volumes/Data/Monkey/TEMP')
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+monk/R/behaviorSetupGNG.R')

subject = "Tess"
fname = as.list( list.files(pattern=paste(subject,"_GNG_.*txt",sep="")) )

dat = loadData(fname = fname, subject = subject)

# The following generates trials, but I'm not sure how it can have these values
#dat[dat$Tar.X==0,]

require(tables)
tabular(Condition.Name ~ Is.Repeat.Trial,data=dat)
tabular(Condition.Name*Trial.Result.Str ~ Is.Correct.Trial,data=dat)
tabular(Condition.Name*Trial.Result.Str ~ Is.Incorrect.Trial,data=dat)
tabular(Condition.Name*Trial.Result.Str ~ Is.Abort.Trial,data=dat)
detach("package:tables", unload = TRUE)
detach("package:Hmisc", unload = TRUE)

dat = dat[dat$Condition.Name=="Go control" | dat$Condition.Name=="Go",]
dat = dat[dat$Is.Correct.Trial=="True" ,]
dat = droplevels(dat)

dat %>%
  group_by(Cue.Set.Index,Dir,Condition.Name) %>% 
  summarize(average = ifelse(n() < 2, NA, mean(RT)), 
            `terms in the average` = n())

#m = lmer(RT ~ Dir*Condition.Name*Cue.Set.Index + Session + Counter.Total.Trials + Counter.Trials.In.Block + Is.Repeat.Trial + (1|Session),data=dat)
#summary(m)

# m = lmer(RT ~ Dir*Condition.Name*Cue.Set.Index + Session + Counter.Total.Trials + Counter.Trials.In.Block + Is.Repeat.Trial + 
#            G_1 + G_2 + G_3 + G_4 + G_5 + 
#            (1|Session),data=dat)
# summary(m)

m = lmer(RT ~ Dir*Condition.Name*Cue.Set.Index + 
           Counter.Total.Trials + 
           Counter.Trials.In.Block + 
           Is.Repeat.Trial + 
           lagG + 
           (1|Session),data=dat)
summary(m)
