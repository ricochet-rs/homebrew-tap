#!/usr/bin/env bash
set -euo pipefail

# Helper script to update ricochet formula to a new version
# Usage: ./update-formula.sh 0.2.0

if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 0.2.0"
    exit 1
fi

VERSION="$1"
FORMULA_NAME="ricochet"
UPSTREAM_REPO="ricochet-rs/cli"

echo "🔄 Updating ${FORMULA_NAME} to version ${VERSION}..."

# Construct the source URL
URL="https://github.com/${UPSTREAM_REPO}/archive/refs/tags/v${VERSION}.tar.gz"

echo "📦 Source URL: ${URL}"

# Verify the release exists
if ! curl --head --silent --fail "${URL}" > /dev/null; then
    echo "❌ Error: Release v${VERSION} not found at ${URL}"
    exit 1
fi

echo "✅ Release verified"

# Make sure we're in the tap directory
cd "$(dirname "$0")"

# Use brew bump-formula-pr to update the formula
echo "📝 Updating formula..."
brew bump-formula-pr \
  --url="${URL}" \
  --write-only \
  --no-browse \
  "${FORMULA_NAME}"

echo ""
echo "✅ Formula updated successfully!"
echo ""
echo "📋 Next steps:"
echo "  1. Review changes: git diff Formula/${FORMULA_NAME}.rb"
echo "  2. Commit: git add Formula/${FORMULA_NAME}.rb && git commit -m '${FORMULA_NAME} ${VERSION}'"
echo "  3. Push: git push"
echo "  4. GitHub Actions will build bottles automatically"
echo ""
echo "Or run this to commit and push now:"
echo "  git add Formula/${FORMULA_NAME}.rb && git commit -m '${FORMULA_NAME} ${VERSION}' && git push"
