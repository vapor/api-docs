cd code

rm -rf vapor
git clone git@github.com:vapor/vapor.git
cd vapor 
swift package generate-xcodeproj

echo "# API Documentation" > README.md
echo "View API documentation for Vapor's modules by choosing one of the modules from the top, then selecting a documented component from the left hand column." >> README.md

jazzy -x -scheme,Vapor --module Cache --output ../../cache
jazzy -x -scheme,Vapor --module Configs --output ../../configs
jazzy -x -scheme,Vapor --module Testing --output ../../testing
jazzy -x -scheme,Vapor --module Sessions --output ../../sessions
jazzy -x -scheme,Vapor --module Vapor --output ../../vapor
jazzy -x -scheme,Vapor --module Bits --output ../../bits
jazzy -x -scheme,Vapor --module Debugging --output ../../debugging
jazzy -x -scheme,Vapor --module Core --output ../../core
jazzy -x -scheme,Vapor --module Crypto --output ../../crypto
jazzy -x -scheme,Vapor --module Node --output ../../node
jazzy -x -scheme,Vapor --module PathIndexable --output ../../pathindexable
jazzy -x -scheme,Vapor --module JSON --output ../../json
jazzy -x -scheme,Vapor --module Branches --output ../../branches
jazzy -x -scheme,Vapor --module Routing --output ../../routing
jazzy -x -scheme,Vapor --module Multipart --output ../../multipart
jazzy -x -scheme,Vapor --module FormData --output ../../formdata
jazzy -x -scheme,Vapor --module BCrypt --output ../../bcrypt
jazzy -x -scheme,Vapor --module WebSockets --output ../../websockets
jazzy -x -scheme,Vapor --module SMTP --output ../../smtp
jazzy -x -scheme,Vapor --module HTTP --output ../../http
jazzy -x -scheme,Vapor --module URI --output ../../uri
jazzy -x -scheme,Vapor --module Transport --output ../../transport
jazzy -x -scheme,Vapor --module Sockets --output ../../sockets

cd ..

rm -rf fluent
git clone git@github.com:vapor/fluent.git
cd fluent 
swift package generate-xcodeproj

echo "# API Documentation" > README.md
echo "View API documentation for Vapor's modules by choosing one of the modules from the top, then selecting a documented component from the left hand column." >> README.md

jazzy -x -scheme,Fluent --module Fluent --output ../../fluent

cd ../../