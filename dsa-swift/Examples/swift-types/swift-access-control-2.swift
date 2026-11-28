// Generated from src/dsa/content/lessons/swift-types/swift-access-control.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct StepCounter {
    private(set) var steps = 0

    mutating func walk(_ count: Int) {
        guard count > 0 else { return }
        steps += count
    }
}

var counter = StepCounter()
counter.walk(500)
counter.walk(-20)
counter.walk(250)
print(counter.steps)
