// Generated from src/dsa/content/lessons/swift-generics/swift-generic-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstAndLast<T>(_ items: [T]) -> (first: T, last: T)? {
    guard let first = items.first, let last = items.last else {
        return nil
    }
    return (first, last)
}

if let ends = firstAndLast([4, 8, 15, 16]) {
    print(ends.first, ends.last)
}
if let ends = firstAndLast(["a", "b", "c"]) {
    print(ends.first, ends.last)
}
