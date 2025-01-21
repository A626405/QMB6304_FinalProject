#requirements<-c("dplyr","ggplot2","scales","shiny","readr","tidyr","stringi","mapdata","reticulate","lubridate","tibble","tidyselect")

clrmem <- function(select_123){
  if(select_123==1){
  gc(F,T,T)
  cat("\014")
  objs_to_remove <- ls(all.names = TRUE, envir = .GlobalEnv)
  objs_to_remove <- objs_to_remove[!grepl("^renv", objs_to_remove)]
  rm(list = objs_to_remove, envir = .GlobalEnv)
  options(verbose=F,catch.script.errors=T,echo=F,repos=c("https://cloud.r-project.org","http://cran.rstudio.com"))
  source("code/R/functions.r")
  cat("\014")
  gc(F,F,T)
  }else if(select_123==2){
    gc(F,F,T)
    cat("\014")
    gc(F,T,T)
    cat("\014")
  } else if(select_123==3){
    gc()
    cat("\014")
    gc()
    cat("\014")
  } else{
    print("Incorrect Selection")
  }
}


load_lb<-function(LibList){
  Lib <- as.list(LibList)
  for(i in 1:length(Lib)){
    require(Lib[[i]],character.only=T)}
}

'getlibs <- function(pkgs_charlist) {
  Lib <- as.list(pkgs_charlist)
  require(doParallel)
  require(parallel)
  
  num_cores <- parallel::detectCores() - 1
  cl <- parallel::makeCluster(num_cores)
  doParallel::registerDoParallel(cl)
  
  parallel::mclapply(Lib, function(pkg){
          require(pkg,character.only=T)
  },mc.cores = num_cores,mc.preschedule=T)  
  
  parallel::stopCluster(cl)
}'

db1 <- function(){
  if(!file.exists("data/internal/datasets.db")){
    require(reticulate)
    reticulate::py_run_file("../Python/databases.py")
    unloadNamespace("reticulate")
  } else{
    print("The Database Already Exists.")
  }
}
