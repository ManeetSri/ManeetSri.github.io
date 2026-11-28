// Generated from src/dsa/content/lessons/binary-search/bs-sqrt-matrix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func floorRoot(_ x: Int) -> Int {
    var low = 0
    var high = x
    var best = 0
    while low <= high {
        let mid = low + (high - low) / 2
        if mid * mid <= x {
            best = mid             // mid works: remember it and try bigger
            low = mid + 1
        } else {
            high = mid - 1         // mid is too big
        }
    }
    return best
}

for x in [0, 1, 15, 16, 17, 1_000_000, 2_000_000_000] {
    print("floorRoot(\(x)) = \(floorRoot(x))")
}
