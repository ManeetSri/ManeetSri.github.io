// swift-tools-version: 6.2
// The System Design course's companion package. Katas live in Exercises (your code) and Solutions
// (reference answers); the tests compile against either:
//   swift test --filter <Kata>Tests              your Exercises
//   swift test -Xswiftc -DSOLUTIONS              every reference solution
// Swift 6 language mode: strict concurrency checking is part of what the course teaches. Some katas use Swift 6.2
// features (nonisolated(nonsending), @concurrent, weak let), so the package needs Xcode 26 or later.
import PackageDescription

let package = Package(
    name: "DesignSwift",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [
        .library(name: "DesignKit", targets: ["DesignKit"]),
    ],
    targets: [
        .target(name: "DesignKit"),
        .target(name: "Exercises", dependencies: ["DesignKit"]),
        .target(name: "Solutions", dependencies: ["DesignKit"]),
        .testTarget(name: "DesignTests", dependencies: ["DesignKit", "Exercises", "Solutions"]),
        .testTarget(name: "DesignKitTests", dependencies: ["DesignKit"]),
    ],
    swiftLanguageModes: [.v6]
)
