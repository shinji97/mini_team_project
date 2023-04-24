# 출처
# seaborn 데이터셋
# - https://github.com/mwaskom/seaborn-data

# 경로설정
# setwd('C:\\Users\\user\\Desktop\\mini_team_project\\mini_team_project')
# getwd()

# 파일 불러오기
health <- read.csv('8week_statistical_analysis\\data\\healthexp.csv')
head(health)
str(health)

# 결측치 확인
sum(is.na(health))

for (i in 1:ncol(health)){
  if (i==1){
    cat('컬럼별 unique 값 \n')
  }
  if (typeof(health[,i])=='double'){next}
  cat(colnames(health)[i],':', unique(health[,i]),'\n')
}

# 탐색적데이터 분석 & 시각화
# 연도별 금액
mean_year_spend <- round(tapply(health$Spending_USD, INDEX = health$Year, FUN = mean),2)
mean_year_spend
plot(names(mean_year_spend),mean_year_spend,type='l',xlab='연도', ylab='평균 건강관련 지출 비용',col='red',
     main='연도별 건강관련 지출 비용 평균')

ggplot(health, aes(x=Year, y=Spending_USD, color = Country)) +
  geom_line(size=2) +
  labs(title='나라별 건강관련 지출 비용', x="연도", y="건강관련 지출 비용")

# 나라별 사용 금액
mean_country_spend <- round(tapply(health$Spending_USD, INDEX = health$Country, FUN = mean),2)
mean_country_spend
label <- paste(names(mean_country_spend),'\n',round(mean_country_spend/sum(mean_country_spend)*100,1),'%',sep='')
pie(mean_country_spend, col=c('#688aad','#2c65aa','#4281ce','#73a2da','#a6c4e8','#00286e'),labels=label, border='white',main='나라별 건강관련 지출 비용')

# 나라별 평균 수명
mean_country_life <- round(tapply(health$Life_Expectancy, INDEX = health$Country, FUN = mean),2)
mean_country_life
bp <- barplot(mean_country_life,cex.names=0.8,col='lightblue', main='나라별 평균 기대 수명')
text(x=bp, y=mean_country_life*0.9, labels=mean_country_life,cex=1.5, col='white')



# 나라별 평균 사용 비용& 기대 수명
df <- data.frame(cbind(mean_country_spend,mean_country_life))
df
library(ggplot2)
ggplot(df, aes(x=row.names(df),group=1))+
  geom_bar(aes(y=mean_country_life*55),fill='darkgrey',stat='identity')+
  geom_line(aes(y=mean_country_spend,colour='건강관련 지출 비용'),size=2)+
  scale_y_continuous(name='나라별 평균 건강관련 지출 비용',sec.axis = sec_axis(~.*0.02, name="나라별 평균 기대 수명"))+
  geom_hline(yintercept = 4375,color='blue',lwd=3)+xlab('')+
  ggtitle('나라별 평균 건강관련 지출 비용& 기대 수명')




# 기술적 분석기법

str(health)
# 평균, 분산, 표준편차
for (i in c(3,4)){
  cat(colnames(health)[i],'평   균 : ',mean(health[,i]),'\n')
  cat('    ','분   산 : ',var(health[,i]),'\n')
  cat('    ','표준편차 : ',sd(health[,i]),'\n')
  Q <- quantile(health[,i], probs = seq(0, 1, 0.25), na.rm = FALSE)
  for (j in 1:length(Q)){
    cat('    ',names(Q)[j],':',Q[j],'\n')
  }
  cat('\n')
}

# 나라별 평균, 분산, 표준편차
country_list <- c('Germany', 'France','Great Britain','Japan','USA','Canada')
for (i in country_list){
  health_country<-subset(health,Country==i)
  for (j in c(3,4)){
    cat(i,colnames(health)[j],'\n')
    cat('    ','평균 : ',mean(health_country[,j]),'\n')
    cat('    ','분산 : ',var(health_country[,j]),'\n')
    cat('    ','표준편차 : ',sd(health_country[,j]),'\n\n')
  }
}

# 연도별 평균, 분산, 표준편차
year_list <-  unique(health$Year)

for (i in year_list){
  health_year<-subset(health,Year==i)
  for (j in c(3,4)){
    cat(i,colnames(health)[j],'\n')
    cat('    ','평균 : ',mean(health_year[,j]),'\n')
    cat('    ','분산 : ',var(health_year[,j]),'\n')
    cat('    ','표준편차 : ',sd(health_year[,j]),'\n\n')
  }
}

# Spending_USD 이상치
boxplot(health$Spending_USD, main='건강관련 지출 비용', col='lavender')
Q <- quantile(health$Spending_USD, probs = seq(0, 1, 0.25), na.rm = FALSE)
iqr <- IQR(health$Spending_USD)
lout <- Q[2]-(1.5*iqr)
uout <- Q[4]+(1.5*iqr)
for (i in 1){
  cat('하위 이상치 : ',lout,'\n')
  cat('하위 이상치 개수 :',sum(health$Spending_USD < lout),'\n')
  cat('상위 이상치 : ',uout,'\n')
  cat('상위 이상치 개수 :',sum(health$Spending_USD > uout),'\n')
}

# 통계적 분석기법

shapiro.test(health$Life_Expectancy)
shapiro.test(health$Spending_USD)

# 평균검정

# 일표본 평균검정

# H0 : 평균 기대 수명은 75세이다. --> p-value <0.05 기각
life.t <- t.test(x=health$Life_Expectancy, mu=75)
life.t
life.t$p.value

