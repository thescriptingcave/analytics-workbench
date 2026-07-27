#!/usr/bin/env bash

set -Eeuo pipefail

WORKBENCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_VERSION="3.12"
KERNEL_NAME="analytics-workbench"
KERNEL_DISPLAY_NAME="Python (Analytics Workbench)"

log() {
    printf '\n==> %s\n' "$1"
}

fail() {
    printf '\nERROR: %s\n' "$1" >&2
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_profile() {
    local profile="$1"
    local file="$WORKBENCH_DIR/requirements/$profile.txt"

    [[ -f "$file" ]] || fail "Missing requirements file: $file"

    log "Installing profile: $profile"
    uv add -r "$file"
}

log "Starting Analytics Workbench setup"
echo "Directory: $WORKBENCH_DIR"

log "Checking required system tools"

command_exists uv || fail "uv is not installed."
command_exists git || fail "Git is not installed."
command_exists java || fail "Java is not installed."
command_exists brew || fail "Homebrew is not installed."

if [[ -z "${JAVA_HOME:-}" ]]; then
    fail "JAVA_HOME is not set."
fi

echo "Java: $(java -version 2>&1 | head -n 1)"
echo "uv: $(uv --version)"
echo "Git: $(git --version)"
echo "JAVA_HOME: $JAVA_HOME"

log "Installing Python $PYTHON_VERSION"
uv python install "$PYTHON_VERSION"

cd "$WORKBENCH_DIR"

log "Initializing uv project"

if [[ ! -f pyproject.toml ]]; then
    uv init \
        --name analytics-workbench \
        --python "$PYTHON_VERSION" \
        --no-readme
else
    echo "Existing pyproject.toml found."
fi

log "Checking XGBoost system dependency"

if ! brew list libomp >/dev/null 2>&1; then
    log "Installing libomp for XGBoost"
    brew install libomp
else
    echo "libomp is already installed."
fi


log "Creating workbench directories"

mkdir -p \
    notebooks \
    data/raw \
    data/processed \
    data/output \
    projects \
    scripts \
    docs \
    requirements

install_profile core
install_profile notebook
install_profile visualization
install_profile ml
install_profile spark
install_profile utilities
install_profile dev

log "Synchronizing environment"
uv sync

log "Installing Jupyter kernel"

uv run python -m ipykernel install \
    --user \
    --name "$KERNEL_NAME" \
    --display-name "$KERNEL_DISPLAY_NAME"

log "Creating environment example"

cat > .env.example <<ENVEOF
JAVA_HOME=$JAVA_HOME
PYSPARK_PYTHON=$WORKBENCH_DIR/.venv/bin/python
PYSPARK_DRIVER_PYTHON=$WORKBENCH_DIR/.venv/bin/python
ENVEOF

log "Running verification"
OMP_NUM_THREADS=1 uv run python scripts/verify_environment.py

log "Setup complete"

cat <<MESSAGE

Start JupyterLab with:

    cd "$WORKBENCH_DIR"
    uv run jupyter lab

Select the kernel:

    $KERNEL_DISPLAY_NAME

MESSAGE
