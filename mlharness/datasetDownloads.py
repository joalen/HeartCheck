import os
import pandas as pd
import numpy as np
import glob

rename_map = {
    "age_years": "age",
    "gender": "sex",
    "chol": "cholesterol",
    "trestbps": "bp",
    "resting_blood_pressure": "bp",
    "thalach": "max_hr",
    "max_heart_rate": "max_hr",
    "cardio": "target",
    "output": "target",
    'trtbps': 'bp',
    'exng': 'exang',
    'slp': 'slope',
    'caa': 'ca',
    'thalachh': 'max_hr',
    'kcm': 'ck_mb'
}

class DataSet:
    @staticmethod
    def getAndStoreDatasets():
        """ 
        First, we need to download the datasets (for now these are all I got, feel free to add some more if you find any...contributions would be helpful :D)
        """
        dataframes = []

        csv_files = glob.glob(os.path.join("mlharness\\csvs\\", '**', '*.csv'), recursive=True)

        for csv_file in csv_files:
            try:
                df = pd.read_csv(csv_file)
                dataframes.append(df)
            except Exception as e:
                print(f"Failed to read {csv_file}: {e}")

        return dataframes

class DataOperations:
    def normalize(df):
        """ 
        Second, normalize the schemas so that all the datasets have common columns to ensure correctness (again if you can, contribute here and I'd be happy to include more data!)
        """
        df = df.copy()
        df.columns = df.columns.str.lower().str.strip()

        df = df.rename(columns={k: v for k, v in rename_map.items() if k in df.columns}).replace("?", np.nan)

        for c in df.columns:
            if df[c].dtype == "object":
                df[c] = df[c].astype(str)
        
        return df

    def batchNormalize(dfs):
        """ 
        Takes in a list of all dataframes and normalizes them
        """

        return [DataOperations.normalize(df) for df in dfs if df.shape[1] > 1]
    
    def mergeDataFrames(dfs):
        """ 
        Now merge all the dataframes into one
        """
        return pd.concat(dfs, ignore_index=True)

class HeartCheckTrainingDataHarness:
    """ 
    This ML harness utilizes the DataOperations + KaggleDataset classes which helps me to abstract and modularize this 
    codebase for me to improve, tweak, or add features to create more robust ML prediction datasets
    """

    def createHeartcheckTrainingData():
        kaggleDataframes = DataSet.getAndStoreDatasets() # collect all available Kaggle sets we got 
        normalizedDataframes = DataOperations.batchNormalize(kaggleDataframes) # then, we normalize
        mergedDataFrame = DataOperations.mergeDataFrames(normalizedDataframes)

        return mergedDataFrame