// Generated from src/dsa/content/lessons/swift-generics/swift-protocols.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

protocol Resettable {
    mutating func reset()
}

struct Counter: Resettable {
    var count = 0

    mutating func reset() {
        count = 0
    }
}

final class Timer: Resettable {
    var seconds = 90

    func reset() {
        seconds = 0
    }
}

var clicks = Counter(count: 12)
clicks.reset()
let timer = Timer()
timer.reset()
print(clicks.count, timer.seconds)
