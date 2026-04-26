import os
import torch
from notes_classification import CharNGramClassifier

# import notes_ckassification as m
from load_train_data import load_train_data as _load_train_data, print_class_distribution
from load_model import load_model
from augment_dataset import augment_dataset



def load_train_data(
    filename: str = "learning.json", class_names: list[str] | None = None
):
    _json_path = os.path.join(os.path.dirname(__file__), filename)
    train_data, CLASS_NAMES = _load_train_data(_json_path, class_names)
    return train_data, CLASS_NAMES


def train_model(
    train_data: list[tuple[str, int]],
    all_classes: list[str],
):
    model = CharNGramClassifier(num_classes=len(all_classes))
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    model = model.to(device)
    model.train_and_save_model(train_data, all_classes)


def evaluate(
    model,
    train_data: list[tuple[str, int]],
    class_names: list[str],
):
    """Accuracy single-label классификации."""
    texts = [text for text, _ in train_data]
    all_labels = [label for _, label in train_data]

    with torch.no_grad():
        logits = model(texts)
        preds = logits.argmax(dim=1).cpu().tolist()

    correct = sum(p == l for p, l in zip(preds, all_labels))
    accuracy = correct / len(all_labels) if all_labels else 0.0

    print(f"\n--- Оценка качества ---")
    print(f"  Accuracy: {accuracy:.2%}  ({correct}/{len(all_labels)})")


def predict(model, texts: list[str], class_names: list[str], top_k: int = 3):
    with torch.no_grad():
        logits = model(texts)
        probs = torch.softmax(logits, dim=1)
        topk_probs, topk_indices = torch.topk(probs, k=top_k, dim=1)

    for text, indices, scores in zip(texts, topk_indices, topk_probs):
        print(f"\n'{text}':")
        for idx, score in zip(indices, scores):
            print(f"  {class_names[idx]}: {score:.2f}")


if __name__ == "__main__":
    train_data, CLASS_NAMES = load_train_data()
    # metric_data грузим с тем же маппингом классов, что и у модели
    metric_data, _ = load_train_data("learning_metric_data.json", CLASS_NAMES)
    
    print_class_distribution(metric_data, CLASS_NAMES)
    
    
    datasetToUse = augment_dataset(train_data, 2)
    
    print_class_distribution(datasetToUse, CLASS_NAMES)
    
    train_model(datasetToUse, CLASS_NAMES)

    model = load_model(len(CLASS_NAMES))

    evaluate(model, metric_data, CLASS_NAMES)
    predict(
        model,
        [
            "сходить в магазин",
            "написать код для нейросети",
            "https://api.dart.dev/stable/2.12.0/dart-async/Future-class.html",
            "обычный текст P@ssw0rd123",
        ],
        CLASS_NAMES,
    )

    print("\n--- С предиктом с правилами ---")

    # predict_with_rules(
    #     model,
    #     [
    #         # "сходить в магазин",
    #         # "написать код для нейросети",
    #         # "https://api.dart.dev/stable/2.12.0/dart-async/Future-class.html",
    #         "обычный текст P@ssw0rd123",
    #     ],
    #     CLASS_NAMES,
    # )
