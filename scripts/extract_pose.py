import os
import cv2
import numpy as np
from ultralytics import YOLO
from tqdm import tqdm

# Load YOLOv8 pose model
model = YOLO("yolov8n-pose.pt")

RAW_DIR = "data/raw_videos"
OUT_DIR = "data/processed_keypoints"

os.makedirs(OUT_DIR, exist_ok=True)

def extract_pose_from_video(video_path, save_path):
    cap = cv2.VideoCapture(video_path)
    sequence = []

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        results = model(frame, conf=0.5, verbose=False)

        if results[0].keypoints is not None:
            keypoints = results[0].keypoints.xy.cpu().numpy()

            if len(keypoints) > 0:
                # Take the main (closest) player
                kpts = keypoints[0]        # shape (17, 2)
                sequence.append(kpts.flatten())  # shape (34,)

    cap.release()

    if len(sequence) > 0:
        np.save(save_path, np.array(sequence))

# Process all classes
for label in ["forehand", "backhand", "serve"]:
    in_dir = os.path.join(RAW_DIR, label)
    out_dir = os.path.join(OUT_DIR, label)
    os.makedirs(out_dir, exist_ok=True)

    for video in tqdm(os.listdir(in_dir), desc=f"Processing {label}"):
        video_path = os.path.join(in_dir, video)
        save_path = os.path.join(out_dir, video.replace(".mp4", ".npy"))
        extract_pose_from_video(video_path, save_path)

print("✅ Pose extraction completed successfully")