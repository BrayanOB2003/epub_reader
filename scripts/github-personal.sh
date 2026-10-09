#!/usr/bin/env bash
# Switch the active GitHub CLI account to the personal user and
# set this repo's commit identity to match.
set -euo pipefail

PERSONAL_USER="BrayanOB2003"
PERSONAL_NAME="Brayan Ortiz~"
# GitHub noreply address (public email is hidden on the account).
PERSONAL_EMAIL="65927857+BrayanOB2003@users.noreply.github.com"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

gh auth switch --hostname github.com --user "$PERSONAL_USER"

git config --local user.name "$PERSONAL_NAME"
git config --local user.email "$PERSONAL_EMAIL"

echo "Active GitHub account: $(gh api user --jq .login)"
echo "Commit identity: $(git config --local --get user.name) <$(git config --local --get user.email)>"
echo "Remote: $(git remote get-url origin)"
