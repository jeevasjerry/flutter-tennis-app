import cv2
import numpy as np
import torch
import torch.nn as nn
from ultralytics import YOLO
import json
import os
from collections import deque

# ==============================
# CONFIG
# ==============================
VIDEO_PATH = "data/test_videos/test5.mp4"
OUTPUT_VIDEO = "outputs/videos/output.mp4"
OUTPUT_JSON = "outputs/json/output.json"

WINDOW_SIZE = 60        # frames
PRED_INTERVAL = 5       # predict every N frames

LABEL_MAP = {0: "Forehand", 1: "Backhand", 2: "Serve"}

# ==============================
# LOAD MODELS
# ==============================
pose_model = YOLO("yolov8n-pose.pt")

class ShotClassifier(nn.Module):
    def __init__(self):
        super().__init__()
        self.lstm = nn.LSTM(34, 128, batch_first=True)
        self.fc = nn.Linear(128, 3)

    def forward(self, x):
        _, (h, _) = self.lstm(x)
        return self.fc(h[-1])

classifier = ShotClassifier()
classifier.load_state_dict(torch.load("models/shot_classifier.pth", map_location="cpu"))
classifier.eval()

# ==============================
# VIDEO SETUP
# ==============================
cap = cv2.VideoCapture(VIDEO_PATH)
fps = cap.get(cv2.CAP_PROP_FPS)
W = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
H = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

os.makedirs("outputs/videos", exist_ok=True)
os.makedirs("outputs/json", exist_ok=True)

writer = cv2.VideoWriter(
    OUTPUT_VIDEO,
    cv2.VideoWriter_fourcc(*"mp4v"),
    fps,
    (W, H)
)

# ==============================
# BUFFERS
# ==============================
pose_buffer = deque(maxlen=WINDOW_SIZE)
results_log = []
current_label = "Detecting..."
current_conf = 0.0

frame_id = 0

# ==============================
# INFERENCE LOOP
# ==============================
while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    results = pose_model(frame, conf=0.5, verbose=False)

    if results[0].keypoints is not None:
        kpts_all = results[0].keypoints.xy.cpu().numpy()

        if len(kpts_all) > 0:
            kpts = kpts_all[0]  # main player
            pose_buffer.append(kpts.flatten())

            # Draw skeleton
            for (x, y) in kpts:
                cv2.circle(frame, (int(x), int(y)), 4, (0, 255, 0), -1)

    # ==============================
    # PREDICTION
    # ==============================
    if len(pose_buffer) == WINDOW_SIZE and frame_id % PRED_INTERVAL == 0:
        window = np.array(pose_buffer)
        window_tensor = torch.tensor(window, dtype=torch.float32).unsqueeze(0)

        with torch.no_grad():
            logits = classifier(window_tensor)
            probs = torch.softmax(logits, dim=1).numpy()[0]

        pred_idx = int(np.argmax(probs))
        current_label = LABEL_MAP[pred_idx]
        current_conf = float(probs[pred_idx])

        timestamp = frame_id / fps
        results_log.append({
            "time_sec": round(timestamp, 2),
            "shot": current_label,
            "confidence": round(current_conf, 3)
        })

    # ==============================
    # OVERLAY TEXT
    # ==============================
    cv2.putText(
        frame,
        f"Shot: {current_label}",
        (30, 40),
        cv2.FONT_HERSHEY_SIMPLEX,
        1,
        (0, 0, 255),
        2
    )

    cv2.putText(
        frame,
        f"Confidence: {current_conf:.2f}",
        (30, 80),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.9,
        (255, 0, 0),
        2
    )

    writer.write(frame)
    frame_id += 1

# ==============================
# CLEANUP
# ==============================
cap.release()
writer.release()

with open(OUTPUT_JSON, "w") as f:
    json.dump(results_log, f, indent=2)

print("✅ Inference complete")
print("🎥 Output video saved to:", OUTPUT_VIDEO)
print("📄 JSON results saved to:", OUTPUT_JSON)