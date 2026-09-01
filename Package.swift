// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PopupKit",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "PopupKit", targets: ["PopupKit"])
    ],
    targets: [
        .target(name: "PopupKit"),
        .testTarget(name: "PopupKitTests", dependencies: ["PopupKit"])
    ]
)
