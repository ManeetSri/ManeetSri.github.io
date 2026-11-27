// Generated from src/dsa/content/lessons/binary-search/bs-sqrt-matrix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func floorRoot(_ x: Int) -> Int {
    if x < 2 {
        return x                   // 0 and 1 are their own roots
    }
    var low = 1
    var high = x / 2               // for x ≥ 2, the root is at most x / 2
    var passes = 0
    while low <= high {
        passes += 1
        let mid = low + (high - low) / 2
        if mid <= x / mid {
            low = mid + 1          // mid × mid ≤ x
        } else {
            high = mid - 1         // mid × mid > x
        }
    }
    print("  \(passes) passes")
    return high                    // the last value that passed
}

print(floorRoot(17))
print(floorRoot(1_000_000_000_000_000_000))
print(floorRoot(Int.max))
