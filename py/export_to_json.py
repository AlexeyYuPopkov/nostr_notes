import os
import json
from load_model import load_model
from load_train_data import load_train_data as _load_train_data

def load_train_data(filename: str = "learning.json"):
    _json_path = os.path.join(os.path.dirname(__file__), filename)
    train_data, CLASS_NAMES = _load_train_data(_json_path)
    return train_data, CLASS_NAMES

train_data, CLASS_NAMES = load_train_data()
    
model = load_model(len(CLASS_NAMES))
model.eval()

weights = {}

# Embedding tables: {n: [[vocab_size, emb_dim]]}
for n, emb in model.embeddings.items():
    weights[f"emb_{n}"] = emb.weight.detach().cpu().numpy().tolist()

# LayerNorm
weights["bn_weight"] = model.bn.weight.detach().cpu().numpy().tolist()
weights["bn_bias"]   = model.bn.bias.detach().cpu().numpy().tolist()

# FC слои
for name, param in [("fc1_w", model.fc1.weight), ("fc1_b", model.fc1.bias),
                     ("fc2_w", model.fc2.weight), ("fc2_b", model.fc2.bias),
                     ("fc3_w", model.fc3.weight), ("fc3_b", model.fc3.bias)]:
    weights[name] = param.detach().cpu().numpy().tolist()

# Классы
weights["classes"] = CLASS_NAMES

with open("model_weights.json", "w") as f:
    json.dump(weights, f)

print("Exported!")