// Generated from src/dsa/content/lessons/swift-control-flow/swift-if-else.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let battery = 42

if battery >= 80 {
    print("Full enough")
} else if battery >= 20 {
    print("Fine for today")
} else if battery > 0 {
    print("Charge soon")
} else {
    print("Flat")
}
