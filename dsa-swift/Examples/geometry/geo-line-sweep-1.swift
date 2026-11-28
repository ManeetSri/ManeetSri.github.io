// Generated from src/dsa/content/lessons/geometry/geo-line-sweep.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Each rectangle is [x1, y1, x2, y2]: it covers x1 ≤ x < x2 and y1 ≤ y < y2
func coveredArea(_ rectangles: [[Int]]) -> Int {
    // Compress y: the distinct edge heights, sorted, and each one's index
    let ys = Array(Set(rectangles.flatMap { [$0[1], $0[3]] })).sorted()
    var slabOf: [Int: Int] = [:]
    for (index, y) in ys.enumerated() {
        slabOf[y] = index
    }
    // Two events per rectangle: +1 cover at its left edge, -1 at its right edge
    var events: [(x: Int, from: Int, to: Int, change: Int)] = []
    for r in rectangles where r[0] < r[2] && r[1] < r[3] {
        events.append((r[0], slabOf[r[1]]!, slabOf[r[3]]!, 1))
        events.append((r[2], slabOf[r[1]]!, slabOf[r[3]]!, -1))
    }
    events.sort { $0.x < $1.x }

    var cover = [Int](repeating: 0, count: max(ys.count - 1, 0))   // slab i is ys[i]..<ys[i + 1]
    var area = 0
    var previousX = events.first?.x ?? 0
    for event in events {
        if event.x > previousX {
            // Nothing changed since previousX, so this whole strip has the same covered length
            var length = 0
            for slab in cover.indices where cover[slab] > 0 {
                length += ys[slab + 1] - ys[slab]
            }
            print("x \(previousX) to \(event.x): covered length \(length), adds \(length * (event.x - previousX))")
            area += length * (event.x - previousX)
            previousX = event.x
        }
        for slab in event.from..<event.to {
            cover[slab] += event.change
        }
    }
    return area
}

print("total:", coveredArea([[0, 0, 4, 3], [2, 1, 6, 5], [5, 0, 8, 2]]))
