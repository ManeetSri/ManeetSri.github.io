// Reference solution: Recursion trees, level by level. Describe a level by how many calls have each
// argument; calls with the same argument make the same children, so each level is built from the last
// in O(distinct arguments). O(n²) for fib(n), O(log n) for the halves.

public enum RecursionTreeLevels {
    public static func fibonacciLevels(_ n: Int) -> [Int] {
        var level = [n: 1]                              // argument → calls on this level
        var counts: [Int] = []
        while !level.isEmpty {
            counts.append(level.values.reduce(0, +))
            var next: [Int: Int] = [:]
            for (argument, count) in level where argument >= 2 {
                next[argument - 1, default: 0] += count
                next[argument - 2, default: 0] += count
            }
            level = next
        }
        return counts
    }

    public static func halvesLevels(_ n: Int) -> [Int] {
        var level = [n: 1]                              // range size → calls on this level
        var counts: [Int] = []
        while !level.isEmpty {
            counts.append(level.values.reduce(0, +))
            var next: [Int: Int] = [:]
            for (size, count) in level where size >= 2 {
                next[(size + 1) / 2, default: 0] += count   // low...mid
                next[size / 2, default: 0] += count         // mid + 1...high
            }
            level = next
        }
        return counts
    }
}
