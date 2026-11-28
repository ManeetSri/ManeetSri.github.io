// Generated from src/dsa/content/lessons/binary-search/bs-classic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func worstCasePasses(_ count: Int) -> Int {
    let items = Array(0..<count)
    let target = count                    // bigger than every element
    var low = 0
    var high = items.count - 1
    var passes = 0
    while low <= high {
        passes += 1
        let mid = low + (high - low) / 2
        if items[mid] == target {
            break
        } else if items[mid] < target {
            low = mid + 1
        } else {
            high = mid - 1
        }
    }
    return passes
}

for count in [10, 1_000, 1_000_000] {
    print("\(count) elements: \(worstCasePasses(count)) passes")
}
