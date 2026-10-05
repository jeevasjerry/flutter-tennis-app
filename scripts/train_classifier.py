import os
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim

DATA_DIR = "data/processed_keypoints"
LABELS = {"forehand": 0, "backhand": 1, "serve": 2}
MAX_FRAMES = 60

# -------------------------
# Load dataset
# -------------------------
def load_dataset():
    X, y = [], []

    for label, idx in LABELS.items():
        folder = os.path.join(DATA_DIR, label)
        for file in os.listdir(folder):
            data = np.load(os.path.join(folder, file))

            # Pad or truncate
            if len(data) > MAX_FRAMES:
                data = data[:MAX_FRAMES]
            else:
                pad = np.zeros((MAX_FRAMES - len(data), data.shape[1]))
                data = np.vstack([data, pad])

            X.append(data)
            y.append(idx)

    return torch.tensor(X, dtype=torch.float32), torch.tensor(y)

X, y = load_dataset()

# -------------------------
# LSTM Model
# -------------------------
class ShotClassifier(nn.Module):
    def __init__(self):
        super().__init__()
        self.lstm = nn.LSTM(input_size=34, hidden_size=128, batch_first=True)
        self.fc = nn.Linear(128, 3)

    def forward(self, x):
        _, (h, _) = self.lstm(x)
        return self.fc(h[-1])

model = ShotClassifier()

criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)

# -------------------------
# Training loop
# -------------------------
EPOCHS = 30

for epoch in range(EPOCHS):
    optimizer.zero_grad()
    outputs = model(X)
    loss = criterion(outputs, y)
    loss.backward()
    optimizer.step()

    print(f"Epoch {epoch+1}/{EPOCHS} | Loss: {loss.item():.4f}")

# -------------------------
# Save model
# -------------------------
os.makedirs("models", exist_ok=True)
torch.save(model.state_dict(), "models/shot_classifier.pth")

print("✅ Training complete. Model saved to models/shot_classifier.pth")