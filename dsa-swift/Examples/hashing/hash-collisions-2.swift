// Generated from src/dsa/content/lessons/hashing/hash-collisions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct ChainedTable {
    var buckets: [[(key: Int, value: String)]] = Array(repeating: [], count: 7)

    mutating func insert(_ key: Int, _ value: String) {
        let index = key % buckets.count
        if let position = buckets[index].firstIndex(where: { $0.key == key }) {
            buckets[index][position].value = value       // the key is already here: replace
        } else {
            buckets[index].append((key, value))          // new key: join the chain
        }
    }

    func lookup(_ key: Int) -> String? {
        let index = key % buckets.count
        return buckets[index].first(where: { $0.key == key })?.value
    }
}

var table = ChainedTable()
table.insert(10, "ten")
table.insert(3, "three")
table.insert(17, "seventeen")
table.insert(5, "five")

print(table.buckets[3].map { $0.key })
print(table.lookup(17) ?? "missing")
print(table.lookup(24) ?? "missing")
