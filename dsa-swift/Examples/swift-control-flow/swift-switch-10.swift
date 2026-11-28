// Generated from src/dsa/content/lessons/swift-control-flow/swift-switch.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let point = (4, -4)

switch point {
case let (x, y) where x == y:
    print("On the line y = x")
case let (x, y) where x == -y:
    print("On the line y = -x")
case let (x, y):
    print("(\(x), \(y)) is on neither line")
}
