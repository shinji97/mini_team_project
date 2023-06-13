import joblib
import numpy as np
import pandas as pd


def convert_to_binary(lst1):
    binary_lst = [0] * 26  # 초기값으로 0으로 채움
    for num in lst1:
        binary_lst[num-1] = 1  # 해당하는 인덱스에 1로 채움
    return binary_lst

def recommand_function(user:list, spec:list,model, df):
    binary_list = convert_to_binary(spec)
    input_value_list = user + binary_list
    proba_array = model.predict_proba([input_value_list])
    top5_array = proba_array.argsort()[0][-5:][::-1]
    top5_list = list(top5_array)
    return df.iloc[top5_list,:]


def table_select(result, num=0):
    result = np.array(result)
    return [result[num][3],result[num][1],result[num][2]]

if __name__ == '__main__':
    model = joblib.load('cgi-bin/model.pkl')
    df = pd.read_csv('cgi-bin/id_info.csv')

    result = recommand_function(user=[1,2,3,7,1], spec=[2,18,23,4,12], model=model, df=df)
    print(result)
    test01 = table_select(result)
    print(test01)
