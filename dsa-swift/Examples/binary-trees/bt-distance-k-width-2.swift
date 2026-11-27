// Generated from src/dsa/content/lessons/binary-trees/bt-distance-k-width.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Place numbers down a chain of right children, watching for overflow
var place = 0
for level in 1..<100 {
    let (doubled, overflowed) = place.multipliedReportingOverflow(by: 2)
    let (next, overflowedAgain) = doubled.addingReportingOverflow(1)
    if overflowed || overflowedAgain {
        print("level \(level): the place number no longer fits in an Int")
        break
    }
    place = next
}
print(place == Int.max)
