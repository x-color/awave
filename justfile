build:
    swift build

install:
    swift build -c release
    mkdir -p Awave.app/Contents/MacOS
    mkdir -p Awave.app/Contents/Resources
    cp .build/release/Awave Awave.app/Contents/MacOS/Awave
    cp Sources/App/Info.plist Awave.app/Contents/Info.plist
    cp Sources/App/Resources/Awave.icns Awave.app/Contents/Resources/Awave.icns
    cp -R Awave.app /Applications/
    rm -rf Awave.app
    xattr -dr com.apple.quarantine /Applications/Awave.app

gen-icon:
    mkdir -p Resources/Awave.iconset
    sips -z 16 16     Resources/icon.png --out Resources/Awave.iconset/icon_16x16.png
    sips -z 32 32     Resources/icon.png --out Resources/Awave.iconset/icon_16x16@2x.png
    sips -z 32 32     Resources/icon.png --out Resources/Awave.iconset/icon_32x32.png
    sips -z 64 64     Resources/icon.png --out Resources/Awave.iconset/icon_32x32@2x.png
    sips -z 128 128   Resources/icon.png --out Resources/Awave.iconset/icon_128x128.png
    sips -z 256 256   Resources/icon.png --out Resources/Awave.iconset/icon_128x128@2x.png
    sips -z 256 256   Resources/icon.png --out Resources/Awave.iconset/icon_256x256.png
    sips -z 512 512   Resources/icon.png --out Resources/Awave.iconset/icon_256x256@2x.png
    sips -z 512 512   Resources/icon.png --out Resources/Awave.iconset/icon_512x512.png
    sips -z 1024 1024 Resources/icon.png --out Resources/Awave.iconset/icon_512x512@2x.png
    iconutil -c icns Resources/Awave.iconset -o Sources/App/Resources/Awave.icns
    rm -rf Resources/Awave.iconset

format:
    swift format -r --in-place .

lint:
    swift format lint -r -s .