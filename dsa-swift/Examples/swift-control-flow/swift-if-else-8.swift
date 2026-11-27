// Generated from src/dsa/content/lessons/swift-control-flow/swift-if-else.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let hour = 14
let greeting: String

if hour < 12 {
    greeting = "Good morning"
} else if hour < 18 {
    greeting = "Good afternoon"
} else {
    greeting = "Good evening"
}
print(greeting)
