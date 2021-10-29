# ==========================================================================
# Package load or install and load 
# ==========================================================================

options(scipen=10, width=system("tput cols", intern=TRUE), tigris_use_cache = TRUE) # avoid scientific notation

ipak <- function(pkg){
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)) 
        install.packages(new.pkg, dependencies = TRUE)
    sapply(pkg, require, character.only = TRUE)
}

ipak_gh <- function(pkg){
    new.pkg <- pkg[!(sub('.*/', '', pkg) %in% installed.packages()[, "Package"])]
    if (length(new.pkg)) 
        remotes::install_github(new.pkg, dependencies = TRUE)
    sapply(sub('.*/', '', pkg), require, character.only = TRUE)
}

# Example
# ipak_gh(c("lmullen/gender", "mtennekes/tmap", "jalvesaq/colorout", "timathomas/neighborhood", "arthurgailes/rsegregation"))