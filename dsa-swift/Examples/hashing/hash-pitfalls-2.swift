// Generated from src/dsa/content/lessons/hashing/hash-pitfalls.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var comparisons = 0

struct ToyTable {
    var buckets: [[Int]] = Array(repeating: [], count: 1_024)

    mutating func insert(_ key: Int) {
        let index = key % buckets.count        // predictable: anyone can work it out
        for stored in buckets[index] {
            comparisons += 1
            if stored == key {
                return
            }
        }
        buckets[index].append(key)
    }
}

var normal = ToyTable()
for key in 0..<2_000 {
    normal.insert(key)
}
print("ordinary keys:", comparisons)

comparisons = 0
var attacked = ToyTable()
for i in 0..<2_000 {
    attacked.insert(i * 1_024)               // every one lands in bucket 0
}
print("crafted keys:", comparisons)
