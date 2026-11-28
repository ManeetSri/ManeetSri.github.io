// Generated from src/dsa/content/lessons/hashing/hash-build-hashmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct HashSet<Element: Hashable> {
    private var buckets: [[Element]] = Array(repeating: [], count: 8)
    private(set) var count = 0

    private func index(for element: Element) -> Int {
        element.hashValue & (buckets.count - 1)
    }

    func contains(_ element: Element) -> Bool {
        buckets[index(for: element)].contains(element)
    }

    @discardableResult
    mutating func insert(_ element: Element) -> Bool {
        guard !contains(element) else {
            return false                  // already there: sets hold each value once
        }
        buckets[index(for: element)].append(element)
        count += 1
        if count > buckets.count * 3 / 4 {
            let old = buckets
            buckets = Array(repeating: [], count: old.count * 2)
            for bucket in old {
                for item in bucket {
                    buckets[index(for: item)].append(item)   // index(for:) now uses the new count
                }
            }
        }
        return true
    }

    @discardableResult
    mutating func remove(_ element: Element) -> Bool {
        let bucket = index(for: element)
        guard let position = buckets[bucket].firstIndex(of: element) else {
            return false
        }
        buckets[bucket].swapAt(position, buckets[bucket].count - 1)
        buckets[bucket].removeLast()
        count -= 1
        return true
    }
}

var words = HashSet<String>()
for word in "the cat and the hat and the bat".split(separator: " ") {
    words.insert(String(word))
}
print(words.count)
print(words.contains("hat"), words.contains("rat"))
print(words.insert("cat"), words.remove("cat"), words.remove("cat"))
print(words.count)
