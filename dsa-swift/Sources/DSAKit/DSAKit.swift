// DSAKit grows as you work through the course. Every data structure you build in a lesson,
// from DynamicArray and LinkedList to Heap, Trie, Graph and SegmentTree, ends up here, tested,
// so later lessons can build on it.

/// Times a piece of work. Build with `-c release` before trusting the numbers: debug builds can be
/// 10–100× slower for algorithm-heavy code.
@discardableResult
public func measure<Result>(_ label: String, _ work: () throws -> Result) rethrows -> Result {
    let clock = ContinuousClock()
    var result: Result?
    let elapsed = try clock.measure { result = try work() }
    print("\(label): \(elapsed)")
    return result!
}
