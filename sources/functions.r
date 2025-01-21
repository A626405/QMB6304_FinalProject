#requirements<-c("dplyr","ggplot2","scales","shiny","readr","tidyr","stringi","mapdata","reticulate","lubridate","tibble","tidyselect")
#options(verbose=F,catch.script.errors=T,echo=F,repos=c("https://cloud.r-project.org","http://cran.rstudio.com"))
#Sys.time()
rs <- function() {
  system("cmd /c cls")
  cat("\014")
  .rs.api.terminalKill(.rs.api.terminalList())
  gc()  
  
  all_objs <- ls(all.names = TRUE, envir = .GlobalEnv)
  obs_keep<-c("rs","cleaned")
  objs_to_remove <- setdiff(all_objs,obs_keep)
  rm(list = objs_to_remove, envir = .GlobalEnv)
  
  system("cmd /c cls")
  cat("\014")
  gc(F,T,T)
}
#-------------------------------------------------------------------------------------------------
rs <- function() {
  clear_console_and_terminal <- function() {
    if (.Platform$OS.type == "windows") {
      
      system("cmd /c cls")
      cat("\014")
    } else {
      system("clear && printf '\\e[3J'")
      cat("\014")
    }
  }
  
  kill_rstudio_terminals <- function() {
    if ("tools:rstudio" %in% search()) {
      .rs.api.terminalKill(.rs.api.terminalList())
    }
  }
  
  clear_environment <- function(except = c("rs", "cleaned")) {
    all_objs <- ls(all.names = TRUE, envir = .GlobalEnv)
    objs_to_remove <- setdiff(all_objs, except)
    rm(list = objs_to_remove, envir = .GlobalEnv)
  }
  
  kill_rstudio_terminals()
  gc()
  clear_environment()
  clear_console_and_terminal()
  gc(F,T,T)
}
##########################################################################################################
#Function #1: Checks all Cols of A DF for: Class, Count NA/NULL/NaN, Is Categorical?, Count Unique Values
dfcheck <- function(dataframe, threshold) {
  require(dplyr)
  library(doParallel)
  dataframe <- as.data.frame(dataframe)
  colclasses <- sapply(dataframe, class)
  colname <- c(names(dataframe))
  
  if (!is.integer(threshold)) {
    threshold <- as.integer(threshold)}
  
  num_cores <- parallel::detectCores() - 1
  cl <- parallel::makeCluster(num_cores)
  registerDoParallel(cl)
  
  results <- foreach(colpos = 1:ncol(dataframe), .combine = rbind, .packages = c("foreach", "parallel","dplyr")) %dopar% {
    col_class <- colclasses[colpos]
    num_na <- sum(is.na(dataframe[[colpos]]))
    num_null <- sum(is.null(dataframe[[colpos]]))
    num_nan <- sum(is.nan(dataframe[[colpos]]))
    num_unique_vals <- length(unique(dataframe[[colpos]]))
    is_categorical <- ifelse(num_unique_vals < threshold, "Yes", "No")
    
    c(col_class,num_na,num_null,num_nan,is_categorical,num_unique_vals)
  }
  results_df <- as.data.frame(results,row.names = c(names(dataframe)))
  colnames(results_df) <- c("Class","#NA","#NULL","#NaN","Categorical","Num_Unique_Vals")
  results_df <- results_df[order(results_df$Class),]
  
  print(results_df)
  parallel::stopCluster(cl)
}
##########################################################################################################
#FUNCTION #1: Nothing crazy requires character vector/list
load_lb<-function(LibList){
  Lib <- as.list(LibList)
  for(i in 1:length(Lib)){
    require(Lib[[i]],character.only=T)}
}
#-------------------------------------------------------------------------------------------------
'FUNCTION #2: Specify Libs("C"), load into environment when desired.
      Unix-OS ONLY, Forks the process of loading libs.'

load_lb<-function(){
  num_cores<-parallel::detectCores()-1
  cl<-Parallel::makeCluster(num_cores)
  doParallel::registerDoParallel(cl)
  Libs<-c("dplyr","readr","tidyr","stringi","tibble","tidyr")
  parallel::mclapply(Libs, function(pkg){
    
    if (!requireNamespace(pkg,quietly=T,)) {
      install.packages(pkg,dependencies=T,repo='http://cran.rstudio.com',quiet = T)}
  },mc.cores = num_cores)  
  
  parallel::stopCluster(cl)
  cat("All specified libraries are loaded into the global environment.\n")
}
#-------------------------------------------------------------------------------------------------
'FUNCTION #3: provide an object Libs("C"), loads them into the environment.
      Unix-OS ONLY, Forks the process of loading libs.'
getlibs <- function(Libs) {
  Libs <- c(Libs)
  require(foreach)
  require(doParallel)
  
  num_cores <- parallel::detectCores() - 1
  cl <- parallel::makeCluster(num_cores)
  registerDoParallel(cl)
  
  mclapply(Libs, function(pkg) {
    
    if (!requireNamespace(pkg,quietly=T,)) {
      install.packages(pkg,dependencies=T, repo = 'http://cran.rstudio.com',quiet = T)}
  },mc.cores = num_cores)  
  
  parallel::stopCluster(cl)
  cat("All specified libraries are loaded into the global environment.\n")
}
#-------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------

################################################################################################################################################################
#/\/\/\/\/\/\/\\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
"
COMPUTATIONALLY INEFFICIENT FUNCTIONS THAT ALREADY EXIST.

"

################################################################################################################################################################
#Function #4: Loads RData Files Version 1.0 <- Have A Dir that needs load.
load_rd <- function(Directory_Path){
  require(dplyr)
  Directory_Path<- as.character(Directory_Path)
  Directory_Path<-dir(Directory_Path,pattern=c(".RData"),all.files=T,full.names=T,include.dirs=T,no..=T)
  
  for(file in Directory_Path){
    load(file,verbose = F,envir = .GlobalEnv)
  }
  print("RData Files Have Been Loaded.")
  print(paste(ls()))
}
################################################################################################################################################################
#Function #4: Loads RData Files VERSION 2.0   MODIFY TO SAVE AND LOAD
load_rd <- function(Directory_Path){
  require(dplyr)
  #Directory_Path<- as.character(Directory_Path)
  Directory_Path<-dir(Directory_Path,pattern=c(".RData"),all.files=T,full.names=T,include.dirs=T,no..=T)
  
  message("\nLoading RData files from directory...\n")
  for(file in Directory_Path){
    before_objects <- ls(envir = .GlobalEnv)
    tryCatch( {
      load(file,verbose = F,envir = .GlobalEnv)
      after_objects <- ls(envir = .GlobalEnv)
      new_objects <- setdiff(after_objects, before_objects)
      message(paste("Loaded from", file, ":", paste(new_objects, collapse = ", ")))
    },
    error = function(e) {
      warning(paste("Skipping invalid file:", file, "->", e$message))})
  }
  message("RData file loading complete.")
}
######################################################################################################################################################################################################
