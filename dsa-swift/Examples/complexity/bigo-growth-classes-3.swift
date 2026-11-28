// Generated from src/dsa/content/lessons/complexity/bigo-growth-classes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func orderings(of items: [String]) -> [[String]] {
    if items.count <= 1 {
        return [items]
    }
    var result: [[String]] = []
    for (index, item) in items.enumerated() {
        var rest = items
        rest.remove(at: index)
        for ordering in orderings(of: rest) {
            result.append([item] + ordering)
        }
    }
    return result
}

for ordering in orderings(of: ["a", "b", "c"]) {
    print(ordering.joined())
}
print(orderings(of: ["a", "b", "c", "d", "e", "f", "g"]).count)
