source("githubapi.r")

user = "vuejs"
project = "vue"

commits_url = "https://api.github.com/repos" %/% user %/% project %/% "commits" %+% "?per_page=100"

new_commit_metadata <- 
  data.frame(`hash`=character(0), 
             `author name`=character(0),
             `author email`=character(0),
             `author date`=character(0),
             `comitter name`=character(0),
             `comitter email`=character(0),
             `comitter date`=character(0),
             `message`=character(0))

process_commit_metadata <- function(e)
  data.frame(`hash`=e$sha, 
             `author name`=e$commit$author$name,
             `author email`=e$commit$author$email,
             `author date`=e$commit$author$date,
             `comitter name`=e$commit$committer$name,
             `comitter email`=e$commit$committer$email,
             `comitter date`=e$commit$committer$date,
             `message`=e$commit$message)

process_commits_metadata <- function(json)
  do.call(rbind, lapply(json, process_commit_metadata))

commits <- iterate_over_results_of_query(commits_url, 
                                         process=process_commits_metadata, 
                                         join=rbind, 
                                         new=new_commit_metadata)
                                         
commit_files <- lapply(commits$hash, function(e) {
  hash <- as.character(e)
  query <- "https://api.github.com/repos" %/% user %/% project %/% "commits" %/% hash
  commit_info <- run_query(query)
  
  do.call(rbind, lapply(commit_info$files, function(e) {
    data.frame(hash=hash, file=e$filename, additions=e$additions, deletions=e$deletions)
  }))
})