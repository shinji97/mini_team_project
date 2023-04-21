from selenium import webdriver
from bs4 import BeautifulSoup
from selenium.webdriver.common.keys import Keys
import time
import pandas as pd
from urllib.request import urlopen
from konlpy.tag import Okt
from collections import Counter
from wordcloud import WordCloud
import matplotlib.pyplot as plt
import platform


# 데이터 검색 함수
def search(search_data, title_list, date, company, country):

    options = webdriver.ChromeOptions()
    options.add_experimental_option('excludeSwitches', ['enable-logging'])
    driver = webdriver.Chrome('5week_web_crawling\chromedriver_win32\chromedriver.exe',options=options)

    driver.get('https://www.saramin.co.kr/zf_user/')

    driver.implicitly_wait(3)

    driver.find_element_by_id('btn_search').click()
    driver.find_element_by_id('ipt_keyword_recruit').send_keys(search_data)
    driver.find_element_by_id('btn_search_recruit').click()

    driver.find_element_by_xpath('//*[@id="content"]/ul[1]/li[2]/a').click()
    driver.implicitly_wait(3)

    page_number = page_num(driver.page_source)

    count = 2
    idx = 1

    while True:
        
        if count < 13:
            if idx == 11:
                idx = 2
        
        else:
            if idx == 12:
                idx=2

        driver.find_element_by_xpath(f'//*[@id="recruit_info_list"]/div[2]/div/a[{idx}]').send_keys(Keys.ENTER)

        # print(count, idx)

        html = driver.page_source
        soup = BeautifulSoup(html,'html.parser')
        
        time.sleep(3)
        sq = soup.find_all('div', class_='item_recruit')

        for i in sq:
            title_list.append(i.find('h2', class_='job_tit').find('span').text)
            date.append(i.find('span', class_='date').text)
            country.append(i.find('div', class_='job_condition').find('a').text[:2])
            company_name = i.find('a', class_='track_event data_layer').text.replace(' ','')
            company.append(company_name.replace('\n',''))

        idx += 1
        count += 1


        if count == (page_number+1):
            break

    html = driver.page_source
    soup = BeautifulSoup(html,'html.parser')
        
    time.sleep(3)
    sq = soup.find_all('div', class_='item_recruit')

    for i in sq:
        title_list.append(i.find('h2', class_='job_tit').find('span').text)
        date.append(i.find('span', class_='date').text)
        country.append(i.find('div', class_='job_condition').find('a').text[:2])
        company_name = i.find('a', class_='track_event data_layer').text.replace(' ','')
        company.append(company_name.replace('\n',''))
        # company.append(i.find('a', class_='track_event data_layer').text)


    print(len(title_list), len(company), len(date), len(country))

# 검색후 데이터 페이지 확인 함수
def page_num(url):
    html = url
    soup = BeautifulSoup(html,'html.parser')

    page_num = soup.find('span', class_='cnt_result').text
    real_num = ''

    for i in page_num:
        if i.isnumeric():
            real_num += i

    if int(real_num)% 40 == 0:
        real_num = int(real_num)//40
    else:
        real_num = (int(real_num)//40)+1

    return real_num

# wordcloud 그래프 함수
def gra(title_list, top, keyword):
    okt = Okt()

    sentences_tag = []

    for setnece in title_list:
        morph = okt.pos(setnece)
        sentences_tag.append(morph)


    noun_adj_list = []

    for sentence1 in sentences_tag:
        for word, tag in sentence1:
            if tag in ['Noun', 'Adjective']:
                noun_adj_list.append(word)

    # 형태소별 count
    counts = Counter(noun_adj_list)
    tags = counts.most_common(top)



    # wordCloud생성
    # 한글꺠지는 문제 해결하기위해 font_path 지정
    if platform.system() == 'Windows':
        path = r'c:\Windows\Fonts\malgun.ttf'
    elif platform.system() == 'Darwin':  # Mac OS
        path = r'/System/Library/Fonts/AppleGothic'
    else:
        path = r'/usr/share/fonts/truetype/name/NanumMyeongjo.ttf'

    from PIL import Image
    import numpy as np
    

    cloud_mask = np.array(Image.open("5week_web_crawling\\cloud.png"))

    wc = WordCloud(font_path=path,colormap='PuRd',background_color='white', width=800, height=600, mask = cloud_mask)
    
    print(dict(tags))
    cloud = wc.generate_from_frequencies(dict(tags))
    plt.figure(figsize=(10, 8))
    plt.axis('off')
    plt.imshow(cloud)

    plt.savefig(f'5week_web_crawling/data/company_{keyword}.png')
    plt.show()




# 데이터 크롤링 함수
def craw(url, title_list, date, country, company):
    html = url
    soup = BeautifulSoup(html,'html.parser')
        
    time.sleep(3)
    sq = soup.find_all('div', class_='item_recruit')

    for i in sq:
        title_list.append(i.find('h2', class_='job_tit').find('span').text)
        date.append(i.find('span', class_='date').text)
        country.append(i.find('div', class_='job_condition').find('a').text[:2])
        company_name = i.find('a', class_='track_event data_layer').text.replace(' ','')
        company.append(company_name.replace('\n',''))


# 데이터를 csv파일로 저장
def store_csv(keyword,title_list,date,country,company):
    
    df = pd.DataFrame({'회사명':company, 'title':title_list, '날짜':date, '지역':country})
    df.to_csv(f'5week_web_crawling/data/company_{keyword}.csv', encoding='utf-8', index=False)

def main():

    title_list = []
    company = []
    date = []
    country = []

    keyword = input('검색어를 입력하세요.')
    top = int(input('상위 개수 : '))

    search(keyword,title_list, date, company, country)

    store_csv(keyword,title_list,date,country,company)

    gra(title_list, top, keyword)

main()

