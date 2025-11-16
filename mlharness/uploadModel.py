from huggingface_hub import HfApi
import os
import zipfile
import glob
import logging

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger(__name__)

model_dir = glob.glob("models/*")[0]

zip_path = "hckpredictpackage.zip"
with zipfile.ZipFile(zip_path, 'w') as zipf:
    for root, dirs, files in os.walk(model_dir):
        for file in files:
            zipf.write(os.path.join(root, file))

api = HfApi()
api.upload_file(
    path_or_fileobj=zip_path,
    path_in_repo="hckpredictpackage.zip",
    repo_id="therealstarttoend/heartcheck-predictor",
    repo_type="model",
    token=os.environ["HF_TOKEN"]
)

logger.info("Model updated to Hugging Face!")