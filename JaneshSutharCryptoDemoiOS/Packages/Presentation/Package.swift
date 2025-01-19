// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Presentation",
    platforms: [
        .iOS(.v15),  // Specify the minimum platform version if needed
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Presentation",
            targets: ["Presentation"]),
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../Infrastructure" ),  
        .package(path: "../Data" ),  
        .package(path: "../Domain"),  

    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Presentation",
            dependencies: [
                "Common", "Infrastructure", "Data", "Domain",     
            ]),
        .testTarget(
            name: "PresentationTests",
            dependencies: ["Presentation"]),
    ]
)
