// Generated from src/dsa/content/lessons/swift-library/lib-stdlib-algorithms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Counter {
    var value = 0
}

let shared = Array(repeating: Counter(), count: 3)
shared[0].value += 1
print(shared.map(\.value))

let separate = (0..<3).map { _ in Counter() }
separate[0].value += 1
print(separate.map(\.value))
