"""
classifier.py - runs the prediction classifier responsible for predicting if a user has either no, mild, severe, or clinical heart disease.
"""

__author__  = "Alen Jo"
__copyright__ = "Copyright 2024"
__credits__ = "Alen Jo"
__version__ = "2.0.0"
__status__ = "Stable"

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import joblib
import json 

    
def risk_assessment():
    with open('userdata.json', 'r') as jobj: 
        new_instance = json.load(jobj)

    new_data = pd.DataFrame(new_instance, index=[0])


    with open('model_Mar2024.pkl', 'rb') as model_file:
        rfc = joblib.load(model_file)

    prediction = rfc.predict(new_data)

    match prediction: 
        case 0: 
            return "No"
        case 1: 
            return "Mild"
        case 2: 
            return "Moderate"
        case 3:
            return "Severe"
        case 4: 
            return "Clinical"
        case _:
            return "Unknown"

if __name__ == '__main__':
    risk_assessment()