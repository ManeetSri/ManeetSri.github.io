// Generated from src/dsa/content/lessons/swift-generics/swift-some-any.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func evens(upTo limit: Int) -> some Sequence<Int> {
    stride(from: 0, through: limit, by: 2)
}

print(Array(evens(upTo: 10)))
print(evens(upTo: 6).reduce(0, +))
