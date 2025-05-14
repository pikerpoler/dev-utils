#!/bin/bash
mkdir -p ~/.local/bin

curl -fsSL https://raw.githubusercontent.com/pikerpoler/dev-utils/main/config-gcp-ssh.sh -o ~/.local/bin/config-gcp-ssh
chmod +x ~/.local/bin/config-gcp-ssh

SHELL_NAME=$(basename "$SHELL")
RC_FILE=""

if [[ "$SHELL_NAME" == "zsh" ]]; then
    RC_FILE="$HOME/.zshrc"
elif [[ "$SHELL_NAME" == "bash" ]]; then
    RC_FILE="$HOME/.bashrc"
else
    echo "⚠️ Unknown shell: $SHELL_NAME. Please add ~/.local/bin to your PATH manually."
fi

if [[ -n "$RC_FILE" ]]; then
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$RC_FILE"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC_FILE"
        echo "Added ~/.local/bin to PATH in $RC_FILE — restart your shell to apply."
    else
        echo "~/.local/bin already in PATH in $RC_FILE"
    fi
fi

echo "Installed config-gcp-ssh. Run it using:"
echo "    config-gcp-ssh"
