// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "handling-files",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc"),
        .package(url: "https://github.com/vapor/multipart.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.3.0"),
        .package(url: "https://github.com/gperdomor/S3", .branch("patch-1"))
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Multipart", "S3"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

