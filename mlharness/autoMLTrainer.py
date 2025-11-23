from pathlib import Path
import shutil
import h2o
import logging
from h2o.automl import H2OAutoML
from datasetDownloads import HeartCheckTrainingDataHarness, rename_map

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger(__name__)

class H2OAutoMLHarness: 
    def train():
        h2o.init(max_mem_size="4G")
        df = HeartCheckTrainingDataHarness.createHeartcheckTrainingData()
        hf = h2o.H2OFrame(df)

        # categorical encoding
        categorical_cols = ['sex', 'cp', 'slope', 'ca', 'thal', 'exang', 'target']
        for col in categorical_cols:
            if col in hf.columns:
                hf[col] = hf[col].asfactor()


        hf['target'] = hf['target'].asfactor() # Target as factor for classification
        train, valid, test = hf.split_frame(ratios=[0.7, 0.15], seed=42)

        # AutoML configuration tailored to HeartCheck training data
        aml = H2OAutoML(
            max_runtime_secs=14400, # 4-hr to have good hyper-parameter tuning
            balance_classes=True, # Handle class imbalance
            nfolds=5, # 5-fold CV
            seed=42,
            sort_metric='AUCPR',
            stopping_metric='AUC',
            stopping_tolerance=0.001,
            stopping_rounds=5,
            verbosity='info',
            keep_cross_validation_predictions=True
        )

        # Train
        target = 'target'
        features = [c for c in hf.columns if c != target]

        aml.train(
            x=features,
            y=target,
            training_frame=train,
            validation_frame=valid,
            leaderboard_frame=test
        )
        
        model_dir = Path.cwd() / "models"
        model_dir.mkdir(parents=True, exist_ok=True)
        model_path = h2o.save_model(aml.leader, path=str(model_dir), filename="hckpredictor", force=True)
    
        h2o.cluster().shutdown()

        return model_path

if __name__ == "__main__":
    H2OAutoMLHarness.train()

