// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Reminder",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Reminder", targets: ["Reminder"])
    ],
    targets: [
        .executableTarget(
            name: "Reminder",
            path: "Sources"
        )
    ]
)
