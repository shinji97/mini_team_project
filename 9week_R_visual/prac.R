# 데이터 출처
# - 국가통계포털 KOSIS : https://kosis.kr/index/index.do

# 경로설정
setwd('C:\\Users\\user\\Desktop\\mini_team_project\\mini_team_project\\9week_R_visual')
# getwd()

cancer <- read.csv('data\\cancer.csv')

colnames(cancer)

sto_cancer <- subset(cancer, X24개.암종별=='위(C16)')

sto_cancer <- sto_cancer[,c(2:3,8:21)]

head(sto_cancer)

for (i in 2:ncol(sto_cancer)){
  sto_cancer[,i] <- as.numeric(sto_cancer[,i])
}

str(sto_cancer)
sto_cancer$위암_20대 <- apply(sto_cancer[,c(3,4)],1,sum)
sto_cancer$위암_30대 <- apply(sto_cancer[,c(5,6)],1,sum)
sto_cancer$위암_40대 <- apply(sto_cancer[,c(7,8)],1,sum)
sto_cancer$위암_50대 <- apply(sto_cancer[,c(9,10)],1,sum)
sto_cancer$위암_60대 <- apply(sto_cancer[,c(11,12)],1,sum)
sto_cancer$위암_70대이상 <- apply(sto_cancer[,c(13:16)],1,sum)

sto_cancer <- sto_cancer[,c(1,2,17:ncol(sto_cancer))]
str(sto_cancer)


source('ut.R')
weight <- cause('data\\weight.csv',weight,c(7:12),'비만')

weight.year <- weight[c(1:11),-1]
weight.year$위암_총합 <- round(apply(weight.year[,-1],1,mean),2)
weight.year




food <- cause('data\\weight.csv',weightt,c(9:14),'외식')
str(food)

# 데이터 불러오기 연령별
cancer.male <-t.cause(sto_cancer,'male')
weight.male <-t.cause(weight,'male')
food.male <-t.cause(food,'male')

cancer.female <-t.cause(sto_cancer,'female')
weight.female <-t.cause(weight,'female')
food.female <-t.cause(food,'female')

# 2020, 남자 데이터
reg2020.male<-reg.cause(cancer.male,weight.male,food.male,'male','2020')
str(reg2020.male)

library(ggplot2)
ggplot(reg2020.male, aes(x=연령,group=1))+
  geom_bar(aes(y=위암발생),fill='darkgrey',stat='identity')+
  geom_line(aes(y=비만발생률*55,colour='비만발생률'),size=2)+
  geom_line(aes(y=외식률*55,colour='외식률'),size=2)+
  scale_y_continuous(name='위암발생건수',sec.axis = sec_axis(~.*0.02, name="비만발생률"))+
  xlab('')+
  ggtitle('위암발생건수와 비만발생률 관계')

write.csv(reg2020.male[,-4], file='data//reg2020_male.csv')

# 2020, 여자 데이터
reg2020.female <- reg.cause(cancer.female,weight.female,food.female,'female','2020')
str(reg2020.female)

write.csv(reg2020.female[,-4], file='data//reg2020_female.csv')

# 정규성 테스트
shapiro.test(reg2020.male[,1])
shapiro.test(reg2020.male[,2])
shapiro.test(reg2020.male[,3])

# 컬럼별 정규성 확인
par(mfrow=c(3,2))
for (i in colnames(reg2020.male)[-4]){
  qqnorm(reg2020.male[,i], main=paste(i, 'Normal Q-Q Plot'))
  qqline(reg2020.male[,i], col='red',lwd=2)
  
  hist(reg2020.male[,i], freq=FALSE, main=paste(i, 'Histogram'),xlab=i)
  lines(density(reg2020.male[,i]),col='red',lwd=2)
}

# 상관계수
library(psych)
corr.test(reg2020.male)

library(ggplot2)
ggplot(reg2020.male, aes(x=연령, y=위암발생))+ theme_bw()+
  geom_point(color='skyblue', size=5,shape=20)+ggtitle('나이와 위암의 관계')+
  geom_smooth(method=lm, fullrange=T) + xlab('나이')+ylab('위암 발병 건수')+
  annotate('text',label='cor = 0.97', x =40,y=4500,size=8)

reg2020.lm <- lm(위암발생~연령, data=reg2020.male)
summary(reg2020.lm)

# ------------------------------------------------------------------------------
# 잔차 검정
# - 선 행 성
# - 정 규 성 : shapiro.test()
# - 등분산성 : ncvTest()       <- car 패키지
# - 독 립 성 : dwtest()        <- lmtest 패키지
# ------------------------------------------------------------------------------
# (1) 모델에 대한 검정 그래프 출력
par(mfrow=c(2,2))
plot(reg2020.lm)
# 1- 잔차와 예측값간의 관계,선형성 충족하려면 패턴 존재x
# 2- 잔차의 정규성
# 3- 등분산성 수평 추세선으로 관찰 -> 실패
# 4- 주의를 기울일 필요있는 관측값

# (2) 함수기반 수치값 검정
# (2-1) 정규성
shapiro.test(resid(reg2020.lm))

# (2-2)  등분산성
library(car)
ncvTest(reg2020.lm)
#  p-value > 0.05면 등분산성을 만족

# (2-3) 독립성
# install.packages('lmtest')
library(lmtest)

dwtest(reg2020.lm)
# p-value > 0.05 -> 독립성 만족

# 다중회귀 분석
multi.lm <- lm(위암발생~., data=reg2020.male)
summary(multi.lm)


# ------------------------------------------------------------------------------
# 잔차 검정
# - 선 행 성
# - 정 규 성 : shapiro.test()
# - 등분산성 : ncvTest()       <- car 패키지
# - 독 립 성 : dwtest()        <- lmtest 패키지
# ------------------------------------------------------------------------------
# (1) 모델에 대한 검정 그래프 출력
par(mfrow=c(2,2))
plot(multi.lm)
# 1- 잔차와 예측값간의 관계,선형성 충족하려면 패턴 존재x
# 2- 잔차의 정규성
# 3- 등분산성 수평 추세선으로 관찰 -> 실패
# 4- 주의를 기울일 필요있는 관측값

# (2) 함수기반 수치값 검정
# (2-1) 정규성
shapiro.test(resid(multi.lm))

# (2-2)  등분산성
library(car)
ncvTest(multi.lm)
#  p-value > 0.05면 등분산성을 만족

# (2-3) 독립성
# install.packages('lmtest')
library(lmtest)

dwtest(multi.lm)
# p-value > 0.05 -> 독립성 만족



