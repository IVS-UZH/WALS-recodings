#!/usr/bin/env Rscript --vanilla


library(tidyverse)
library(testthat)


# read in the WALS language catalogue, unfortunately there is no dedicated file for this
wals_languages <- select(read.csv("wals-dataset/language.csv"), wals_code,iso_code,glottocode,Name,latitude,longitude,genus,family,macroarea,countrycodes)

expect_false(any(duplicated(wals_languages)))
expect_false(any(duplicated(wals_languages$wals_code)))


# read in the WALS sources
wals_source_data <- bind_rows(lapply(dir("wals-dataset", pattern="^wals-chapter-.+\\.csv$", full.names=TRUE), function(fname) {
    data <- read.csv(fname, stringsAsFactors=FALSE)
  
    transmute(data,
      Feature = paste(Parameter_ID, Parameter_name),
      Language.Code = as.character(Language_ID),
      Value = as.character(Value)
    )
  })) %>%
  # and recode it into column format
  spread(Feature, Value)


# load the list of recodings
recode_patterns <- read.csv("recode-patterns.csv", stringsAsFactors=FALSE)

# extract the features that we don't need to recode
retained_wals_features <- filter(recode_patterns, is.na(recode.pattern))$wals.fname
recode_patterns <- filter(recode_patterns, !is.na(recode.pattern))

expect_false(any(duplicated(recode_patterns$new.fname)), info=paste0(
  "Duplicated feature names:\n", 
  paste0("  ", recode_patterns$new.fname[duplicated(recode_patterns$new.fname)], collapse="\n")
))

recoded_wals_fnames <- c(retained_wals_features, recode_patterns$new.fname)

expect_false(any(duplicated(retained_wals_features)), info=paste0(
  "Duplicated retained feature names:\n", 
  paste0("  ", retained_wals_features[duplicated(retained_wals_features)], collapse="\n")
))

expect_true(all(retained_wals_features %in% names(wals_source_data)), info=paste0(
  "Feature not found in WALS:\n", 
  paste0("  ", setdiff(retained_wals_features, names(wals_source_data)), collapse="\n")
))

# recode all the patterns
wals_recoded <- rowwise(recode_patterns) %>% do({
    cat("Processing ", .$new.fname, "(", .$wals.fname, " recoded as ", .$recode.pattern, ")\n", sep="")
    
    # check that the original variable is present in wals
    expect_true(.$wals.fname %in% names(wals_source_data)[-1])
    original_data <- as.character(wals_source_data[[.$wals.fname]])
  
    # make a table of original values
    expected_levels <- unlist(strsplit(.$wals.levels, "\n"))
    expected_levels <- data.frame(
      i = as.integer(gsub("^([0-9])+.+$", "\\1", expected_levels)),
      level = gsub("^[0-9]+\\.? +", "", expected_levels),
      stringsAsFactors=FALSE
    )
    
    expect_true(all(!is.na(expected_levels$i)))
    expect_true(all(!is.na(expected_levels$level)))
    
    # make sure that the WALS values are what we have in the table
    expect_true(setequal(expected_levels$level, na.omit(original_data)), info=
      paste0("Expected:\n", paste0("  ", (expected_levels$level), collapse="\n"), "\n",
            "Got:\n",  paste0("  ", (unique(original_data)), collapse="\n"))
    )
    
    # parse the recoding pattern
  
    recoding_groups <- unlist(strsplit(.$recode.pattern, "-"))
    recoding_groups <- strsplit(recoding_groups, "/") %>% lapply(as.integer)
      
    # sanity checks
    expect_true(length(recoding_groups)>1) # must have at least 2 recoding groups
    expect_true(all(!is.na(unlist(recoding_groups)))) # can't have NA's
    expect_true(all(unlist(recoding_groups) %in% expected_levels$i)) # must correspond to wals values
    expect_false(any(duplicated(unlist(recoding_groups)))) # can't have any duplicates
  
    # build the recodign table
    recoded_levels <- unlist(strsplit(.$new.levels, "\n"))
    expect_true(length(recoding_groups)==length(recoded_levels)) # must have at least 2 recoding groups
    
    recoded_levels <- bind_rows(mapply(recoded_levels, recoding_groups, FUN=function(value, ii) {
      data.frame(i = ii, new_level=as.character(value), stringsAsFactors=FALSE)
    }, SIMPLIFY=FALSE))
    
    level_table <- full_join(expected_levels, recoded_levels, by="i")
    
    # sanity checks
    expect_true(all(!is.na(level_table$level)))
    
    # recode the data
    recoded_data <- level_table$new_level[match(original_data, level_table$level)]
    
    
    data.frame(
      feature = .$new.fname, 
      wals_code = wals_source_data$Language.Code, 
      value = recoded_data,  
    stringsAsFactors=FALSE)  
  }) %>%
  spread(feature, value)
  

#  add the non-recoded variables
retained_data <- wals_source_data[c("Language.Code", retained_wals_features)]
wals_recoded <- full_join(wals_recoded, retained_data, by=c(wals_code="Language.Code"))

# and merge it with the language list
wals_recoded <- full_join(wals_languages, wals_recoded, by = "wals_code")

# check that all variable names are present
expect_true(setequal(names(wals_recoded)[-c(1:ncol(wals_languages))], recoded_wals_fnames))


# run the languae cleanup script
source("R/fix-languages.R")

# save the data
writeLines(names(wals_recoded))
write.csv(wals_recoded, "wals-recoded.csv", row.names=FALSE)



