#!/usr/bin/env bash

set -e

if [ "$#" -ne 1 ] || [ ! -d "${1}" ]; then
  echo "Error: You must specify a valid target subdirectory." >&2
  echo "Usage: $0 <target-subdirectory>" >&2
  exit 1
fi

# Compute relative path for target subdirectory
REPO_PATH=$(readlink -f -- "$(git rev-parse --show-toplevel)")
SUBDIR_PATH=$(readlink -f -- "${1}")
TARGET_SUBDIR="${SUBDIR_PATH#"${REPO_PATH}/"}"

if [ "${TARGET_SUBDIR}" = "${SUBDIR_PATH}" ]; then
  echo "Error: Target path must be a subdirectory of the repository." >&2
  exit 1
fi

# Remove remote for original repo
git remote remove origin

# Rename original main branch
git branch --move main original-main

# Create subtree branch for target subdirectory
git subtree split --prefix="${TARGET_SUBDIR}" --branch main

# Checkout subtree branch
git checkout main

# Delete original main branch
git branch --delete --force original-main
