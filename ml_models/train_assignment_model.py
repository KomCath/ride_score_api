import joblib
import logging
import os

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression

# Setup logger
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

# Resolve file paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(BASE_DIR, "assignment_data.csv")
MODEL_PATH = os.path.join(BASE_DIR, "assignment_model.pkl")

def train():
    try:
        # Check if CSV exists
        if not os.path.exists(DATA_PATH):
            raise FileNotFoundError("assignment_data.csv file does not exist.")

        # Load dataset
        data = pd.read_csv(DATA_PATH)

        # Check if CSV is empty
        if data.empty:
            raise ValueError("assignment_data.csv file has no data.")

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

        # Save the trained model
        joblib.dump(model, MODEL_PATH)

        logger.info(f"Training successfull: Test R² score: {r2_score:.2f}, model saved as {MODEL_PATH}")
    # Gracefully fails
    except Exception as e:
        logger.error(f"Training failed with {type(e).__name__}: {e}")

# Run when executing script directly
if __name__ == "__main__":
    train()
