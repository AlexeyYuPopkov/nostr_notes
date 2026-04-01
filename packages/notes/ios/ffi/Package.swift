// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "crypto_module",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "crypto_module", targets: ["crypto_module"])
    ],
    targets: [
        .binaryTarget(
            name: "crypto_module",
            path: "crypto_module.xcframework"
        )
    ]
)