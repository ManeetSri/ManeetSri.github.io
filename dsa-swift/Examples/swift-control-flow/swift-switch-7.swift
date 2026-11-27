// Generated from src/dsa/content/lessons/swift-control-flow/swift-switch.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let point = (0, 5)

switch point {
case (0, 0):
    print("At the origin")
case (_, 0):
    print("On the x-axis")
case (0, _):
    print("On the y-axis")
case (-2...2, -2...2):
    print("Close to the origin")
default:
    print("Somewhere else")
}
