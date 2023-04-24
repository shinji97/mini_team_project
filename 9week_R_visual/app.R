# 데이터 출처
# - 국가통계포털 KOSIS : https://kosis.kr/index/index.do

# 경로설정
setwd('C:\\Users\\user\\Desktop\\mini_team_project\\mini_team_project\\9week_R_visual')
# getwd()

source('ut.R')
library(shiny)
library(ggplot2)
library(car)
library(lmtest)
library(psych)


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

weight <- cause('data\\weight.csv',weight,c(7:12),'비만')

food <- cause('data\\weight.csv',food,c(9:14),'외식')

# 데이터 불러오기 연령별
cancer.male <-t.cause(sto_cancer,'male')
weight.male <-t.cause(weight,'male')
food.male <-t.cause(food,'male')

cancer.female <-t.cause(sto_cancer,'female')
weight.female <-t.cause(weight,'female')
food.female <-t.cause(food,'female')

# 데이터 불러오기 연도별
cancer.male.year <- year.cause(sto_cancer,'male','위암_총합')
weight.male.year <- year.cause(weight,'male','비만_평균')
food.male.year <- year.cause(food,'male','외식률_평균')

cancer.female.year <- year.cause(sto_cancer,'female','위암_총합')
weight.female.year <- year.cause(weight,'female','비만_평균')
food.female.year <- year.cause(food,'female','외식률_평균')

year.male <- reg.cause(cancer.male.year,weight.male.year,food.male.year,'male',7)
year.female <- reg.cause(cancer.female.year,weight.female.year,food.female.year,'female',7)


# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel('위암 발병 원인'),
  
  sidebarLayout(
    # 왼쪽 부분
    sidebarPanel(
      # 입력 UI
      radioButtons('gender', '성별',c('male','female')),
      sliderInput('year_data','연도를 선택하세요 : ', min=2010,max=2020,value=2020)
    ),
    # 오른쪽 부분
    mainPanel(
      # 출력 UI
      # 성별에 대한 데이터 출력
      dataTableOutput('data_gender'),
      
      # 그래프 출력
      tabsetPanel(
        tabPanel('age', plotOutput('age_gra', height='550px')),
        tabPanel('year', plotOutput('year_gra'))
      )
    )
  ),
  
  
  
  sidebarLayout(
    # 왼쪽 부분
    sidebarPanel(
      selectInput('reg','회귀를 선택하세요 :', list('단순선형회귀'='one','다중회귀분석'='multi'))
    ),
    
    # 오른쪽 부분
    mainPanel(
      tabsetPanel(
        tabPanel('상관분석',verbatimTextOutput('corText')),
        tabPanel('lmSummary',verbatimTextOutput('lmSummary')),
        tabPanel('그래프', plotOutput('corgra'),plotOutput('lmPlot')),
        tabPanel('잔차정규성', verbatimTextOutput('shText')),
        tabPanel('잔차등분산성', verbatimTextOutput('ncvTestt')),
        tabPanel('잔차독립성', verbatimTextOutput('dwtestt'))
        
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output,session) {
  male <- reactive(reg.cause(cancer.male,weight.male,food.male,'male',as.character(input$year_data)))
  female <- reactive(reg.cause(cancer.female,weight.female,food.female,'male',as.character(input$year_data)))
  gender <- reactive(input$gender)
  
  datasetInput <- reactive({switch(gender(),'male'=male(),'female'=female())})
  output$data_gender<-renderDataTable({datasetInput()})
  
  gradataInput <- reactive({switch(gender(),'male'=male(),'female'=female())})
  graInput <- reactive({switch(gender(),'male'=year.male,'female'=year.female)})
  
  output$age_gra <- renderPlot(ggplot(datasetInput(), aes(x=연령,group=1))+
                           geom_bar(aes(y=위암발생),fill='darkgrey',stat='identity')+
                           geom_line(aes(y=비만발생률*70,colour='비만발생률'),size=2)+
                           geom_line(aes(y=외식률*70,colour='외식률'),size=2)+
                           scale_y_continuous(name='위암발생건수',sec.axis = sec_axis(~.*0.015, name="비만발생률"))+
                           xlab('')+
                           ggtitle('위암발생건수와 비만발생률 관계'))
  
  output$year_gra <- renderPlot(ggplot(graInput(), aes(x=시점,group=1))+
                                 geom_bar(aes(y=위암발생),fill='darkgrey',stat='identity')+
                                 geom_line(aes(y=비만발생률*70,colour='비만발생률'),size=2)+
                                 geom_line(aes(y=외식률*70,colour='외식률'),size=2)+
                                 scale_y_continuous(name='위암발생건수',sec.axis = sec_axis(~.*0.015, name="비만발생률"))+
                                 xlab('')+
                                 ggtitle('위암발생건수와 비만발생률 관계'))
  
  regInput <- reactive({switch(input$reg, 'one'=datasetInput()[,c(1,4)], 'multi'=datasetInput())})
  output$corText <- renderPrint({corr.test(regInput())})
  
  reg.one.lm <- reactive(lm(위암발생~연령, data=datasetInput()))
  reg.multi.lm <- reactive(lm(위암발생~., data=datasetInput()))
  reg.lm <- reactive({switch(input$reg, 'one'=reg.one.lm(), 'multi'=reg.multi.lm())})
  
  output$lmSummary <- renderPrint({summary(reg.lm())})
  
  observeEvent(input$reg, {
    if (input$reg == 'one'){
      insertUI(selector = '#lmPlot',where='beforeEnd', ui=plotOutput('corgra'))
    }else{
      removeUI(selector = '#corgra')
    }
  })
  
  output$corgra <- renderPlot(if (input$reg == 'one'){
    ggplot(datasetInput(), aes(x=연령, y=위암발생))+ theme_bw()+
      geom_point(color='skyblue', size=5,shape=20)+ggtitle('나이와 위암의 관계')+
      geom_smooth(method=lm, fullrange=T) + xlab('나이')+ylab('위암 발병 건수')+
      annotate('text',label='cor = 0.97', x =40,y=4500,size=8)})
  
  output$lmPlot <- renderPlot({
    par(mfrow=c(2,2))
    plot(reg.lm())
  })
  
  output$shText <- renderPrint({shapiro.test(resid(reg.lm()))})
  
  output$ncvTestt <- renderPrint({ncvTest(reg.lm())})
  
  output$dwtestt <- renderPrint({dwtest(reg.lm())})
  
}

# Run the application 
shinyApp(ui = ui, server = server)


