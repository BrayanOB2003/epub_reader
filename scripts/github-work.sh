#!/usr/bin/env bash
# Switch the active GitHub CLI account back to the work user and
# set this repo's commit identity to the work email.
set -euo pipefail

WORK_USER="brayanortiz-mejorcdt"
WORK_NAME="Brayan Ortiz~"
WORK_EMAIL="brayanortiz@mejorcdt.com"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

gh auth switch --hostname github.com --user "$WORK_USER"

git config --local user.name "$WORK_NAME"
git config --local user.email "$WORK_EMAIL"

echo "Active GitHub account: $(gh api user --jq .login)"
echo "Commit identity: $(git config --local --get user.name) <$(git config --local --get user.email)>"
echo "Remote: $(git remote get-url origin)"
