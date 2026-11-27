// Generated from src/dsa/content/lessons/swift-control-flow/swift-break-continue.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let first = [1, 4, 6, 8]
let second = [2, 5, 6]

for a in first {
    for b in second {
        if a + b == 10 {
            print("Found \(a) + \(b)")
            break
        }
    }
}
