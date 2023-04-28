"""
# URL : http://localhost:8080/cgi-bin/fruit-web.py
"""
# 모듈 로딩 ---------------------------------------------------
import cgi, sys, codecs, os
import joblib
from PIL import Image
import numpy as np
import warnings

warnings.filterwarnings('ignore')

# WEB 인코딩 설정 ---------------------------------------------
sys.stdout=codecs.getwriter('utf-8')(sys.stdout.detach())

# 함수 선언 --------------------------------------------------
# WEB 페이지 출력 --------------------------------------------
def displayWEB(detect_msg):
    print("Content-Type: text/html; charset=utf-8")
    print("")
    html="""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Image Upload Example</title>
        <style>
            html {{
                height: 100%;
            }}

            body {{
                font-family: sans-serif;
                height: 100%;
                margin: 0;
            }}

            .container {{
                display: flex;
                height: 100%;
                flex-direction: column;
            }}

            .image-upload {{
                flex: 1;
                display: flex;
                flex-direction: column;
                justify-content: center;
            }}

            .button {{
                display: flex;
                justify-content: center;
            }}

            label {{
                cursor: pointer;
                font-size: 1em;
            }}

            #chooseFile {{
                visibility: hidden;
            }}

            .fileContainer {{
                display: flex;
                justify-content: center;
                align-items: center;
            }}

            .fileInput {{
                display: flex;
                align-items: center;
                border-bottom: solid 2px black;
                width: 60%;
                height: 30px;
            }}

            #fileName {{
                margin-left: 5px;
            }}

            .buttonContainer {{
                width: 15%;
                display: flex;
                justify-content: center;
                align-items: center;
                margin-left: 10px;
                background-color: black;
                color: white;
                border-radius: 30px;
                padding: 10px;
                font-size: 0.8em;

                cursor: pointer;
            }}

            .image-show {{
                z-index: -1;
                display: flex;
                justify-content: center;
                align-items: center;
                position: absolute;
                width: 100%;
                height: 100%;
            }}

            .img {{
                position: absolute;
            }}
        </style>
        
    </head>
    <body>
        <div class="container">
            <div class="image-upload" id="image-upload">

                <form method="post" enctype="multipart/form-data">
                    <div class="button" name ="wow">
                        <label for="chooseFile">
                            👉 파일명을 입력하세요 👈
                        </label>
                    </div>
                    <div style="text-align:center;">
                    <input id="weight" type="text" placeholder="파일명" name="weight">
                    <center><input type="submit" value="판정" class="buttonContainer"></center>
                    </div>
                </form>

                <div class="fileContainer">
                    <br><font color='blue'>{}</font>
                </div>
            </div>
            
            
        </div>

    </body>
    </html>""".format(detect_msg)
    print(html)



# 판정 --------------------------------------------------------
def detect_rtc(img):
    fruit_list = ['apple', 'banana', 'kiwi', 'lemon', 'mango', 'orange', 'pear', 'watermelon']
    sample = Image.open(img).convert('L')
    sample = sample.resize((80,80), Image.ANTIALIAS)
    sample_data= np.array(sample).reshape(1,-1)

    sample_data = sample_data/255

    rtc_pred = best_rtc.predict(sample_data)
    dtc_pred = best_dtc.predict(sample_data)

    return fruit_list[rtc_pred[0]], fruit_list[dtc_pred[0]]

# 기능 구현 -----------------------------------------------------
# (1) 학습 데이터 읽기
rtc_pklfile = os.path.dirname(__file__) + "/best_rfc.pkl"
best_rtc = joblib.load(rtc_pklfile)
dtc_pklfile = os.path.dirname(__file__) + "/best_dtc.pkl"
best_dtc = joblib.load(dtc_pklfile)

# (2) WEB 페이지 <Form> -> <INPUT> 리스트 가져오기
form = cgi.FieldStorage()
img_value = form.getvalue('fileName')
weight_value = form.getvalue('weight')

# (3) 판정 하기
if weight_value is not None:
    rtc_result = detect_rtc(weight_value)
    result = f'RandomForest 예측결과 {rtc_result[0]}, DecisionTree 에측결과 {rtc_result[1]}'

else:
    result =f'{img_value} 측정된 결과가 없습니다.'

# (4) WEB 출력하기
displayWEB(result)


