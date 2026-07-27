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

get_java_major_version() {
    java -XshowSettings:properties -version 2>&1 |
        awk -F'= ' '/java.specification.version/ {
            print $2
            exit
        }'
}

ensure_java_17() {
    log "Checking Java"

    local java_major=""
    local java_home=""

    if command_exists java; then
        java_major="$(get_java_major_version || true)"
    fi

    if [[ "$java_major" =~ ^[0-9]+$ ]] && (( java_major >= 17 )); then
        if [[ -z "${JAVA_HOME:-}" ]]; then
            JAVA_HOME="$(
                /usr/libexec/java_home -v "$java_major" 2>/dev/null ||
                dirname "$(dirname "$(command -v java)")"
            )"
            export JAVA_HOME
        fi

        export PATH="$JAVA_HOME/bin:$PATH"

        echo "Java $java_major detected."
        echo "JAVA_HOME: $JAVA_HOME"
        return 0
    fi

    if [[ -z "$java_major" ]]; then
        echo "Java is not installed."
    else
        echo "Java $java_major detected; Java 17 or newer is required."
    fi

    log "Installing OpenJDK 17"
    brew install openjdk@17

    java_home="$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home"

    [[ -x "$java_home/bin/java" ]] ||
        fail "OpenJDK 17 was installed, but Java was not found at $java_home/bin/java"

    export JAVA_HOME="$java_home"
    export PATH="$JAVA_HOME/bin:$PATH"

    java_major="$(get_java_major_version || true)"

    if [[ ! "$java_major" =~ ^[0-9]+$ ]] || (( java_major < 17 )); then
        fail "Java 17 installation could not be verified."
    fi

    echo "Java $java_major installed and activated."
    echo "JAVA_HOME: $JAVA_HOME"
}

configure_java_shell() {
    local shell_config="$HOME/.zshrc"
    local marker="# Analytics Workbench Java 17"

    if [[ "${SHELL:-}" != */zsh ]]; then
        echo "Skipping persistent Java configuration because the current shell is not zsh."
        return 0
    fi

    touch "$shell_config"

    if grep -Fq "$marker" "$shell_config"; then
        echo "Java 17 is already configured in $shell_config."
        return 0
    fi

    log "Configuring Java 17 for future terminal sessions"

    cat >> "$shell_config" <<'EOF'

# Analytics Workbench Java 17
export JAVA_HOME="$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
EOF

    echo "Added Java 17 configuration to $shell_config."
    echo "Open a new terminal or run: source $shell_config"
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
command_exists brew || fail "Homebrew is not installed."

ensure_java_17
configure_java_shell

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
