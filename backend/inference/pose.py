import numpy as np
from ultralytics import YOLO
import cv2

pose_model = YOLO("models/yolov8n-pose.pt")

def extract_pose_features(video_path, max_frames=30):
    cap = cv2.VideoCapture(video_path)
    features = []

    while cap.isOpened() and len(features) < max_frames:
        ret, frame = cap.read()
        if not ret:
            break

        results = pose_model(frame, verbose=False)
        if results and results[0].keypoints is not None:
            kp = results[0].keypoints.xy[0].cpu().numpy()  # (17, 2)
            features.append(kp.flatten())  # → 34

    cap.release()

    if len(features) == 0:
        return np.zeros((1, 34))

    return np.array(features)
