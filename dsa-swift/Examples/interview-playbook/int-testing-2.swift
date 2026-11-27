// Generated from src/dsa/content/lessons/interview-playbook/int-testing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct SeededRandom: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

func longestRun(_ values: [Int]) -> Int {
    guard !values.isEmpty else { return 0 }
    var best = 1
    var current = 1
    for i in values.indices.dropFirst() {
        current = values[i] == values[i - 1] ? current + 1 : 1
        best = max(best, current)
    }
    return best
}

// Obviously right, but O(n²): from every start, count how far the same value continues
func longestRunSlow(_ values: [Int]) -> Int {
    var best = 0
    for start in values.indices {
        var end = start
        while end < values.count && values[end] == values[start] {
            end += 1
        }
        best = max(best, end - start)
    }
    return best
}

var random = SeededRandom(state: 42)
var mismatches = 0
for _ in 0..<1_000 {
    let length = Int.random(in: 0...8, using: &random)
    let values = (0..<length).map { _ in Int.random(in: 0...2, using: &random) }
    if longestRun(values) != longestRunSlow(values) {
        mismatches += 1
    }
}
print("1000 random arrays, \(mismatches) mismatches")
