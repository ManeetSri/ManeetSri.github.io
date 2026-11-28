// Generated from src/dsa/content/lessons/swift-generics/swift-generic-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sortedUnique<T>(_ items: [T]) -> [T] where T: Hashable & Comparable {
    Array(Set(items)).sorted()
}

print(sortedUnique([5, 1, 5, 3, 1]))
print(sortedUnique(["b", "a", "b"]))
