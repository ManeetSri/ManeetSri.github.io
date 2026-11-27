// Generated from src/dsa/content/lessons/strings-basic/str-isomorphic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func signature<T: Hashable>(_ items: [T]) -> [Int] {
    var firstSeen: [T: Int] = [:]
    var result: [Int] = []
    for (index, item) in items.enumerated() {
        if firstSeen[item] == nil {
            firstSeen[item] = index
        }
        result.append(firstSeen[item]!)
    }
    return result
}

print(signature(Array("paper")))
print(signature(Array("title")))
print(signature(Array("ab")), signature(Array("cc")))
print(signature("sun moon moon sun".split(separator: " ").map(String.init)))
