"""
classifier.py - creates, runs, and stores the prediction classifier responsible for predicting if a user has heart disease. We utilize archive.ics.uci.edu's cleveland data (may switch to a more reliable source)
"""

__author__  = "Alen Jo"
__copyright__ = "Copyright 2023"
__credits__ = ["Alen Jo", "John Luke"]
__version__ = "1.0.0"
__status__ = "Production"


import numpy as np
import pandas as pd
import requests
import io
import lightgbm as lgb
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import pickle
import os 

def create_prediction_classifier():
    url = 'https://archive.ics.uci.edu/ml/machine-learning-databases/heart-disease/processed.cleveland.data'
    s = requests.get(url).content
    data = pd.read_csv(io.StringIO(s.decode('utf-8')), header=None)
    data = data.replace('?', np.nan)
    data = data.dropna()

    data[11] = pd.to_numeric(data[11])
    data[12] = pd.to_numeric(data[12])

    X = data.iloc[:, :-1]
    y = data.iloc[:, -1]

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    params = {
        'objective': 'multiclass',
        'num_class': 5,
        'metric': 'multi_logloss',
        'boosting_type': 'gbdt',
        'num_leaves': 31,
        'learning_rate': 0.05,
        'feature_fraction': 0.9,
        'bagging_fraction': 0.8,
        'bagging_freq': 5,
        'verbose': 0,
        'n_jobs': -1
    }

    model = lgb.LGBMClassifier(**params)

    model.fit(X_train, y_train)

    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred, average='weighted') 
    recall = recall_score(y_test, y_pred, average='weighted')
    f1 = f1_score(y_test, y_pred, average='weighted') 

    with open('prediction_classifier.pkl', 'wb') as classifier_export:
        pickle.dump(model, classifier_export)

    if (accuracy >= 0.80 and precision >= 0.80 and recall >= 0.80 and f1 >= 0.80):
        print("Model is very good; no further action required!") 
    else:
        print("Model is not good; retraining required or a new dataset!")


def risk_assessment(params):
    new_instance = {'age': params["age"],
                    'sex': params['sex'],
                    'cp': params['cp'],
                    'trestbps': params['trestbps'],
                    'chol': params['chol'] ,
                    'fbs': params['fbs'],
                    'restecg': params['restecg'],
                    'thalach': params['thalach'],
                    'exang': params['exang'],
                    'oldpeak': params['oldpeak'],
                    'slope': params['slope'],
                    'ca': params['ca'],
                    'thal': params['thal']
                   }


    new_data = pd.DataFrame(new_instance, index=[0])

    loaded_model = pickle.load(open("prediction_classifier.pkl", 'rb'))
    prediction = loaded_model.predict(new_data)

    for i in prediction: 
        if (i == 0): 
            return "Individual does not have heart disease"
        elif (i == 1): 
            return "Individual has heart disease"
        else: 
            return "Could not determine"
