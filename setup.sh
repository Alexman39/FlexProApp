#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────
# FlexPro Coaching — Flutter project initialisation script
# Run this ONCE after installing Flutter & Android Studio.
# ─────────────────────────────────────────────────────────
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "→ Checking Flutter..."
flutter --version

echo "→ Creating Flutter project scaffold (platform files only)..."
# Create a temp project to get platform files, then merge
TMPDIR=$(mktemp -d)
flutter create \
  --org com.tasos \
  --project-name flexpro_coaching \
  --platforms android,ios \
  "$TMPDIR/flexpro_coaching"

# Copy platform dirs (android/, ios/) — DO NOT overwrite our lib/ or pubspec.yaml
cp -r "$TMPDIR/flexpro_coaching/android" "$DIR/"
cp -r "$TMPDIR/flexpro_coaching/ios" "$DIR/"
cp -r "$TMPDIR/flexpro_coaching/test" "$DIR/"
rm -rf "$TMPDIR"

echo "→ Getting packages..."
flutter pub get

echo "→ Running flutter doctor..."
flutter doctor

echo ""
echo "✅ Done! Open VS Code in this directory and run:"
echo "   flutter run"
echo ""
echo "💡 To set up Firebase later, run:"
echo "   dart pub global activate flutterfire_cli"
echo "   flutterfire configure"
