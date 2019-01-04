source("githubapi.r")

repository_full_name_processor <- function(json) sapply(json$items, function(e) e$full_name)

most_starred_query = 'https://api.github.com/search/repositories?q=stars:>0&sort=stars&order=desc&per_page=100'
most_starred_repositories <- iterate_over_results_of_query(most_starred_query, 
                                                           process=repository_full_name_processor, 
                                                           join=c, 
                                                           new=character(0))

write(most_starred_repositories, file="repos.list")

  


  
