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
        for col in rename_map.keys():
            if col in hf.columns:
                hf[col] = hf[col].asfactor()


        hf['target'] = hf['target'].asfactor() # Target as factor for classification
        train, valid, test = hf.split_frame(ratios=[0.7, 0.15], seed=42)

        # AutoML configuration tailored to HeartCheck training data
        aml = H2OAutoML(
            max_models=50, # Try max 50 models
            max_runtime_secs=1200, # 20 minutes
            balance_classes=True, # Handle class imbalance
            nfolds=5, # 5-fold CV
            seed=42,
            sort_metric='AUC', # Optimize for AUC
            stopping_metric='AUC',
            stopping_tolerance=0.001,
            stopping_rounds=3,
            verbosity='info'
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


        # AutoML results (debug only view)
        logger.debug("Top 10 best models: \n%s", aml.leaderboard.head(10))
        logger.debug("Best Model: %s", aml.leader.model_id)
        logger.debug("Model Performance: \n%s", aml.leader.model_performance(test))
        logger.debug("Feature Importance: \n%s", aml.leader.varimp(use_pandas=True).head(10))
        logger.debug("Confusion Matrix: \n%s", aml.leader.model_performance(test).confusion_matrix())
        model_path = h2o.save_model(aml.leader, path="./models", force=True)

        logger.info("Model saved to: %s", model_path)

        h2o.cluster().shutdown()

        return model_path

if __name__ == "__main__":
    H2OAutoMLHarness.train()

