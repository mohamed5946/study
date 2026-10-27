#!/usr/bin/env bash
# Generates the Android project around the existing lib/ code, then installs packages.
# Run once from the project root:  bash setup.sh
set -e

flutter create --platforms=android --project-name study_assistant_cloud --org com.studyassistantcloud .
rm -rf test

MANIFEST=android/app/src/main/AndroidManifest.xml

# Release builds need the INTERNET permission to reach the AI server.
if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
  sed -i.bak 's#<application#<uses-permission android:name="android.permission.INTERNET"/>\n    <application#' "$MANIFEST"
fi

# App name shown under the icon.
sed -i.bak 's#android:label="[^"]*"#android:label="Study Assistant Cloud"#' "$MANIFEST"
rm -f "$MANIFEST.bak"

flutter pub get
echo "Done. Run: flutter run   or   flutter build apk --release"
