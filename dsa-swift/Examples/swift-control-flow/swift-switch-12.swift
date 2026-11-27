// Generated from src/dsa/content/lessons/swift-control-flow/swift-switch.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let score = 68

let grade = switch score {
case 90...100: "A"
case 70..<90: "B"
case 50..<70: "C"
default: "F"
}
print(grade)
