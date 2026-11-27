// Generated from src/dsa/content/lessons/interview-playbook/int-ios-flavoured.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A model of the eviction rule, most recently used first. O(n) per call: fine to explain, too slow to ship.
struct ImageCacheModel {
    let budget: Int
    private(set) var entries: [(url: String, bytes: Int)] = []
    private(set) var total = 0

    init(budget: Int) {
        self.budget = budget
    }

    mutating func use(_ url: String) -> Bool {
        guard let index = entries.firstIndex(where: { $0.url == url }) else { return false }
        entries.insert(entries.remove(at: index), at: 0)
        return true
    }

    mutating func insert(_ url: String, bytes: Int) -> [String] {
        if let index = entries.firstIndex(where: { $0.url == url }) {
            total -= entries.remove(at: index).bytes
        }
        entries.insert((url, bytes), at: 0)
        total += bytes
        var evicted: [String] = []
        while total > budget, let oldest = entries.popLast() {   // evict until it fits
            total -= oldest.bytes
            evicted.append(oldest.url)
        }
        return evicted
    }
}

var cache = ImageCacheModel(budget: 100)
_ = cache.insert("a.jpg", bytes: 50)
_ = cache.insert("b.jpg", bytes: 30)
_ = cache.use("a.jpg")
print(cache.insert("c.jpg", bytes: 40))
print(cache.entries.map { $0.url }, cache.total)
print(cache.insert("d.jpg", bytes: 70))
print(cache.entries.map { $0.url }, cache.total)
