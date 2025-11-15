import os
import kagglehub
import pandas as pd
import chardet
import csv 

def retrieveAvailableDatasets():
    """ 
    A text file is made for easy bookkeeping of potential datasets (for now...I'd need to come up with some sort of "watcher" to look out for these)
    """
    availableDatasets = []

    with open("mlharness\\datasets.txt", 'r') as datasetFile: 
        availableDatasets = datasetFile.readlines()

    return availableDatasets

class KaggleDataset:
    @staticmethod
    def __autoDetectCSVDataset(filePath):
        with open(filePath, 'rb') as f:
            raw = f.read(20000)  # sample
            enc = chardet.detect(raw)['encoding'] or 'utf-8'

        with open(filePath, 'r', encoding=enc, errors='ignore') as f:
            sample = f.read(20000)
            try:
                dialect = csv.Sniffer().sniff(sample)
                delimiter = dialect.delimiter
                has_header = csv.Sniffer().has_header(sample)
            except Exception:
                delimiter = ','
                has_header = True      

        try:
            df = pd.read_csv(
                filePath,
                sep=delimiter,
                encoding=enc,
                header=0 if has_header else None,
                engine='python'
            )
        except Exception:
            df = pd.read_csv(filePath, engine='python') # fallback into letting pandas do the heavy work

        return df


    @staticmethod
    def getAndStoreKaggleDatasets():
        """ 
        First, we need to download the datasets (for now these are all I got, feel free to add some more if you find any...contributions would be helpful :D)
        """
        dataframes = [] 

        for datasetPath in retrieveAvailableDatasets():
            path = kagglehub.dataset_download(datasetPath.replace("\n", ""))
            csvs = [f for f in os.listdir(path) if f.lower().endswith(".csv")]

            if not csvs:
                continue 

            for csv in csvs:
                dataframes.append(KaggleDataset.__autoDetectCSVDataset(os.path.join(path, csv)))

        return dataframes

class DataOperations:
    def normalize(df):
        """ 
        Second, normalize the schemas so that all the datasets have common columns to ensure correctness (again if you can, contribute here and I'd be happy to include more data!)
        """
        df = df.copy()
        df.columns = df.columns.str.lower().str.strip()

        rename_map = {
            "age_years": "age",
            "gender": "sex",
            "chol": "cholesterol",
            "trestbps": "bp",
            "resting_blood_pressure": "bp",
            "thalach": "max_hr",
            "max_heart_rate": "max_hr",
            "cardio": "target",
            "output": "target"
        }
        df = df.rename(columns={k: v for k, v in rename_map.items() if k in df.columns})
        return df

    def batchNormalize(dfs):
        """ 
        Takes in a list of all dataframes and normalizes them
        """

        return [DataOperations.normalize(df) for df in dfs]

    def keepCommonColumns(dfs):
        """ 
        Third, we keep shared columns across all datasets
        """
        commonCols = list(set.intersection(*(set(df.columns) for df in dfs)))
        return [df[commonCols] for df in dfs]
    
    def mergeDataFrames(dfs):
        """ 
        Now merge all the dataframes into one
        """
        return pd.concat(dfs, ignore_index=True)

class HeartCheckMLHarness:
    """ 
    This ML harness utilizes the DataOperations + KaggleDataset classes which helps me to abstract and modularize this 
    codebase for me to improve, tweak, or add features to create more robust ML prediction datasets
    """

    def createHeartcheckTrainingData():
        kaggleDataframes = KaggleDataset.getAndStoreKaggleDatasets() # collect all available Kaggle sets we got 
        normalizedDataframes = DataOperations.batchNormalize(kaggleDataframes) # then, we normalize
        mergedDataFrame = DataOperations.mergeDataFrames(DataOperations.keepCommonColumns(normalizedDataframes))

        return mergedDataFrame