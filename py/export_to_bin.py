import struct
import torch
from notes_classification import CharNGramClassifier
from load_train_data import load_train_data

VERSION = 1

train_data, class_names = load_train_data("learning.json")
num_classes = len(class_names)

model = CharNGramClassifier(num_classes=num_classes)
model.load_state_dict(torch.load("model.pth", weights_only=True, map_location="cpu"))
model.eval()

sd = model.state_dict()
ngram_min, ngram_max = model.ngram_range
num_ngrams = ngram_max - ngram_min + 1
vocab_size = sd["embeddings.2.weight"].shape[0]
emb_dim = model.emb_dim

# Blob имён классов: каждое имя + \0
classes_blob = b"".join(c.encode("utf-8") + b"\0" for c in class_names)

with open("model.bin", "wb") as f:
    # Заголовок
    f.write(b"NGCL")
    f.write(struct.pack("<iiiiiii",
        VERSION,                    
        vocab_size,
        emb_dim,
        ngram_min,
        ngram_max,
        num_classes,
        len(classes_blob),
    ))
    f.write(classes_blob)

    # Embedding tables (в порядке n = ngram_min..ngram_max)
    for n in range(ngram_min, ngram_max + 1):
        w = sd[f"embeddings.{n}.weight"].numpy()  # [vocab_size, emb_dim]
        f.write(w.astype("<f4").tobytes())

    # LayerNorm
    f.write(sd["bn.weight"].numpy().astype("<f4").tobytes())
    f.write(sd["bn.bias"].numpy().astype("<f4").tobytes())

    # FC слои
    for name in ["fc1.weight", "fc1.bias", "fc2.weight", "fc2.bias", "fc3.weight", "fc3.bias"]:
        f.write(sd[name].numpy().astype("<f4").tobytes())

print(f"Записано: {open('model.bin','rb').seek(0,2) or open('model.bin','rb').read().__len__()} байт")
# Проще:
import os
print(f"model.bin: {os.path.getsize('model.bin') / 1024 / 1024:.2f} MB")