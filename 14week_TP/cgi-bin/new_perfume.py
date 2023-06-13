"""
# URL : http://localhost:8080/cgi-bin/new_perfume.py
"""

# 모듈 로딩 ---------------------------------------------------
import cgi, sys, codecs, os
import joblib
import numpy as np
import pandas as pd
import warnings
import my_utils

warnings.filterwarnings('ignore')

# WEB 인코딩 설정 ---------------------------------------------
sys.stdout=codecs.getwriter('utf-8')(sys.stdout.detach())

# 함수 선언 --------------------------------------------------
# WEB 페이지 출력 --------------------------------------------
def displayWEB(img_path,first_brand, first_item, first_price, data2_img,data2_brand, data2_item,data3_img,data3_brand,data3_item,data4_img,data4_brand,data4_item,data5_img,data5_brand,data5_item):
    print("Content-Type: text/html; charset=utf-8")
    print("")
    html="""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>향수 추천</title>
        <link href="../css/perfume_new.css" rel="stylesheet" type="text/css">
    </head>

    <body>

        <div id="header">
            <img src="../img/new_header.jpg", width="100%"; height=70px>
        </div>
        
        <div id="fullscreen">
            <div id="my_input">

                <form method="post" enctype="multipart/form-data">
                    <div id="brand">
                        <br>
                        <h5>브랜드<br>
                            Brand</h5>
                        <img src="../img/brand_logo.gif" style="width:150px; height:100px;"><br><br>
                        <select id="brandname" name="brandname">
                            <option value="">브랜드</option>
                            <option value=1>딥디크</option>
                            <option value=2>조말론</option>
                            <option value=3>바이레도</option>
                            <option value=4>이솝</option>
                            <option value=5>톰포드</option>
                            <option value=6>프레데릭말</option>
                            <option value=7>퍼퓸드말리</option>
                            <option value=8>조보이</option>
                            <option value=9>제로보암</option>
                            <option value=10>오케스트라퍼퓸</option>
                            <option value=11>이니시오</option>
                            <option value=12>메모</option>
                            <option value=13>알마프</option>
                            <option value=14>아프난</option>
                            <option value=15>크리드</option>
                            <option value=16>나소마토</option>
                            <option value=17>산타마리아노벨라</option>
                            <option value=18>디올</option>
                            <option value=19>샤넬</option>
                            <option value=20>자라</option>
                            <option value=21>에따리브르도랑쥬</option>
                            <option value=22>모스키노</option>
                            <option value=23>아이젠버그</option>
                            <option value=24>메종마르지엘라</option>
                            <option value=25>밀러해리스</option>
                            <option value=26>아쿠아디파르마</option>
                            <option value=27>쇼파드</option>
                            <option value=28>르라보</option>
                            <option value=29>티지아나테렌지</option>
                            <option value=30>메종프란시스커정</option>
                            <option value=31>메종크리벨리</option>
                            <option value=32>킬리안</option>
                            <option value=33>라리크</option>
                            <option value=34>펜할리곤스</option>
                            <option value=35>에르메스</option>
                            <option value=36>반클리프앤아펠</option>
                            <option value=37>히스토리드퍼퓸</option>
                            <option value=38>프레드릭엠</option>
                            <option value=39>4160튜즈데이</option>
                            <option value=40>꼼데가르송</option>
                            <option value=41>버버리</option>
                            <option value=42>파코라반</option>
                            <option value=43>돌체앤가바나</option>
                            <option value=44>제르조프</option>
                            <option value=45>랑방</option>
                            <option value=46>패리스힐튼</option>
                            <option value=47>입생로랑</option>
                            <option value=48>지미추</option>
                            <option value=49>MDCI</option>
                            <option value=50>BDK</option>
                            <option value=51>로이비</option>
                            <option value=52>불리</option>
                            <option value=53>키엘</option>
                            <option value=54>셀린느</option>
                            <option value=55>니콜라이</option>
                            <option value=56>NCP</option>
                            <option value=57>에어린</option>
                            <option value=58>마크안토니바로스</option>
                            <option value=59>오리베</option>
                            <option value=60>구딸</option>
                            <option value=61>아르마니프리베</option>
                            <option value=62>퍼퓸드엠파이어</option>
                            <option value=63>겔랑</option>
                            <option value=64>루이비통</option>
                            <option value=65>조러브스</option>
                            <option value=66>로자</option>
                            <option value=67>오르몽드제인</option>
                            <option value=68>카너바르셀로나</option>
                            <option value=69>아무아쥬</option>
                            <option value=70>만세라</option>
                            <option value=71>몽탈</option>
                            <option value=72>아뜰리에데조</option>
                            <option value=73>클라이브크리스찬</option>
                        </select>
                        <br>             
                    </div>
                
                    <div id="gender">
                        <br>
                        <h5>남성적 & 여성적<br>
                            masculine & feminine</h5>
                        <select id="gendername" name="gendername">
                            <option value="">향의 성별</option>
                            <option value=1>여성</option>
                            <option value=2>남성</option>
                            <option value=3>중성</option>
                        </select>
                        <br>
                    </div>

                    <div id="tpo">
                        <br>
                        <h5>캐주얼 & 포멀<br>
                            casual & Formal</h5>
                        <select id="tponame" name="tponame">
                            <option value="">T.P.O</option>
                            <option value=1>캐쥬얼</option>
                            <option value=2>포멀</option>
                            <option value=3>캐쥬얼,포멀</option>
                        </select>
                        <br>
                    </div>

                    <div id="season">
                        <br>
                        <h5>계절감<br>
                            sense of the season</h5>
                        <select id="seasonname" name="seasonname">
                            <option value="">계절감</option>
                            <option value=1>봄,여름</option>
                            <option value=2>봄,가을</option>
                            <option value=3>봄,여름,가을</option>
                            <option value=4>봄,가을,겨울</option>
                            <option value=5>여름,가을,겨울</option>
                            <option value=6>가을,겨울</option>
                            <option value=7>사계절</option>
                        </select>
                        <br>           
                    </div>

                    <div id="level">
                        <br>
                        <h5>향의 농도<br>
                            concentration of incense</h5>
                        <select id="levelname" name="levelname">
                            <option value="">향의농도</option>
                            <option value=1>가벼운</option>
                            <option value=2>무거운</option>
                            <option value=3>중간</option>
                        </select> 
                        <br>           
                    </div>

                    <div id="feature">
                        <br>
                        <h5>향의 느낌(5개 선택해주세요)<br>
                        scent of incense</h5>

                        <input type="checkbox" name="featurename" value=1>플로럴<br>
                        <input type="checkbox" name="featurename" value=2>그린<br>
                        <input type="checkbox" name="featurename" value=3>우디<br>
                        <input type="checkbox" name="featurename" value=4>얼씨<br>
                        <input type="checkbox" name="featurename" value=5>프루티<br>
                        <input type="checkbox" name="featurename" value=6>프레쉬<br>
                        <input type="checkbox" name="featurename" value=7>시트러스<br>
                        <input type="checkbox" name="featurename" value=8>머스크<br>
                        <input type="checkbox" name="featurename" value=9>파우더리<br>
                        <input type="checkbox" name="featurename" value=10>민트<br>
                        <input type="checkbox" name="featurename" value=11>부지<br>
                        <input type="checkbox" name="featurename" value=12>마린<br>
                        <input type="checkbox" name="featurename" value=13>코코넛<br>
                        <input type="checkbox" name="featurename" value=14>스파이시<br>
                        <input type="checkbox" name="featurename" value=15>앰버<br>
                        <input type="checkbox" name="featurename" value=16>레더<br>
                        <input type="checkbox" name="featurename" value=17>아로마틱<br>
                        <input type="checkbox" name="featurename" value=18>로즈<br>
                        <input type="checkbox" name="featurename" value=19>스모키<br>
                        <input type="checkbox" name="featurename" value=20>타바코<br>
                        <input type="checkbox" name="featurename" value=21>바닐라<br>
                        <input type="checkbox" name="featurename" value=22>라벤더<br>
                        <input type="checkbox" name="featurename" value=23>워터리<br>
                        <input type="checkbox" name="featurename" value=24>너티<br>
                        <input type="checkbox" name="featurename" value=25>메탈릭<br>
                        <input type="checkbox" name="featurename" value=26>프랄린
                        <br><br>
                    </div>

                    <div id="button">
                        <center><input type="submit" value="판정" class="buttonContainer"></center>
                    </div>
                </form>
                            
            </div>

            <div id="predict_all">
                <div id="first_predict">

                    <div id="predict_img">
                        <br><br><br><br><br><br><br>
                        <img src={} style="width:300px; height:400px;">
                    </div>

                    <div id="first_data">

                        <br><br><br><br><br><br><br><br><br><br>
                        <h3>브랜드명 : {}</h3><br><br>

                        <h3>제품명 : {}</h3><br><br>

                        <h3>가격 : {}</h3>

                    </div>
                </div>

                <hr>

                <div id="other_predict">
                    <br><br><br><br><br><br>
                    <div class="predicts">
                        <cendter><img src={} style="width:200px; height:300px;"><br>
                        <h3>2. {} - {}</h3>
                        <center>
                    </div>

                    <div class="predicts">
                        <cendter><img src={} style="width:200px; height:300px;"><br>
                        <h3>3. {} - {}</h3>
                        <center>
                    </div>

                    <div class="predicts">
                        <cendter><img src={} style="width:200px; height:300px;"><br>
                        <h3>4. {} - {}</h3>
                        <center>
                    </div>

                    <div class="predicts">
                        <cendter><img src={} style="width:200px; height:300px;"><br>
                        <h3>5. {} - {}</h3>
                        <center>
                    </div>

                </div>
            </div>
        </div>
        <div id="info_box">
                <center>
                <a href="http://www.instagram.com/iou_scent" target="_blank"><img src="../img/insta.png" style="width:50px; height:50px;"></a>
                <img src="../img/white.jpg" style="width:30px; height:50px;">
                <a href="https://m.blog.naver.com/y2kjd" target="_blank"><img src="../img/blog.png" style="width:50px; height:50px;"></a>
                </center>

        </div>

    </body>
    
    </html>""".format(img_path,first_brand, first_item,first_price,data2_img,data2_brand,data2_item,data3_img,data3_brand,data3_item,data4_img,data4_brand,data4_item,data5_img,data5_brand,data5_item)
    print(html)


