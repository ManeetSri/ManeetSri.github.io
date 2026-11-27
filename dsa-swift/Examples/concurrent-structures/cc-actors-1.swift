// Generated from src/dsa/content/lessons/concurrent-structures/cc-actors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A memo cache for Collatz step counts: how many steps of "halve if even, else 3n + 1" reach 1
actor CollatzCache {
    private var steps: [Int: Int] = [1: 0]
    private(set) var computed = 0

    func stepCount(for start: Int) -> Int {
        // Walk forward until a number whose answer is already known
        var path: [Int] = []
        var n = start
        while steps[n] == nil {
            path.append(n)
            n = n.isMultiple(of: 2) ? n / 2 : 3 * n + 1
        }
        // Fill in the answers backwards along the path
        var count = steps[n]!
        for number in path.reversed() {
            count += 1
            steps[number] = count
            computed += 1
        }
        return count
    }

    var cachedCount: Int {
        steps.count
    }
}

let cache = CollatzCache()
let results = await withTaskGroup(of: (Int, Int).self) { group in
    for start in [27, 9, 97, 27, 6, 9, 871] {
        group.addTask { (start, await cache.stepCount(for: start)) }
    }
    var all: [(Int, Int)] = []
    for await result in group {
        all.append(result)
    }
    return all
}
for (start, steps) in results.sorted(by: { $0.0 < $1.0 }) {
    print(start, steps)
}
print(await cache.computed, await cache.cachedCount)
