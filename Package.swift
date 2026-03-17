// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "Awave",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .executable(
      name: "Awave",
      targets: ["App"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", exact: "1.8.0"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.11.0")),
  ],
  targets: [
    .executableTarget(
      name: "App",
      dependencies: [
        .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts"),
        .product(name: "Alamofire", package: "Alamofire"),
      ],
      path: "Sources/App",
      exclude: [
        "Info.plist"
      ],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
