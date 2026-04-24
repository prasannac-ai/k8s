#!/usr/bin/env bash
# Script to install Kubernetes tools on macOS using Homebrew

set -euo pipefail

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew is not installed. Please install it first from https://brew.sh"
    exit 1
fi

echo "Updating Homebrew..."
brew update

echo "Installing kind, kubectl, and helm..."
brew install kind kubectl helm

echo "---------------------------------------"
echo "Verification:"
kind version
kubectl version --client
helm version
echo "---------------------------------------"
echo "All tools installed successfully!"
