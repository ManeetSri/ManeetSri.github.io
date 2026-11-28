// Generated from src/dsa/content/lessons/swift-library/lib-swift-collections.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// What OrderedDictionary gives you: dictionary lookups, plus the order keys first appeared
var firstSeen: [String] = []
var counts: [String: Int] = [:]
for word in "the cat sat on the mat the end".split(separator: " ").map(String.init) {
    if counts[word] == nil {
        firstSeen.append(word)
    }
    counts[word, default: 0] += 1
}
for word in firstSeen {
    print(word, counts[word]!)
}
