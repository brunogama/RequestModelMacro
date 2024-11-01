// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "RequestModelMacro",
    platforms: [
      .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "RequestModelMacro",
            targets: ["RequestModelMacro"]
        ),
        .executable(
            name: "Examples",
            targets: ["Examples"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax",
            revision: "release/6.0.0"
        ),
    ],
    targets: [
        .target(
            name: "RequestModelMacro",
            dependencies: ["RequestModelMacroInterface"],
            path: "Sources/RequestModelMacro"
        ),
        .testTarget(
            name: "RequestModelMacroTests",
            dependencies: ["RequestModelMacro"],
            path: "Tests/RequestModelMacroTests"
        ),
        .executableTarget(
            name: "Examples",
            dependencies: ["RequestModelMacro"],
            path: "Examples"
        ),
        .macro(
            name: "RequestModelMacroImplementation",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            ],
            path: "Sources/RequestModelMacroImplementation"
        ),
        .testTarget(
            name: "RequestModelMacroImplementationTests",
            dependencies: [
                "RequestModelMacroImplementation",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "Tests/RequestModelMacroImplementationTests"
        ),
        .target(
            name: "RequestModelMacroInterface",
            dependencies: [
                "RequestModelMacroImplementation"
            ],
            path: "Sources/RequestModelMacroInterface"
        ),
    ]
)
