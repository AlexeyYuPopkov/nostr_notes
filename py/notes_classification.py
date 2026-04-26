import os
import hashlib
import torch
import torch.nn as nn
import torch.nn.functional as F
from collections import defaultdict
import random

EPOCHS_COUNT = 300
VOCAB_SIZE = 3000
NGRAM_RANGE = (2, 5)
EMB_DIM = 48


class CharNGramClassifier(nn.Module):
    def __init__(
        self,
        # n-граммы от 2 до 5 символов, включая границы
        ngram_range=NGRAM_RANGE,
        # Размер словаря для хэширования n-грамм (кол-во бакетов)
        vocab_size=VOCAB_SIZE,
        # Размер эмбеддингов для каждой n-граммы
        emb_dim=EMB_DIM,
        # Кол-во классов для классификации
        num_classes=5,
        # Дропаут для классификационной головки
        dropout=0.3,
    ):
        super().__init__()
        self.ngram_range = ngram_range
        self.emb_dim = emb_dim

        # Для каждого n своя embedding table (с хэшированием в buckets)
        self.embeddings = nn.ModuleDict(
            {
                str(n): nn.Embedding(vocab_size, emb_dim, padding_idx=0)
                for n in range(ngram_range[0], ngram_range[1] + 1)
            }
        )

        # Слой нормализации
        # self.bn = nn.BatchNorm1d(emb_dim * len(self.embeddings))
        self.bn = nn.LayerNorm(emb_dim * len(self.embeddings))

        # Классификационная головка
        total_dim = emb_dim * len(self.embeddings)
        self.fc1 = nn.Linear(total_dim, 128)
        self.fc2 = nn.Linear(128, 64)
        self.fc3 = nn.Linear(64, num_classes)
        self.dropout = nn.Dropout(dropout)

    def get_ngrams(self, text: str):
        """Генерация n-грамм для текста"""
        # Добавляем границы
        text = f"<{text}>"
        ngrams_by_n = defaultdict(list)

        for n in range(self.ngram_range[0], self.ngram_range[1] + 1):
            for i in range(len(text) - n + 1):
                ngram = text[i : i + n]
                # Детерминированный хэш (не зависит от PYTHONHASHSEED)
                hash_val = (
                    int.from_bytes(
                        hashlib.md5(ngram.encode("utf-8")).digest()[:4], "little"
                    )
                    % VOCAB_SIZE
                )
                ngrams_by_n[n].append(hash_val)

        return ngrams_by_n

    def forward(self, texts):
        """
        texts: list of strings
        Returns: logits [batch_size, num_classes]
        """
        all_embeddings = []

        for n, emb_layer in self.embeddings.items():
            n_int = int(n)
            # Для каждого текста в батче генерируем n-граммы
            batch_ngrams = [self.get_ngrams(text)[n_int] for text in texts]

            # Суммируем эмбеддинги всех n-грамм для каждого текста
            batch_vectors = []
            for ngrams in batch_ngrams:
                if len(ngrams) == 0:
                    # Если нет n-грамм (короткий текст)
                    vec = torch.zeros(self.emb_dim, device=emb_layer.weight.device)
                else:
                    # Получаем эмбеддинги и суммируем
                    ngram_tensor = torch.tensor(ngrams, device=emb_layer.weight.device)
                    vec = emb_layer(ngram_tensor).mean(dim=0)
                batch_vectors.append(vec)

            batch_vectors = torch.stack(batch_vectors)
            all_embeddings.append(batch_vectors)

        # Конкатенируем эмбеддинги всех n
        x = torch.cat(all_embeddings, dim=1)  # [batch, total_dim]

        # Нормализация (транспонируем для BatchNorm1d)
        # x = self.bn(x.unsqueeze(-1)).squeeze(-1)
        x = self.bn(x)

        # Классификатор
        x = F.relu(self.fc1(x))
        x = self.dropout(x)
        x = F.relu(self.fc2(x))
        x = self.dropout(x)
        logits = self.fc3(x)
        
        # F.softmax 

        return logits

    def train_and_save_model(
        self, train_data: list[tuple[str, int]], all_classes: list[str]
    ):
        device = next(self.parameters()).device
        num_classes = len(all_classes)

        # Взвешенный loss: компенсирует дисбаланс классов
        counts = [0] * num_classes
        for _, label in train_data:
            counts[label] += 1
        total = len(train_data)
        weights = torch.tensor(
            [total / (num_classes * c) if c > 0 else 1.0 for c in counts],
            dtype=torch.float,
            device=device,
        )
        criterion = nn.CrossEntropyLoss(weight=weights)
        optimizer = torch.optim.Adam(self.parameters(), lr=0.001)
        scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(
            optimizer, T_max=EPOCHS_COUNT, eta_min=1e-5
        )

        batch_size = 8

        for epoch in range(EPOCHS_COUNT):
            random.shuffle(train_data)
            for i in range(0, len(train_data), batch_size):
                batch = train_data[i : i + batch_size]
                texts = [text for text, _ in batch]
                targets = torch.tensor(
                    [label for _, label in batch], dtype=torch.long
                ).to(device)

                logits = self(texts)
                loss = criterion(logits, targets)
                loss.backward()
                optimizer.step()
                optimizer.zero_grad()
            scheduler.step()
            if epoch % 5 == 0:
                print(f"Epoch {epoch}, Loss: {loss.item():.4f}, LR: {scheduler.get_last_lr()[0]:.6f}")

        save_path = os.path.join(os.path.dirname(__file__), "model.pth")
        torch.save(self.state_dict(), save_path)


# _json_path = os.path.join(os.path.dirname(__file__), "learning.json")
# train_data, CLASS_NAMES = load.load_train_data(_json_path)

# Классы: автоматически из learning.json
# NUM_CLASSES = len(CLASS_NAMES)



