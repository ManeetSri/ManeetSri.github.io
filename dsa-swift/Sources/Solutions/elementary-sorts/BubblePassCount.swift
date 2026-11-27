// Reference solution: Bubble sort's busy passes. In every pass, each value with a bigger value
// somewhere to its left moves exactly one place left, so the passes needed are the furthest
// distance any value has to travel left. That's the largest (original index − sorted index), using
// a stable sort so equal values keep their order, as bubble sort does. O(n log n) time, O(n) space.

public enum BubblePassCount {
    public static func busyPasses(_ numbers: [Int]) -> Int {
        // The original indexes, stably sorted by value: order[p] is where the value that ends
        // up at position p started
        let order = numbers.indices.sorted { (numbers[$0], $0) < (numbers[$1], $1) }
        var passes = 0
        for (sortedIndex, originalIndex) in order.enumerated() {
            passes = max(passes, originalIndex - sortedIndex)
        }
        return passes
    }
}