# H0 : 평균 기대 수명은 75세보다 작거나 같다. --> p-value <0.05 기각
# H1 : 평균 기대 수명은 75세보다 크다. --> 지지
under_life.t <- t.test(x=health$Life_Expectancy, mu=75,alternative = 'greater')
under_life.t
under_life.t$p.value

# H0 : 평균 기대 수명은 78세이다. --> p-value > 0.05 귀무가설 지지
life.t_new <- t.test(x=health$Life_Expectancy, mu=78)
life.t_new
life.t_new$p.value

# 독립표본 평균검정

# H0 : 같은 유럽인 프랑스와 독일의 평균 기대수명은 동일하다. --> p-value <0.05 기각
# H1 : 다르다
health_EU<-subset(health,Country=='Germany' | Country=='France')
health_EU$Country <- as.factor(health_EU$Country)
str(health_EU)

EU.t <- t.test(formula=Life_Expectancy~Country, data=health_EU)
EU.t
EU.t$p.value
bars <- tapply(health_EU$Life_Expectancy, health_EU$Country, mean)
lower <- tapply(health_EU$Life_Expectancy, health_EU$Country, function(x) t.test(x)$conf.int[1])
upper <- tapply(health_EU$Life_Expectancy, health_EU$Country, function(x) t.test(x)$conf.int[2])

library(gplots)
barplot2(bars, space=0.4, plot.ci=TRUE, ci.l=lower, ci.u=upper, ci.color = '#006d2c',ci.lwd=4,
         names.arg = c('Germany', 'France'), col=c('#edf8e9','#bae4b3'),
         ylab='평균 기대 수명', main= '유럽내 평균 기대 수명')
abline(h=78.58254, col='red',lwd=4)


# 분산분석

# 범주형으로 변환
health$Country <- as.factor(health$Country)
# health$Year <- as.factor(health$Year)
str(health)

# 일원분산분석
# H0 : 나라별 기대수명 차이는 없다 --> p-value <0.05 기각
# 나라별 기대수명 차이는 존재한다.
health.one.aov <- aov(Life_Expectancy~Country, data=health)
summary(health.one.aov)

model.tables(health.one.aov)

TukeyHSD(health.one.aov)

library(gplots)
plotmeans(Life_Expectancy~Country, data=health, barcol='#a4acea', barwidth=3, col='cornflowerblue',connect=FALSE,
          xlab='Country', ylab='평균 기대 수명',cex=0.7)
abline(h=76.5002, lwd=3,lty=1,col='coral')
abline(h=78.49112, lwd=3,lty=1,col='coral')
abline(h=77.71328,lwd=3,lty=1,col='coral')

health_GB <- subset(health, Country=='Great Britain')
t.test(health_GB$Life_Expectancy)$conf.int[2]

health_USA <- subset(health, Country=='USA')
t.test(health_USA$Life_Expectancy)$conf.int[2]

health_Ger <- subset(health, Country=='Germany')
t.test(health_Ger$Life_Expectancy)$conf.int[2]

# 이원분산분석
# H0 : 주효과와 상호작용 효과는 없다. --> 기각
health.aov <- aov(Life_Expectancy~ Year*Country, data=health)
health.aov
summary(health.aov)

# 다변량 분산분석
# H0 : 나라별 기대 평균 수명과 건강관련 지출 비용은 동일하다. --> p-value <0.05 기각
y <- cbind(health$Life_Expectancy, health$Spending_USD)
aggregate(y,by=list(health$Country), FUN=mean)

health.menova <- manova(y~Country, data=health)

summary(health.menova)

summary.aov(health.menova)

# 카이 제곱 검정 --> 각셀의 기대 빈도 5 이상 실패

health$fac_life <- 1

for (i in 70:84){
  health$fac_life <- ifelse(i<=health$Life_Expectancy & health$Life_Expectancy<i+1,i,health$fac_life)
}

health$fac_life <- as.factor(health$fac_life)
head(health)
str(health)

chisq.test(table(health$Country, health$fac_life))$expected

health$fac_spend <- 1

for (i in seq(0,12000,1000)){
  health$fac_spend <- ifelse(i<=health$Spending_USD & health$Spending_USD<i+1000,i+1000,health$fac_spend)
}
tail(health)

health$fac_spend <- as.factor(health$fac_spend)

chisq.test(table(health$Country, health$fac_spend))$expected

# 상관계수
# H0 : 건강관련 지출 비용과 기대 수명간의 상관계수가 0이다. --> 기각
str(health)
spend_life_cor <- cor.test(~Spending_USD+Life_Expectancy, data=health)
spend_life_cor
spend_life_cor$p.value

library(ggplot2)
ggplot(health, aes(x=Life_Expectancy, y=Spending_USD))+ theme_bw()+
  geom_point(color='skyblue', size=2,shape=20)+ggtitle('기대수명과 건강관련 지출 비용 상관관계')+
  geom_smooth(method=lm, fullrange=T) + xlab('기대수명')+ylab('건강관련 지출 비용')+
  annotate('text',label='cor = 0.58', x =83,y=9000,size=8)

# H0 : 건강관련 지출 비용과 연도간간의 상관계수가 0이다. --> 기각
year_spend_cor <- cor.test(~Spending_USD+Year, data=health)
year_spend_cor
year_spend_cor$p.value

library(ggplot2)
ggplot(health, aes(x=Year, y=Spending_USD))+ theme_bw()+
  scale_x_continuous(limits=c(1970,2020))+
  geom_point(color='skyblue', size=2,shape=20)+ggtitle('기대수명과 건강관련 지출 비용 상관관계')+
  geom_smooth(method=lm, fullrange=T) + xlab('기대수명')+ylab('건강관련 지출 비용')+
  annotate('text',label='cor = 0.83', x =1990,y=6000,size=8)
