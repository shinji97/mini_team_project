# 출처
# seaborn 데이터셋
# - https://github.com/mwaskom/seaborn-data

# 경로설정
# setwd('C:\\Users\\user\\Desktop\\mini_team_project\\mini_team_project')
# getwd()

tip <- read.csv('8week_statistical_analysis\\data\\tips.csv')
head(tip)
str(tip)

# 결측치 확인
sum(is.na(tip))

# 탐색적데이터 분석 & 시각화
cat('컬럼별 unique 값')
for (i in 1:ncol(tip)){
  if (typeof(tip[,i])=='double'){next}
  cat(colnames(tip)[i],':', unique(tip[,i]),'\n')
}

# 성별 비율
tab_se <- table(tip$sex)
label <- paste(names(tab_se),'\n',round(tab_se/sum(tab_se)*100,1),'%',sep='')
pie(tab_se,col=c('#f0f0f0','#63a3f7'),labels=label,border='white',main='성별 비율')

# 요일 비율
tab_day <- table(tip$day)
label <- paste(names(tab_day),'\n',round(tab_day/sum(tab_day)*100,1),'%',sep='')
pie(tab_day,col=c('#327acc','#d8e1ea','#a6c4e8','#00286e'),labels=label,border='white',main='요일 비율')

# 시간 비율
tab_time <- table(tip$time)
label <- paste(names(tab_time),'\n',round(tab_time/sum(tab_time)*100,1),'%',sep='')
pie(tab_time,col=c('#63a3f7','#f0f0f0'),labels=label,border='white',main='시간별 비율')

# 성별별 tip 평균
mean_tip_sex <- round(tapply(tip$tip, INDEX = tip$sex, FUN = mean),2)
bp <- barplot(mean_tip_sex, ylim=c(0,3.5),col='lightblue',main='성별별 tip 평균')
text(x=bp, y=mean_tip_sex*0.9, labels=mean_tip_sex,cex=5, col='white')

# 금액별 빈도수
library(ggplot2)

ggplot(tip, aes(x = total_bill)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  facet_wrap(~ time, ncol = 1) 

# 기술적 분석기법

# 평균, 분산, 표준편차
for (i in c(1,2,7)){
  cat(colnames(tip)[i],'평   균 : ',mean(tip[,i]),'\n')
  cat('    ','분   산 : ',var(tip[,i]),'\n')
  cat('    ','표준편차 : ',sd(tip[,i]),'\n')
  
  if (i != 7){
    Q <- quantile(tip[,i], probs = seq(0, 1, 0.25), na.rm = FALSE)
    for (j in 1:length(Q)){
      cat('    ',names(Q)[j],':',Q[j],'\n')
    }
    cat('\n')
  }
  
}

boxplot(tip$total_bill, main='total_bill', col='lavender')
boxplot(tip$tip, main='tip', col='lavender')


tip_fe <- subset(tip, sex=='Female')
tip_ma <- subset(tip, sex=='Male')


# tip과 total_bill 상관관계 그래프
ggplot(tip, aes(x = total_bill, y = tip)) +
  geom_point() +
  geom_smooth(method = "lm")

cor(tip$tip, tip$total_bill)
