import torch
import torch.nn as nn
import numpy as np

MODEL_PATH = "models/shot_classifier.pth"

# 🔥 MATCH TRAINING
NUM_CLASSES = 3
INPUT_SIZE = 34   # 17 keypoints × (x,y)
HIDDEN_SIZE = 128

class ShotClassifier(nn.Module):
    def __init__(self):
        super().__init__()
        self.lstm = nn.LSTM(
            input_size=INPUT_SIZE,
            hidden_size=HIDDEN_SIZE,
            batch_first=True
        )
        self.fc = nn.Linear(HIDDEN_SIZE, NUM_CLASSES)

    def forward(self, x):
        _, (h_n, _) = self.lstm(x)
        out = self.fc(h_n[-1])
        return out

# 🔥 Load model
model = ShotClassifier()
state_dict = torch.load(MODEL_PATH, map_location="cpu")
model.load_state_dict(state_dict)
model.eval()

CLASS_LABELS = ["forehand", "backhand", "serve"]

def classify_pose(pose_features):
    x = torch.tensor(pose_features, dtype=torch.float32).unsqueeze(0)

    with torch.no_grad():
        logits = model(x)
        probs = torch.softmax(logits, dim=1).numpy()[0]

    idx = int(np.argmax(probs))
    return CLASS_LABELS[idx], float(probs[idx])
