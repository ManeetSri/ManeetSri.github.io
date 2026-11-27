// Generated from src/dsa/content/lessons/swift-control-flow/swift-switch.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let point = (3, 0)

switch point {
case (let x, 0):
    print("On the x-axis at x = \(x)")
case (0, let y):
    print("On the y-axis at y = \(y)")
case let (x, y):
    print("At (\(x), \(y))")
}
