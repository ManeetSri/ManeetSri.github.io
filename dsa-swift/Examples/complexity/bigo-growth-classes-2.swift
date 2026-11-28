// Generated from src/dsa/content/lessons/complexity/bigo-growth-classes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func subsets(of items: [String]) -> [[String]] {
    guard let first = items.first else {
        return [[]]
    }
    let withoutFirst = subsets(of: Array(items.dropFirst()))
    return withoutFirst + withoutFirst.map { [first] + $0 }
}

for subset in subsets(of: ["a", "b", "c"]) {
    print(subset)
}
print(subsets(of: ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]).count)
