cause <- function(path,name,colnum,filename){
  name <- read.csv(path, header=FALSE)
  
  names(name) <- name[2,]
  name <- name[c(-1,-2,-3),c(1,2,colnum)]

  col <-c('성별','시점')
  for (i in 2:7){
    col <- c(col, paste(filename,'_',i,'0대',sep=''))
  }
  
  colnames(name) <- col
  for (i in 2:ncol(name)){
    name[,i] <- as.numeric(name[,i])
  }
  return (name)
}

t.cause <- function(data, gender){
  if (gender=='male'){
    data.re <- t(data[,-1])
    colnames(data.re) <- data.re[1,]
    data.gender <- data.re[-1,c(1:11)]
    
    return (data.gender)
  }else {
    data.re <- t(data[,-1])
    colnames(data.re) <- data.re[1,]
    data.gender <- data.re[-1,c(12:22)]
    
    return (data.gender)
    
  }
}


reg.cause <- function(data1,data2,data3,gender,year){
  reg.gender <- cbind(data1[,year],data2[,year],data3[,year])
  reg.gender <- data.frame(reg.gender)
  colnames(reg.gender) <- c('위암발생','비만발생률','외식률')
  
  if (year!=7){
    reg.gender$연령 <- seq(20,70,10)
  }else{
    reg.gender$시점 <- c(2010:2020)
  }
  
  return (reg.gender)
}




year.cause <- function(data,gender,colname){
  
  if (gender=='male'){
    data.year <- data[c(1:11),-1]
  }else{
    data.year <- data[c(12:nrow(data)),-1]
  }
  
  if (colname =='위암_총합'){
    data.year[,colname] <- apply(data.year[,-1],1,sum)
  }else{
    data.year[,colname] <- round(apply(data.year[,-1],1,mean))
  }
  return(data.year)
}
