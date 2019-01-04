library(curl)
library(rjson)
library(stringr)

# Some quality of life for string concatenation.
`%+%` <- function(a, b) paste0(a, b)
`%/%` <- function(a, b) paste0(a, "/", b)

# Parses the headers and looks for one that specifies the number of pages the results are divided into?
read_page_count_from_curl_headers <- function(headers) {
  # Get the commit-specific header
  git_header <- headers[grepl("^Link:", headers)]
  
  # Split the header into individual lines and select the reference to last page
  references <- unlist(str_split(git_header, ","))
  last_reference <- references[grepl("rel=\"last\"", references)]
  
  # Extract last page number and convert to int
  as.integer(str_extract(str_extract(last_reference, pattern="[&?]page=[0-9]+"), pattern="[0-9]+"))
}

# A framework for executing a query multiple times in a row to retrieve all the pages of results available.
iterate_over_results_of_query <- function(query, process, join, new) {
  # Grab headers returned by the query and use them to figure out how many pages of results there will be.
  headers <- curlGetHeaders(query)
  n <- read_page_count_from_curl_headers(headers)
  
  # Create a temporary filename for grabbing results.
  temp_file <- tempfile()
  
  # This is the data structure which will hold our data.
  results <- new
  
  # For each available page of results:
  for (i in 1:n) {
    # Extend the query to grab a specific page of results.
    paginated_query = query %+% '&page=' %+% i
    
    cat(paste0("processing page ", i, "/", n, " query: ", paginated_query, "\n"), file=stderr())
    
    # Download the results of the query into the temporary file.
    curl_download(paginated_query, temp_file)
    
    # Stagger the downloads.
    Sys.sleep(5)

    # Parse the JSON data in the temporary file.
    json <- fromJSON(file=temp_file)
    
    # Process the JSON data with the custom function. Afterwards, use the custom join function to append the results of this and previous queries.
    results <- join(results, process(json))
  }
  
  # Return the aggregated results.
  results
}

run_query <- function(query) {
  cat(paste0("processing query: ", query, "\n"), file=stderr())
  
  # Create a temporary filename for grabbing results.
  temp_file <- tempfile()
  
  # Download the results of the query into the temporary file.
  curl_download(query, temp_file)
  
  # Stagger the downloads.
  Sys.sleep(5)
  
  # Parse the JSON data in the temporary file.
  fromJSON(file=temp_file)
}
