// Generated from src/dsa/content/lessons/intervals/iv-intersections.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The overlap of two closed intervals, or nil if they don't meet
func intersection(_ a: [Int], _ b: [Int]) -> [Int]? {
    let start = max(a[0], b[0])     // the later start
    let end = min(a[1], b[1])       // the earlier end
    return start <= end ? [start, end] : nil
}

for (a, b) in [([1, 6], [4, 9]), ([1, 6], [2, 3]), ([1, 6], [6, 8]), ([1, 6], [7, 8])] {
    if let overlap = intersection(a, b) {
        print(a, b, "->", overlap)
    } else {
        print(a, b, "-> none")
    }
}
