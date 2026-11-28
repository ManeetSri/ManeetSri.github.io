// Generated from src/dsa/content/lessons/swift-generics/swift-generic-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Pair<First, Second> {
    var first: First
    var second: Second

    func swapped() -> Pair<Second, First> {
        Pair<Second, First>(first: second, second: first)
    }
}

let entry = Pair(first: "age", second: 30)
let flipped = entry.swapped()
print(entry.first, entry.second)
print(flipped.first, flipped.second)
