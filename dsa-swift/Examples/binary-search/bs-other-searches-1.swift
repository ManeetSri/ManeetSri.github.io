// Generated from src/dsa/content/lessons/binary-search/bs-other-searches.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// 999,999 sorted values whose count the search pretends not to know
let hidden = Array(stride(from: 3, to: 3_000_000, by: 3))
var probes = 0

func value(at index: Int) -> Int? {
    probes += 1
    return index < hidden.count ? hidden[index] : nil       // nil past the end
}

func exponentialSearch(for target: Int) -> Int? {
    // 1. Gallop: double the bound until it reaches the target or passes the end
    var bound = 1
    while let found = value(at: bound), found < target {
        bound *= 2
    }
    // 2. Binary search between the last two bounds
    var low = bound / 2
    var high = bound
    while low <= high {
        let mid = low + (high - low) / 2
        guard let found = value(at: mid) else {
            high = mid - 1                                   // past the end counts as too big
            continue
        }
        if found == target {
            return mid
        } else if found < target {
            low = mid + 1
        } else {
            high = mid - 1
        }
    }
    return nil
}

for target in [3, 30, 3_000, 2_999_997, 4] {
    probes = 0
    let index = exponentialSearch(for: target)
    print("\(target): index \(index.map { String($0) } ?? "none"), \(probes) probes")
}
