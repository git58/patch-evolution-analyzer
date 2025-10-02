"""
ML Classifier — классификация изменений патчей.
Использует простую ML-модель (TF-IDF + Naive Bayes).
Если модель отсутствует — обучает автоматически.
"""

import os
import pickle
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB

MODEL_PATH = "models/ml_classifier.pkl"

class MLClassifier:
    def __init__(self, dataset_file="datasets/lkml.csv"):
        self.dataset_file = dataset_file
        self.vectorizer = None
        self.clf = None
        self._load_or_train()

    def _train_model(self):
        texts, labels = [], []
        with open(self.dataset_file, encoding="utf-8") as f:
            for line in f:
                if "\t" not in line:
                    continue
                diff, label = line.strip().split("\t", 1)
                texts.append(diff)
                labels.append(label)

        self.vectorizer = TfidfVectorizer()
        X = self.vectorizer.fit_transform(texts)
        self.clf = MultinomialNB()
        self.clf.fit(X, labels)

        os.makedirs("models", exist_ok=True)
        with open(MODEL_PATH, "wb") as f:
            pickle.dump((self.vectorizer, self.clf), f)

        print(f"[OK] ML-модель обучена и сохранена: {MODEL_PATH}")

    def _load_or_train(self):
        if os.path.exists(MODEL_PATH):
            with open(MODEL_PATH, "rb") as f:
                self.vectorizer, self.clf = pickle.load(f)
        else:
            print("[INFO] ML-модель отсутствует → обучение...")
            self._train_model()

    def classify(self, diff_text: str) -> str:
        if not self.clf:
            return "[ML disabled]"
        X = self.vectorizer.transform([diff_text])
        pred = self.clf.predict(X)[0]
        proba = self.clf.predict_proba(X).max()
        return f"{pred} (уверенность {int(proba*100)}%)"
