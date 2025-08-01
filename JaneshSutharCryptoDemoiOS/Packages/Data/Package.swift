// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [
        .iOS(.v15),  // Specify the minimum platform version if needed
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Data",
            targets: ["Data"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Common"),  
        .package(path: "../Infrastructure"),  

    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Data",
            dependencies: [
                "Domain", "Common", "Infrastructure",],
            resources: [
                .process("DataSources/Local/Models/CryptoCoin.xcdatamodeld")
            ]),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data"]),
    ]
)
