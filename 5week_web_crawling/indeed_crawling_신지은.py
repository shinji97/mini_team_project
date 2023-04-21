from selenium import webdriver
from bs4 import BeautifulSoup
from selenium.webdriver.common.keys import Keys
import time
import pandas as pd
from urllib.request import urlopen
import matplotlib.pyplot as plt
import spacy
from collections import Counter
from wordcloud import WordCloud
import platform

# 데이터 검색 함수
def search(search_data, title_list,wow, company_list):

    options = webdriver.ChromeOptions()
    options.add_experimental_option('excludeSwitches', ['enable-logging'])
    driver = webdriver.Chrome('5week_web_crawling\chromedriver_win32\chromedriver.exe',options=options)

    driver.get('https://jp.indeed.com/?from=gnav-jobsearch--indeedmobile')

    driver.implicitly_wait(3)

    driver.find_element_by_name('q').send_keys(search_data)
    driver.find_element_by_name('q').send_keys(Keys.ENTER)
    driver.implicitly_wait(3)

    driver.find_element_by_xpath('//*[@id="jobsearch-ViewjobPaneWrapper"]/div/button').click()
    time.sleep(3)

    page_num = page_number(driver.page_source)

    craw(driver.page_source,title_list, company_list, wow)

    driver.find_element_by_xpath('//*[@id="jobsearch-JapanPage"]/div/div/div[5]/div[1]/nav/div[6]/a').send_keys(Keys.ENTER)
    time.sleep(3)

    for i in range(page_num-1):

        craw(driver.page_source,title_list, company_list, wow)

        if len(title_list) ==  150:
            break

        try:
            driver.find_element_by_xpath('//*[@id="jobsearch-JapanPage"]/div/div/div[5]/div[1]/nav/div[7]/a').send_keys(Keys.ENTER)
            time.sleep(3)

        except:
            driver.find_element_by_xpath('//*[@id="mosaic-modal-mosaic-provider-desktopserp-jobalert-popup"]/div/div/div[1]/div/button').click()
            time.sleep(3)
            driver.find_element_by_xpath('//*[@id="jobsearch-JapanPage"]/div/div/div[5]/div[1]/nav/div[7]/a').send_keys(Keys.ENTER)
        
            time.sleep(3)


    print(len(title_list), len(company_list), len(wow))

# 검색후 데이터 페이지 확인 함수
def page_number(url):
    html = url

    soup = BeautifulSoup(html, 'html.parser')

    page_num = soup.find('div',class_='jobsearch-JobCountAndSortPane-jobCount').find('span').text

    real_num = ''

    for i in page_num:
        if i.isnumeric():
            real_num += str(i)

    if int(real_num)% 15 == 0:
        real_num = int(real_num)//15
    else:
        real_num = (int(real_num)//15)+1


    return real_num

# 데이터 크롤링 함수
def craw(url,title_list, company_list, wow):

    html = url
    soup = BeautifulSoup(html, 'html.parser')

    time.sleep(3)

    table_box = soup.find_all('td', class_='resultContent')

    for i in table_box:
        title_list.append(i.find('h2', class_='jobTitle').find('span').text)
        company_list.append(i.find('span', class_='companyName').text)
        try:
            wow.append(i.find('div', class_='metadata').text)
        except:
            wow.append('.')

# 데이터를 csv파일로 저장
def store_csv(title_list,wow,company, keyword):
    
    df = pd.DataFrame({'회사명':company, 'title':title_list, '경력':wow})

    df.to_csv(f'5week_web_crawling/data/indeed_company_{keyword}.csv', encoding='utf-8', index=False)

def main():

    title_list = []
    company_list = []
    wow = []

    keyword = input('검색어를 입력하세요.')


    search(keyword,title_list, wow, company_list)

    store_csv(title_list,wow,company_list, keyword)

    import spacy

    nlp = spacy.load("ja_ginza")

    non_list = []
    

    for i in title_list:
        text = i
        doc = nlp(text)

        for token in doc:
            if token.pos_ == 'NOUN':
                non_list.append(token.text)

    counts = Counter(non_list)
    tags = counts.most_common(40)
    print(tags)




main()
