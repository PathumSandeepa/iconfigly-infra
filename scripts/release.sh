#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <version-tag> (e.g. 2.1 or v2.1)"
  exit 1
fi

TAG="$1"
VERSION="${TAG#v}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

for env_file in .env .env.example; do
  target="${REPO_ROOT}/${env_file}"
  if [ -f "$target" ]; then
    if grep -q '^ICONFIGLY_VERSION=' "$target"; then
      sed -i.bak "s/^ICONFIGLY_VERSION=.*/ICONFIGLY_VERSION=${VERSION}/" "$target" && rm -f "${target}.bak"
    else
      printf "\nICONFIGLY_VERSION=%s\n" "$VERSION" >> "$target"
    fi
  fi
done

git -C "$REPO_ROOT" config user.name "Pathum Sandeepa"
git -C "$REPO_ROOT" config user.email "pathumsandeepa13@gmail.com"

git -C "$REPO_ROOT" add .env.example
if ! git -C "$REPO_ROOT" diff --cached --quiet .env.example; then
  git -C "$REPO_ROOT" commit -m "chore(release): bump ICONFIGLY_VERSION to ${VERSION}"
  git -C "$REPO_ROOT" push origin HEAD
fi

git -C "$REPO_ROOT" tag -a "$TAG" -m "Release ${TAG}"
git -C "$REPO_ROOT" push origin "$TAG"

echo "Pushed tag '${TAG}' to iconfigly-infra. GitHub Actions will propagate v${VERSION} across all repos."
