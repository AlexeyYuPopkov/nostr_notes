import os
import torch
from notes_classification import CharNGramClassifier

def load_model(num_classes: int):
    model = CharNGramClassifier(num_classes=num_classes)
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    model = model.to(device)
    model_path = os.path.join(os.path.dirname(__file__), "model.pth")
    model.load_state_dict(torch.load(model_path, weights_only=True, map_location=device))
    model.eval()
    return model


