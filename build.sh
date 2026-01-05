#!/bin/sh
xcodebuild -project apus.xcodeproj -scheme apus -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build ENABLE_USER_SCRIPT_SANDBOXING=NO
