// Generated from src/dsa/content/lessons/swift-collections/swift-counting-grouping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let words = ["apple", "avocado", "banana", "blueberry", "cherry", "apricot"]
let byLength = Dictionary(grouping: words, by: { $0.count })

for length in byLength.keys.sorted() {
    print(length, byLength[length] ?? [])
}
