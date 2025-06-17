import os
import pandas as pd
import joblib
import pytest
from ml_models import train_assignment_model

@pytest.fixture
def sample_data(tmp_path):
    # Create a temporary CSV file
    df = pd.DataFrame({
        "ride_duration": [10, 20, 30],
        "ride_earnings": [50, 60, 70],
        "commute_duration": [5, 10, 15],
        "score": [100, 150, 200]
    })
    data_path = tmp_path / "ml_assignment_data.csv"
    df.to_csv(data_path, index=False)

    # Override paths inside train_assignment_model
    train_assignment_model.DATA_PATH = str(data_path)
    train_assignment_model.MODEL_PATH = str(tmp_path / "assignment_model.pkl")

    return train_assignment_model.MODEL_PATH

def test_train_assignment_model_creates_and_saves_model_file(sample_data):
    # Run training
    train_assignment_model.train()

    # Check that model file was created
    assert os.path.exists(sample_data)

    # Check that model file is not empty
    assert os.path.getsize(sample_data) > 0

    # Try to load model
    model = joblib.load(sample_data)
    assert model is not None
