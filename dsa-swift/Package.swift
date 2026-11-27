// swift-tools-version: 6.0
import PackageDescription

// The companion package for the DSA in Swift console.
//
//   swift test --filter HelloSwiftTests                      check your exercise
//   swift test -Xswiftc -DSOLUTIONS                          check every reference solution
//   swift Examples/orientation/start-problem-solving-1.swift run a lesson's example (generated from the lessons)
let package = Package(
    name: "DSASwift",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "DSAKit", targets: ["DSAKit"]),
    ],
    targets: [
        // The data structures you build during the course
        .target(name: "DSAKit"),
        // Your solutions. Every problem starts as a stub that compiles but fails its tests.
        .target(name: "Exercises", dependencies: ["DSAKit"]),
        // Reference solutions with the same API as Exercises
        .target(name: "Solutions", dependencies: ["DSAKit"]),
        // One set of tests, compiled against Exercises by default or Solutions with -DSOLUTIONS
        .testTarget(name: "DSATests", dependencies: ["DSAKit", "Exercises", "Solutions"]),
    ],
    // Swift 6 compiler, Swift 5 language mode: modern Swift without strict-concurrency errors
    // getting in the way before concurrency is taught in Part IX
    swiftLanguageModes: [.v5]
)
