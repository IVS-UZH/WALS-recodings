
# Various transformations (recodings) of WALS Online data

## Overview and rationale

WALS Online (Dryer, Haspelmath 2013) is a popular typological database, in which languages are
described with respect to a large selection of typological features. Each feature selects a set
number of contrastive types (values), e.g. "No tone", "Simple tone system", "Complex tone system"
for WALS feature 13A "Tone". Languages are then assigned one of these values for their respective
features.

For some types of data analysis, however, it can be useful to look at the features differently. For
instance, it might make sense to make a binary distinction for Tone, between "No tone" and "Tone
system" instead of the ternary distinction defined in WALS. Such transformations are trivial to
accomplish: in the example above, on only needs to recode all instances of ""Simple tone system"
and "Complex tone system" as "Tone system".

This repository contains a list of useful WALS data transformations (see `recode-patterns.csv`), as
well as an R script (`wals-recode.R`) that generates a table containing both the original and
transformed WALS data.

## Transformation specification

The file `recode-patterns.csv` is a comma-separated table of recoding patterns which describes how
WALS data should be transformed. Every row in this table describes a single (transformed or
original) feature, which will appear as a column in the table created by the script. The relevant
table rows are:

 - *wals.fname*:  WALS feature name, exactly as it appears in WALS Online data.
 
 - *new.fname*:   New variable name, to appear in the generated data table.
 
 - *wals.levels*: List of feature values (one per line in the cell), exactly as they are defined 
                  and appear in WALS Online data. Every value is preceded by a unique integer ID 
                  that will be used in the recoding  pattern. Different values are separated by a 
                  new line. 
                  
 - *new.levels*:  List of feature values after transformation. These values will be present in the
                  generated data table. 
  
 - *recode.pattern*: Describes how feature values should be recoded. The pattern has the general
                     form `A-B-C`, with as many hyphen-separated components as there are new 
                     (post transformation) feature values. Every component describes how the 
                     respective (first, second etc.) feature value should be formed. A component 
                     can be either a single integer number — in which case the original feature 
                     value with that ID is taken — or a slash-separated list of original 
                     value IDs (e.g. 1/2/5) — in which case these values are collapsed together. 
 
  
If all relevant columns are filled out for a row, the corresponding feature is copied from WALS
data, transformed according to the pattern, and stored as a column in the generated table. If only
*wals.fname* is filled out for a row, the corresponding feature is copied from WALS without
transformations.

## Using the script

To run the transformations, simply execute the R script in `R/wals-recode.R`. The script expects
the working directory be set to the root of the repository. It expects to find WALS Online data in
the folder `wals-dataset` and the table of data transformations in the comma-separated file
`recode-patterns.csv`. The script will create a table of feature values per language in WALS and
save it in the file `wals-recoded.csv`.  

which contains a table of
languages (rows) and transformed WALS features (columns).  


## Notes

The script additionally executes a subsequent data cleaning step (`fix-languages.R`), which removes 
some inconsistencies in how language data is treated (see that script for details). 

## Data

The recoding are based on WALS Online data as published on http://wals.info on 2016-06-23. The
scripts have not been tested with other versions of WALS Online data. Copy of WALS online from
2016-06-23 is included within this repository for convenience. 

## License

Data of WALS Online is published under the CC-BY 4.0 license:
http://creativecommons.org/licenses/by/4.0/

Scripts and aggregation metadata in this repository is published under CC-BY 4.0 license:
http://creativecommons.org/licenses/by/4.0/

It should be cited as

Bickel, Balthasar, Taras Zakharko. 2018. Recodings of WALS Online data. https://github.com/IVS-UZH/WALS-recodings




## References

Dryer, Matthew S. & Haspelmath, Martin (eds.) 2013.
The World Atlas of Language Structures Online.
Leipzig: Max Planck Institute for Evolutionary Anthropology.
(Available online at http://wals.info, Accessed on 2016-06-23.)
