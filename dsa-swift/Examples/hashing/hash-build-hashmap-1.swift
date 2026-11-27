// Generated from src/dsa/content/lessons/hashing/hash-build-hashmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct HashMap<Key: Hashable, Value> {
    private var buckets: [[(key: Key, value: Value)]] = Array(repeating: [], count: 8)
    private(set) var count = 0

    var bucketCount: Int {
        buckets.count
    }

    private func index(for key: Key) -> Int {
        key.hashValue & (buckets.count - 1)
    }

    subscript(key: Key) -> Value? {
        get {
            for entry in buckets[index(for: key)] where entry.key == key {
                return entry.value
            }
            return nil
        }
        set {
            if let newValue {
                insert(newValue, for: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }

    private mutating func insert(_ value: Value, for key: Key) {
        let bucket = index(for: key)
        if let position = buckets[bucket].firstIndex(where: { $0.key == key }) {
            buckets[bucket][position].value = value      // existing key: replace
            return
        }
        buckets[bucket].append((key, value))              // new key
        count += 1
        if count > buckets.count * 3 / 4 {
            grow()
        }
    }

    @discardableResult
    mutating func removeValue(forKey key: Key) -> Value? {
        let bucket = index(for: key)
        guard let position = buckets[bucket].firstIndex(where: { $0.key == key }) else {
            return nil
        }
        count -= 1
        buckets[bucket].swapAt(position, buckets[bucket].count - 1)
        return buckets[bucket].removeLast().value
    }

    private mutating func grow() {
        var bigger = [[(key: Key, value: Value)]](repeating: [], count: buckets.count * 2)
        for bucket in buckets {
            for entry in bucket {
                bigger[entry.key.hashValue & (bigger.count - 1)].append(entry)
            }
        }
        buckets = bigger
    }

    var keys: [Key] {
        buckets.flatMap { bucket in bucket.map { $0.key } }
    }
}

var ages = HashMap<String, Int>()
ages["Asha"] = 31
ages["Ben"] = 27
ages["Asha"] = 32                       // replaces
print(ages["Asha"] ?? -1, ages["Zoe"] ?? -1, ages.count)
ages["Ben"] = nil
print(ages.count, ages.keys)

var squares = HashMap<Int, Int>()
for number in 0..<1_000 {
    squares[number] = number * number
}
print(squares.count, squares.bucketCount, squares[999] ?? -1)

// A key with a terrible hash: only value % 2 counts, so keys collide constantly
struct ClumsyKey: Hashable {
    let value: Int
    func hash(into hasher: inout Hasher) {
        hasher.combine(value % 2)
    }
}
var clumsy = HashMap<ClumsyKey, String>()
for value in 0..<100 {
    clumsy[ClumsyKey(value: value)] = "#\(value)"
}
clumsy[ClumsyKey(value: 42)] = nil
print(clumsy.count, clumsy[ClumsyKey(value: 41)] ?? "missing", clumsy[ClumsyKey(value: 42)] ?? "missing")

// Compare with Dictionary over a long, mixed run of operations
var mine = HashMap<Int, Int>()
var model: [Int: Int] = [:]
var mismatches = 0
for step in 0..<20_000 {
    let key = (step * 7_919) % 1_000
    if step % 3 == 0 {
        if mine.removeValue(forKey: key) != model.removeValue(forKey: key) {
            mismatches += 1
        }
    } else {
        mine[key] = step
        model[key] = step
    }
    if mine[key] != model[key] || mine.count != model.count {
        mismatches += 1
    }
}
print("mismatches:", mismatches)
