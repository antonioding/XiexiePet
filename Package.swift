// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "XiexiePet",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .executable(name: "XiexiePetMac", targets: ["XiexiePetMac"])
  ],
  targets: [
    .executableTarget(
      name: "XiexiePetMac",
      path: "Sources/XiexiePetMac",
      linkerSettings: [
        .linkedFramework("IOKit")
      ]
    )
  ]
)
