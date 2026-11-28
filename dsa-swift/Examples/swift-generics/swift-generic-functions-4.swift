// Generated from src/dsa/content/lessons/swift-generics/swift-generic-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func hasDuplicates<T: Hashable>(_ items: [T]) -> Bool {
    var seen: Set<T> = []
    for item in items {
        if !seen.insert(item).inserted {
            return true
        }
    }
    return false
}

print(hasDuplicates([1, 2, 3, 2]))
print(hasDuplicates(["a", "b", "c"]))
print(hasDuplicates([Character]("hello")))
