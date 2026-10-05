from .pose import extract_pose_features
from .classify import classify_pose
import os

def run_inference(video_path):
    pose_features = extract_pose_features(video_path)
    action, confidence = classify_pose(pose_features)

    return {
        "action": action,
        "confidence": round(confidence, 3),
        "video": os.path.basename(video_path)
    }
