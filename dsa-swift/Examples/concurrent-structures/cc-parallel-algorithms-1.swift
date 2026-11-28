// Generated from src/dsa/content/lessons/concurrent-structures/cc-parallel-algorithms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A tiny seeded generator, so the "random" data is the same on every run
struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

func merge(_ first: [Int], _ second: [Int]) -> [Int] {
    var result: [Int] = []
    result.reserveCapacity(first.count + second.count)
    var i = 0
    var j = 0
    while i < first.count && j < second.count {
        if second[j] < first[i] {
            result.append(second[j])
            j += 1
        } else {
            result.append(first[i])
            i += 1
        }
    }
    result.append(contentsOf: first[i...])
    result.append(contentsOf: second[j...])
    return result
}

/// Sorts `chunkCount` chunks in parallel, then merges sorted runs in pairs, each round in parallel
func parallelSorted(_ items: [Int], chunkCount: Int) async -> [Int] {
    let size = max(1, (items.count + chunkCount - 1) / chunkCount)     // ceiling division
    let starts = Array(stride(from: 0, to: items.count, by: size))

    var runs = await withTaskGroup(of: (index: Int, run: [Int]).self) { group in
        for (index, start) in starts.enumerated() {
            let chunk = Array(items[start..<min(start + size, items.count)])   // the child's own copy
            group.addTask { (index, chunk.sorted()) }
        }
        var sortedChunks = Array(repeating: [Int](), count: starts.count)
        for await result in group {
            sortedChunks[result.index] = result.run       // results arrive in any order
        }
        return sortedChunks
    }

    while runs.count > 1 {
        let current = runs
        runs = await withTaskGroup(of: (index: Int, run: [Int]).self) { group in
            for pair in stride(from: 0, to: current.count, by: 2) {
                let first = current[pair]
                let second = pair + 1 < current.count ? current[pair + 1] : []
                group.addTask { (pair / 2, merge(first, second)) }
            }
            var merged = Array(repeating: [Int](), count: (current.count + 1) / 2)
            for await result in group {
                merged[result.index] = result.run
            }
            return merged
        }
    }
    return runs.first ?? []
}

var generator = SeededGenerator(state: 2_024)
let data = (0..<50_000).map { _ in Int.random(in: 0..<1_000_000, using: &generator) }
let sorted = await parallelSorted(data, chunkCount: 8)
print(sorted == data.sorted(), sorted.count)
print(await parallelSorted([5, 3, 9, 1, 7, 2], chunkCount: 4))
print(await parallelSorted([], chunkCount: 4))
