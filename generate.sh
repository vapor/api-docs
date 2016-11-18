cd code

git pull
vapor clean --xcode
vapor xcode -n

mv README.md README.md.bu

echo "# API Documentation" > README.md
echo "View API documentation for Vapor's modules by choosing one of the modules from the top, then selecting a documented component from the left hand column." >> README.md

jazzy --xcodebuild-arguments -scheme,Vapor --module Auth --output ../auth xcodebuild
jazzy --xcodebuild-arguments -scheme,Vapor --module Cache --output ../cache xcodebuild
jazzy --xcodebuild-arguments -scheme,Vapor --module Cookies --output ../cookies xcodebuild
jazzy --xcodebuild-arguments -scheme,Vapor --module Sessions --output ../sessions xcodebuild
jazzy --xcodebuild-arguments -scheme,Vapor --module Vapor --output ../vapor xcodebuild

jazzy --xcodebuild-arguments -scheme,Vapor --module WebSockets --output ../websockets xcodebuild
jazzy --xcodebuild-arguments -scheme,Vapor --module SMTP --output ../smtp xcodebuild
jazzy --xcodebuild-arguments -scheme,Vapor --module HTTP --output ../http xcodebuild
jazzy --xcodebuild-arguments -scheme,Vapor --module Transport --output ../transport xcodebuild

jazzy --xcodebuild-arguments -scheme,Vapor --module Fluent --output ../fluent xcodebuild

rm README.md
mv README.md.bu README.md
