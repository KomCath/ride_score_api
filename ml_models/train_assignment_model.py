import joblib
import os
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression

# Resolve file paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(BASE_DIR, "assignment_data.csv")
MODEL_PATH = os.path.join(BASE_DIR, "assignment_model.pkl")

def train():
    # Load dataset
    data = pd.read_csv(DATA_PATH)

    # Prepare features and target
    X = data[["ride_duration", "ride_earnings", "commute_duration"]]
    y = data["score"]

    # Train-test split (optional for evaluation)
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Train model
    model = LinearRegression()
    model.fit(X_train, y_train)

    # Evaluate model
    r2_score = model.score(X_test, y_test)
    print(f"✅ Model trained. Test R² score: {r2_score:.2f}")

    # Save the trained model
    joblib.dump(model, MODEL_PATH)
    print(f"✅ AI model trained and saved as {MODEL_PATH}")


# Run when executing script directly
if __name__ == "__main__":
    train()