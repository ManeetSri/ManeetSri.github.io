// Generated from src/dsa/content/lessons/swift-control-flow/swift-switch.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let temperature = -4

switch temperature {
case ..<0:
    print("Freezing")
case 0..<15:
    print("Cold")
case 15..<25:
    print("Mild")
case 25...:
    print("Hot")
default:
    print("Unreachable")
}
