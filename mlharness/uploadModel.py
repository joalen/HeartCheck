from huggingface_hub import HfApi
import os
import zipfile
from pathlib import Path
import logging

logging.basicConfig(level=logging.DEBUG, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

model_dir = Path("models/hckpredictor")
if not model_dir.exists():
    raise FileNotFoundError(f"Model not found at {model_dir}")

zip_path = "hckpredictpackage.zip"
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for file_path in model_dir.rglob('*'):
        if file_path.is_file():
            zipf.write(file_path, arcname=file_path.relative_to(model_dir.parent))

api = HfApi()
api.upload_file(
    path_or_fileobj=zip_path,
    path_in_repo="hckpredictpackage.zip",
    repo_id="therealstarttoend/heartcheck-prediction",
    repo_type="model",
    token=os.environ["HF_TOKEN"]
)
logger.info("Model uploaded to Hugging Face!")
