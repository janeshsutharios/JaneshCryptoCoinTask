// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Infrastructure",
    platforms: [
        .iOS(.v15),  // Specify the minimum platform version if needed
    ],
    
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Infrastructure",
            targets: ["Infrastructure"]),
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../Domain"),  
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Infrastructure",
            dependencies: [
                "Common", "Domain"              
            ]),
        .testTarget(
            name: "InfrastructureTests",
            dependencies: ["Infrastructure"]),
    ]
)

