from __future__ import annotations

import os
os.environ.setdefault("OMP_NUM_THREADS", "1")
import platform
import sys

import duckdb
import numpy as np
import pandas as pd
import polars as pl
import pyarrow
import pyspark
import sklearn
import torch
import xgboost
from pyspark.sql import SparkSession
from sklearn.ensemble import RandomForestClassifier
from xgboost import XGBClassifier





def print_check(name: str, value: object) -> None:
    print(f"{name:<20}: {value}")


def verify_duckdb() -> None:
    print("\nTesting DuckDB...")

    result = duckdb.sql("SELECT 40 + 2 AS answer").fetchone()

    if result != (42,):
        raise RuntimeError(f"DuckDB test failed: {result}")

    print("DuckDB test passed.")


def verify_scikit_learn() -> None:
    print("\nTesting scikit-learn...")

    features = np.array(
        [
            [0.0, 0.0],
            [0.0, 1.0],
            [1.0, 0.0],
            [1.0, 1.0],
        ]
    )
    labels = np.array([0, 0, 1, 1])

    model = RandomForestClassifier(
        n_estimators=10,
        random_state=42,
    )
    model.fit(features, labels)

    prediction = model.predict([[1.0, 0.0]])

    if prediction.tolist() != [1]:
        raise RuntimeError(
            f"scikit-learn test failed: {prediction}"
        )

    print("scikit-learn test passed.")

def verify_xgboost() -> None:
    print("\nTesting XGBoost...", flush=True)

    rng = np.random.default_rng(42)

    features = rng.normal(size=(200, 4)).astype(np.float32)
    labels = (
        features[:, 0] + features[:, 1] > 0
    ).astype(np.int32)

    model = XGBClassifier(
        n_estimators=10,
        max_depth=3,
        learning_rate=0.2,
        objective="binary:logistic",
        eval_metric="logloss",
        tree_method="hist",
        n_jobs=1,
        random_state=42,
    )

    print("Training XGBoost model...", flush=True)
    model.fit(features, labels)

    predictions = model.predict(features)
    accuracy = float(np.mean(predictions == labels))

    if accuracy < 0.80:
        raise RuntimeError(
            f"XGBoost test failed: accuracy={accuracy:.3f}"
        )

    print_check("XGBoost accuracy", f"{accuracy:.3f}")
    print("XGBoost test passed.", flush=True)
   


def verify_pytorch() -> None:
    print("\nTesting PyTorch...")

    if torch.backends.mps.is_available():
        device = torch.device("mps")
    else:
        device = torch.device("cpu")

    tensor = torch.tensor([1.0, 2.0, 3.0], device=device)
    result = tensor * 2

    if result.cpu().tolist() != [2.0, 4.0, 6.0]:
        raise RuntimeError(f"PyTorch test failed: {result}")

    print_check("PyTorch device", device)
    print("PyTorch test passed.")


def verify_spark() -> None:
    print("\nStarting local Spark session...")

    spark = (
        SparkSession.builder
        .master("local[*]")
        .appName("analytics-workbench-verification")
        .config("spark.ui.enabled", "false")
        .getOrCreate()
    )

    try:
        rows = [
            (1, "solar"),
            (2, "iot"),
            (3, "spark"),
        ]

        dataframe = spark.createDataFrame(
            rows,
            ["id", "topic"],
        )

        count = dataframe.count()

        if count != 3:
            raise RuntimeError(
                f"Spark test failed: expected 3 rows, got {count}"
            )

        print_check("Spark runtime", spark.version)
        print("Spark test passed.")
    finally:
        spark.stop()


def main() -> None:
    print("\nAnalytics Workbench Verification")
    print("-" * 52)

    print_check("Python", sys.version.split()[0])
    print_check("Platform", platform.platform())
    print_check("Java home", os.environ.get("JAVA_HOME", "<not set>"))
    print_check("NumPy", np.__version__)
    print_check("Pandas", pd.__version__)
    print_check("Polars", pl.__version__)
    print_check("PyArrow", pyarrow.__version__)
    print_check("DuckDB", duckdb.__version__)
    print_check("scikit-learn", sklearn.__version__)
    print_check("XGBoost", xgboost.__version__)
    print_check("PyTorch", torch.__version__)
    print_check("PySpark", pyspark.__version__)

    verify_duckdb()
    verify_scikit_learn()
    verify_xgboost()
    verify_pytorch()
    verify_spark()

    print("\nAll verification tests passed.")


if __name__ == "__main__":
    main()
