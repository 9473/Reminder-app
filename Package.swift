// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MotivateBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MotivateBar", targets: ["MotivateBar"])
    ],
    targets: [
        .executableTarget(
            name: "MotivateBar",
            path: "Sources"
        )
    ]
)
