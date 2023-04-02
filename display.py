"""
display.py - a simple, text-based console that asks the user the various parameters: 
age, gender, chest pain type, resting blood pressure, serum cholesterol, fasting blood sugar, resting ecg results, maximum heart rate, exercise induced angina, ST depression induced by exercise relative to rest, ST segment slope of peak exercise, number of major vessels, thalassemia score, and diagnosis of heart disease (angiographic disease status)
"""

__author__  = "John Luke"
__copyright__ = "Copyright 2023"
__credits__ = ["Alen Jo", "John Luke"]
__version__ = "1.0.0"
__status__ = "Production"

import sys
from classifer import * 
import os 

AGE_RANGE = range(20, 91)
SEX_RANGE = range(0, 2)
CP_RANGE = range(0, 4)
TRESTBPS_RANGE = range(80, 201)
CHOL_RANGE = range(100, 601)
FBS_RANGE = range(0, 2)
RESTECG_RANGE = range(0, 3) 
TALACH_RANGE = range(50, 201)
EXANG_RANGE = range(0, 2)
SLOPE_RANGE = range(0, 3)
CA_RANGE = range(0, 4)
THAL_RANGE = range(1, 4)


def get_input(prompt, input_type, check_type):
    if check_type == 0:
        value = input_type(input(prompt))
        while value not in AGE_RANGE:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value
    elif check_type == 1: 
        value = input_type(input(prompt))
        while value not in SEX_RANGE:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value
    elif check_type == 2: 
        value = input_type(input(prompt))
        while value not in CP_RANGE:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value
    elif check_type == 3: 
        value = input_type(input(prompt))
        while value not in TRESTBPS_RANGE:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value
    elif check_type == 4: 
        value = input_type(input(prompt))
        while value not in CHOL_RANGE:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value
    elif check_type == 5: 
        value = input_type(input(prompt))
        while value not in FBS_RANGE:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value
    elif check_type == 6: 
        value = input_type(input(prompt))
        while value not in RESTECG_RANGE:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value
    elif check_type == 7: 
        value = input_type(input(prompt))
        while value not in TALACH_RANGE:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value
    elif check_type == 8: 
        value = input_type(input(prompt))
        while value not in EXANG_RANGE:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value
    elif check_type == 9: 
        value = input_type(input(prompt))
        while not 0.0 <= value <= 6.0:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value
    elif check_type == 10: 
        value = input_type(input(prompt))
        while value not in SLOPE_RANGE:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value
    elif check_type == 11: 
        value = input_type(input(prompt))
        while value not in CA_RANGE:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value
    elif check_type == 12: 
        value = input_type(input(prompt))
        while value not in THAL_RANGE:
            try:
                value = input_type(input(prompt))
                return value
            except ValueError:
                print("Invalid input. Please try again.")
        return value



def main():
    if (not os.path.exists('prediction_classifier.pkl')):
        create_prediction_classifier()

    user_data = {}

    print("Welcome to the Heart Disease Risk Assessment Tool")

    user_data['age'] = get_input("Enter your age: ", int, 0)
    user_data['sex'] = get_input("Enter your sex (1: male, 0: female): ", int, 1)
    user_data['cp'] = get_input("Enter chest pain type (1: typical angina, 2: atypical angina, 3: non-anginal pain, 4: asymptomatic): ", int, 2)
    user_data['trestbps'] = get_input("Enter resting blood pressure (in mm Hg): ", int, 3)
    user_data['chol'] = get_input("Enter serum cholesterol (in mg/dl): ", int, 4)
    user_data['fbs'] = get_input("Enter fasting blood sugar (> 120 mg/dl, 1: true, 0: false): ", int, 5)
    user_data['restecg'] = get_input("Enter resting electrocardiographic result (0: normal, 1: having ST-T wave abnormality, 2: showing probable or definite left ventricular hypertrophy): ", int, 6)
    user_data['thalach'] = get_input("Enter maximum heart rate achieved: ", int, 7)
    user_data['exang'] = get_input("Enter exercise induced angina (1: yes, 0: no): ", int, 8)
    user_data['oldpeak'] = get_input("Enter ST depression induced by exercise relative to rest: ", float, 9)
    user_data['slope'] = get_input("Enter the slope of the peak exercise ST segment (1: upsloping, 2: flat, 3: downsloping): ", int, 10)
    user_data['ca'] = get_input("Enter the number of major vessels (0-3) colored by flourosopy: ", int, 11)
    user_data['thal'] = get_input("Enter thalassemia status (1: normal, 2: fixed defect, 3: reversible defect): ", int, 12)

    verdict = risk_assessment(user_data)
    print(verdict)

if __name__ == "__main__":
    main()
