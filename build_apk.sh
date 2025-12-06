#!/bin/bash
export FLUTTER_ROOT="/Users/sergey/flutter"
export PATH="/Users/sergey/flutter/bin:$PATH"
cd "$(dirname "$0")/cat_tinder"
flutter build apk --release
