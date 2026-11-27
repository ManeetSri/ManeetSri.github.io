// Generated from src/dsa/content/lessons/swift-control-flow/swift-if-else.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let isWeekend = true
let isRaining = false

if isWeekend && !isRaining {
    print("Go to the park")
}
if !isWeekend || isRaining {
    print("Stay in")
}
