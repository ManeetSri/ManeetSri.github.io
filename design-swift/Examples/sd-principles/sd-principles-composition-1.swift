// Generated from src/dsa/design/content/lessons/sd-principles/sd-principles-composition.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

class ImageCache {
    private(set) var keys: [String] = []

    func insert(_ key: String) {
        keys.append(key)
    }

    func insert(contentsOf newKeys: [String]) {
        for key in newKeys {
            insert(key)          // the parent reuses its own single insert
        }
    }
}

final class CountingImageCache: ImageCache {
    private(set) var insertions = 0

    override func insert(_ key: String) {
        insertions += 1
        super.insert(key)
    }

    override func insert(contentsOf newKeys: [String]) {
        insertions += newKeys.count
        super.insert(contentsOf: newKeys)
    }
}

let cache = CountingImageCache()
cache.insert(contentsOf: ["avatar-1", "avatar-2", "avatar-3"])
print("Subclass: stored \(cache.keys.count), counted \(cache.insertions)")

// Composition: own a cache and forward to it through its public interface
final class InsertionCounter {
    private let cache = ImageCache()
    private(set) var insertions = 0

    var keys: [String] { cache.keys }

    func insert(_ key: String) {
        insertions += 1
        cache.insert(key)
    }

    func insert(contentsOf newKeys: [String]) {
        insertions += newKeys.count
        cache.insert(contentsOf: newKeys)
    }
}

let counter = InsertionCounter()
counter.insert(contentsOf: ["avatar-1", "avatar-2", "avatar-3"])
print("Composed: stored \(counter.keys.count), counted \(counter.insertions)")
