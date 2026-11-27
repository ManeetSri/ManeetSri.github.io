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

let words = ["paper", "title", "noon", "deed", "level", "radar", "apple"]
var groupIndex: [[Int]: Int] = [:]
var groups: [[String]] = []
for word in words {
    let key = signature(Array(word))
    if let index = groupIndex[key] {
        groups[index].append(word)
    } else {
        groupIndex[key] = groups.count
        groups.append([word])
    }
}
print(groups)