# 판정 --------------------------------------------------------

# 기능 구현 -----------------------------------------------------
# (1) 학습 데이터 읽기
model_pklfile = os.path.dirname(__file__) + "/model.pkl"
model = joblib.load(model_pklfile)

perfume_path = os.path.dirname(__file__) + "/id_info.csv"
perfume_info = pd.read_csv(perfume_path)

# (2) WEB 페이지 <Form> -> <INPUT> 리스트 가져오기
form = cgi.FieldStorage()
brand_value = form.getvalue('brandname')
gender_value = form.getvalue('gendername')
tpo_value = form.getvalue('tponame')
season_value = form.getvalue('seasonname')
level_value = form.getvalue('levelname')
feature_value = form.getvalue('featurename')

# (3) 판정 하기

data = [brand_value, gender_value, tpo_value, season_value, level_value]

# (4) 데이터 가져오기

if brand_value is not None:

    feature_data = map(int,feature_value)

    result = my_utils.recommand_function(user=data, spec=feature_data, model=model, df=perfume_info)

    first_data = my_utils.table_select(result)
    data2 = my_utils.table_select(result, num=1)
    data3 = my_utils.table_select(result, num=2)
    data4 = my_utils.table_select(result, num=3)
    data5 = my_utils.table_select(result, num=4)

    first_brand = first_data[0]
    first_item = first_data[1]
    first_price = first_data[2]

    img_path = f"../img/{first_item.strip()}.jpg"
    data2_path = f"../img/{data2[1].strip()}.jpg"
    data3_path = f"../img/{data3[1].strip()}.jpg"
    data4_path = f"../img/{data4[1].strip()}.jpg"
    data5_path = f"../img/{data5[1].strip()}.jpg"


else:
    img_path = "../img/white.jpg"
    data2_path = "../img/white.jpg"
    data3_path = "../img/white.jpg"
    data4_path = "../img/white.jpg"
    data5_path = "../img/white.jpg"
    first_brand = ""
    first_item = ""
    first_price = ""
    for i in range(2,6):
        globals()[f'data{i}'] = [""]*3

# (5) WEB 출력하기
displayWEB(img_path,first_brand, first_item, first_price,data2_path,data2[0],data2[1],data3_path,data3[0],data3[1],data4_path,data4[0],data4[1],data5_path,data5[0],data5[1])