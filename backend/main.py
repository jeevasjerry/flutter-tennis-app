from fastapi import FastAPI
from ultralytics import YOLO
from fastapi import UploadFile, File
import shutil
from backend.inference.pipeline import run_inference


import torch
import os

app = FastAPI()

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

YOLO_MODEL_PATH = os.path.join(BASE_DIR, "yolov8n-pose.pt")
CLASSIFIER_PATH = os.path.join(BASE_DIR, "models", "shot_classifier.pth")

yolo_model = YOLO(YOLO_MODEL_PATH)

@app.get("/")
def root():
    return {
        "status": "Backend running",
        "yolo_loaded": True,
        "yolo_model_path": YOLO_MODEL_PATH,
        "classifier_path": CLASSIFIER_PATH
    }

@app.post("/analyze")
async def analyze_video(video: UploadFile = File(...)):
    temp_dir = "temp"
    os.makedirs(temp_dir, exist_ok=True)

    temp_path = os.path.join(temp_dir, video.filename)

    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(video.file, buffer)

    result = run_inference(temp_path)

    return result
