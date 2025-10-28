// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "WalletApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(name: "WalletApp", targets: ["WalletApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "WalletApp",
            path: "WalletApp"
        )
    ]
)
