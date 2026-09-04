#!/bin/bash
set -e

echo "==============================================="
echo "   KaratCore ERP - Vercel Web Build Script     "
echo "==============================================="

# 1. Install Flutter SDK if not present
if [ ! -d "flutter" ]; then
  echo ">>> Cloning Flutter SDK (stable channel)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
else
  echo ">>> Flutter SDK found in workspace."
fi

# 2. Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# 3. Print Flutter Version
echo ">>> Flutter version:"
flutter --version

# 4. Resolve dependencies
echo ">>> Running flutter pub get..."
flutter pub get

# 5. Build Flutter Web Release
echo ">>> Building Flutter Web release bundle..."
if [ -n "$API_URL" ]; then
  echo ">>> Building with API_URL=$API_URL"
  flutter build web --release --dart-define=API_URL="$API_URL"
else
  echo ">>> Building with default Render API URL"
  flutter build web --release --dart-define=API_URL="https://karatcore-erp.onrender.com/api/v1"
fi

echo ">>> Removing service worker to ensure instantaneous web updates..."
rm -f build/web/flutter_service_worker.js

echo "==============================================="
echo "   KaratCore ERP Web Build Complete!           "
echo "   Output: build/web                           "
echo "==============================================="
