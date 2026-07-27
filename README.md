# Analytics Workbench

> **Building Modern Analytics & AI Skills One Project at a Time**

A reproducible, project-driven environment for learning modern analytics, data engineering, machine learning, and AI through hands-on projects.

---

## Overview

Analytics Workbench is a personal learning laboratory designed to explore the modern data ecosystem by building real projects instead of completing isolated tutorials.

Rather than learning technologies in isolation, each notebook introduces new tools while solving practical analytics problems. Every project builds on previous work, reinforcing concepts through incremental, hands-on development.

The goal is to understand not only **how** individual tools work, but **why** they exist and **when** to use them.

---

## Learning Philosophy

The guiding principle of this repository is simple:

> **Learn technologies by solving problems, not by memorizing APIs.**

Every project begins with a business question.

Examples include:

- How much solar energy did we generate today?
- Can we forecast tomorrow's production?
- Which sensors are beginning to fail?
- How can we optimize inventory?
- Can machine learning improve forecasting accuracy?

Technology is introduced only when it helps answer those questions.

---

# Technology Stack

| Category | Technologies |
|----------|--------------|
| Language | Python 3.12 |
| Environment | uv |
| Version Control | Git |
| Notebook Environment | JupyterLab |
| Analytics | DuckDB |
| DataFrames | Pandas, Polars |
| Storage | Apache Parquet |
| Distributed Computing | Apache Spark |
| Machine Learning | scikit-learn |
| Gradient Boosting | XGBoost |
| Deep Learning | PyTorch |
| Visualization | Plotly, Matplotlib, Altair |

---

# Repository Structure

```
analytics-workbench/
│
├── README.md
├── setup.sh
├── pyproject.toml
├── uv.lock
│
├── requirements/
│   ├── core.txt
│   ├── notebook.txt
│   ├── visualization.txt
│   ├── ml.txt
│   ├── spark.txt
│   ├── utilities.txt
│   └── dev.txt
│
├── scripts/
│   └── verify_environment.py
│
├── notebooks/
│
├── projects/
│
├── data/
│   ├── raw/
│   ├── processed/
│   └── output/
│
└── docs/
```

---

# Getting Started

Clone the repository:

```bash
git clone https://github.com/thescriptingcave/analytics-workbench.git
cd analytics-workbench
```

Run the automated setup:

```bash
./setup.sh
```

The setup script will:

- Create the Python environment
- Install all required packages
- Configure the Jupyter kernel
- Verify the installation
- Confirm that the environment is ready for development

---

# Verify the Environment

At any time you can verify the installation by running:

```bash
uv run python scripts/verify_environment.py
```

The verification script tests the complete analytics stack, including:

- DuckDB
- NumPy
- Pandas
- Polars
- PyArrow
- scikit-learn
- XGBoost
- PyTorch
- Apache Spark

---

# Launch JupyterLab

```bash
uv run jupyter lab
```

Select the **Python (Analytics Workbench)** kernel.

---

# Learning Roadmap

This repository grows through a sequence of progressively more advanced notebooks.

| Notebook | Topic | Status |
|-----------|-------|:------:|
| 01 | Solar Analytics with DuckDB & Spark | ✅ Complete |
| 02 | Pandas & Polars Fundamentals | ⏳ Planned |
| 03 | Feature Engineering | ⏳ Planned |
| 04 | Machine Learning with scikit-learn | ⏳ Planned |
| 05 | Gradient Boosting with XGBoost | ⏳ Planned |
| 06 | Deep Learning with PyTorch | ⏳ Planned |
| 07 | Time-Series Forecasting | ⏳ Planned |
| 08 | IoT Analytics | ⏳ Planned |
| 09 | Apache Spark Transformations | ⏳ Planned |
| 10 | End-to-End Analytics Pipeline | ⏳ Planned |

---

# Architecture

```
Raw Data
    │
    ▼
CSV / JSON / Parquet
    │
    ▼
DuckDB
    │
    ▼
Feature Engineering
    │
    ▼
Apache Spark
    │
    ▼
Machine Learning
    │
    ▼
Visualization
    │
    ▼
Business Insights
```

---

# Current Progress

| Area | Status |
|------|:------:|
| Development Environment | ✅ |
| uv Workflow | ✅ |
| Git Repository | ✅ |
| DuckDB | ✅ |
| Apache Spark | ✅ |
| Pandas | ⏳ |
| Polars | ⏳ |
| Feature Engineering | ⏳ |
| scikit-learn | ⏳ |
| XGBoost | ⏳ |
| PyTorch | ⏳ |
| Airflow | ⏳ |
| dbt | ⏳ |

---

# Why This Repository Exists

There are countless tutorials explaining individual tools. Very few demonstrate how those tools work together to solve realistic analytics problems.

Analytics Workbench documents the process of building practical skills through incremental projects. Each notebook introduces a new capability while reinforcing concepts learned earlier, resulting in a growing collection of reusable examples that reflect how modern analytics systems are built.

Whether you're learning SQL, distributed computing, machine learning, or data engineering, the emphasis is always on understanding the complete workflow rather than isolated technologies.

---

# Future Directions

Planned areas of exploration include:

- Advanced DuckDB Analytics
- Apache Spark Performance
- Airflow
- dbt
- Feature Engineering
- Time-Series Forecasting
- Deep Learning with PyTorch
- Solar Analytics
- IoT Analytics
- Supply Chain Analytics
- End-to-End Data Pipelines

---

# License

This project is licensed under the MIT License.