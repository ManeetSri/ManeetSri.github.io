// Generated from src/dsa/content/lessons/binary-search/bs-linear-search.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func linearSearch(_ items: [Int], for target: Int) -> Int? {
    for i in items.indices {
        if items[i] == target {
            return i                  // the first match wins
        }
    }
    return nil                        // looked everywhere: not here
}

let ages = [34, 7, 19, 52, 7, 41]
if let index = linearSearch(ages, for: 7) {
    print("7 is at index \(index)")
}
print(linearSearch(ages, for: 99) == nil)
