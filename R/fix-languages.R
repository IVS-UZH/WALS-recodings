# collapses language ids to a single id point
collapse_language_ids <- function(data, code, subcodes) {
  eval(bquote(expect_true(all(.(unique(c(code, subcodes))) %in% data$wals_code))))

  # the row to be collapsed
  row <- filter(data, wals_code == code)
  
  codes <- unique(c(code, subcodes))
  for(feature in recoded_wals_fnames) {
    # get all the values
    values <- filter(data, wals_code %in% codes)[[feature]]
    
    # check if there are no different things
    if(n_distinct(values, na.rm=TRUE) > 1) {
      report <- data.frame(code = codes, value = values)
      report <- filter(report, !is.na(value), !duplicated(value))
          
      
      stop("Error when collapsing ", 
           paste0("'", report$code, "'", collapse=","),
           "— differing values for feature '", feature, "': ",
           paste0("'", report$value, "'", collapse=","))  
    }
    
    # get the value
    value <- unique(na.omit(values))
    if(length(value)==0) value <- NA
      
    row[1, feature] <- value
  }
  
  # remove the collapsed features
  data <- filter(data, !wals_code %in% setdiff(codes, code))
  data[data$wals_code == code, ] <- row
  
  
  data
}


# 1. Collapse Uzbek and Uzbek (Northern) — same language, but compiled by different authors
wals_recoded <- collapse_language_ids(wals_recoded, "uzb", c("uzb", "uzn"))

# 2. Collapse Adyghe (Abzakh), Adyghe (Shapsugh) and Adyghe (Temirgoy) 
wals_recoded <- collapse_language_ids(wals_recoded, "ady", c("ady", "ash", "adt"))


