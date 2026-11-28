// Generated from src/dsa/content/lessons/fast-swift/fs-memory-layout.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countPrimes(below limit: Int) -> Int {
    var isComposite = [Bool](repeating: false, count: limit)
    var count = 0
    isComposite.withUnsafeMutableBufferPointer { flags in
        for n in 2..<limit where !flags[n] {
            count += 1
            var multiple = n * n
            while multiple < limit {
                flags[multiple] = true
                multiple += n
            }
        }
    }
    return count
}

print(countPrimes(below: 1_000))
print(countPrimes(below: 100_000))
