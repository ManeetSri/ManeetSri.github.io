# DSA in Swift: companion package

Every example, exercise and test for the private DSA-in-Swift console.

```bash
cd dsa-swift
swift build                                               # first build takes a minute
swift test --filter HelloSwiftTests                       # check one exercise
swift test -Xswiftc -DSOLUTIONS                           # check every reference solution
swift Examples/orientation/start-problem-solving-1.swift  # run one of a lesson's examples
```

| Folder | What's in it |
| --- | --- |
| `Sources/Exercises` | Your solutions. Each problem starts as a stub that compiles but fails its tests. The console's editor starts from the same stub; on the dev server its Save to package button writes your code here. |
| `Sources/Solutions` | Reference solutions with the same API. Try first, use the hints, then peek. |
| `Sources/DSAKit` | The data structures you build during the course. |
| `Tests/DSATests` | One set of tests, compiled against `Exercises` by default or `Solutions` with `-DSOLUTIONS`. |
| `Examples` | Every runnable lesson example as its own file, named `<module>/<lesson>-<n>.swift`. Generated from the lessons by `npm run dsa:examples`, so don't edit them here. |

Folders inside `Exercises`, `Solutions` and `Tests/DSATests` are named after the console's module ids (`orientation`, `swift-first-steps`, …).
Each problem is a caseless `enum` with a `static` function, so names never clash across hundreds of problems.
The package uses the Swift 6 compiler in Swift 5 language mode. Use `swift run -c release` when timing code.
