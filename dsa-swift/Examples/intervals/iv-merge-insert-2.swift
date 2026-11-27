// Generated from src/dsa/content/lessons/intervals/iv-merge-insert.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Closed: [start, end] includes both ends
func overlapClosed(_ a: [Int], _ b: [Int]) -> Bool {
    a[0] <= b[1] && b[0] <= a[1]
}

// Half-open: [start, end) includes the start but not the end
func overlapHalfOpen(_ a: [Int], _ b: [Int]) -> Bool {
    a[0] < b[1] && b[0] < a[1]
}

for (a, b) in [([1, 4], [4, 6]), ([1, 4], [3, 6]), ([1, 4], [5, 6]), ([1, 9], [3, 4])] {
    print(a, b, "closed:", overlapClosed(a, b), "half-open:", overlapHalfOpen(a, b))
}
