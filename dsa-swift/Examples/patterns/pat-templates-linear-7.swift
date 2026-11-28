// Generated from src/dsa/content/lessons/patterns/pat-templates-linear.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Prefix sums: build once, then any range total in O(1)
func prefixSums(_ items: [Int]) -> [Int] {
    var prefix = [0]                              // prefix[i] is the total of items[0..<i]
    prefix.reserveCapacity(items.count + 1)
    for value in items {
        prefix.append(prefix[prefix.count - 1] + value)
    }
    return prefix
}

let steps = [3, 1, 4, 1, 5, 9, 2, 6]
let prefix = prefixSums(steps)
func total(_ from: Int, _ to: Int) -> Int {      // items[from...to], both included
    prefix[to + 1] - prefix[from]
}
print(prefix)
print(total(2, 5), total(0, 7), total(3, 3))
