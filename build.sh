#!/bin/sh
xcodebuild -workspace apus.xcworkspace -scheme apus -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build ENABLE_USER_SCRIPT_SANDBOXING=NO
