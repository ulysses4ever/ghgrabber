#!/usr/bin/Rscript
repos <- read_csv("repos.list", col_names=F) %>% rename(repo=X1)
timing <- read_csv("timing.csv", col_names=F) %>% mutate(repo=paste0(user,"/", repo)) %>% select(-user,-time,-status)
diff<-anti_join(repos, x, by="repo")
write_table
write_csv(diff, "repos.diff.list", col_names=FALSE)
