import joblib
import os
import pytest

import pandas as pd
from ml_models import train_assignment_model

@pytest.fixture
def setup_training_paths(tmp_path):
    # Provides paths and resets the model module paths.
    data_path = tmp_path / "ml_assignment_data.csv"
    model_path = tmp_path / "ml_assignment_model.pkl"
    train_assignment_model.DATA_PATH = str(data_path)
    train_assignment_model.MODEL_PATH = str(model_path)
    return data_path, model_path

def test_train_assignment_model_creates_and_saves_model_file(setup_training_paths, caplog):
    data_path, model_path = setup_training_paths

    # Valid CSV and data
    df = pd.DataFrame({
        "ride_duration": [10, 20, 30, 40, 50, 20],
        "ride_earnings": [50, 60, 70, 80, 90, 80],
        "commute_duration": [5, 10, 15, 20, 25, 20],
        "score": [100, 150, 200, 250, 300, 120]
    })
    # Update file name to match DATA_PATH logic
    df.to_csv(data_path, index=False)

    with caplog.at_level("INFO"):
        # Run training
        train_assignment_model.train()

    # Check success log
    assert "Training successfull:" in caplog.text

    # Check that model file was created
    assert os.path.exists(model_path)

    # Check that model file is not empty
    assert os.path.getsize(model_path) > 0

    # Try to load model
    model = joblib.load(model_path)
    assert model is not None

def test_train_assignment_model_handles_missing_csv(setup_training_paths, caplog):
    _, model_path = setup_training_paths

    with caplog.at_level("ERROR"):
        train_assignment_model.train()

    assert "assignment_data.csv file does not exist" in caplog.text
    assert "FileNotFoundError" in caplog.text
    assert not os.path.exists(model_path)

def test_train_assignment_model_handles_no_data_csv(setup_training_paths, caplog):
    data_path, model_path = setup_training_paths

    # Invalid data
    df = pd.DataFrame(columns=["ride_duration", "ride_earnings", "commute_duration", "score"])
    df.to_csv(data_path, index=False)

    with caplog.at_level("ERROR"):
        train_assignment_model.train()

    assert "assignment_data.csv file has no data" in caplog.text
    assert "ValueError" in caplog.text
    assert not os.path.exists(model_path)
