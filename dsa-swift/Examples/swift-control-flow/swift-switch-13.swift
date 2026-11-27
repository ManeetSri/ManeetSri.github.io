// Generated from src/dsa/content/lessons/swift-control-flow/swift-switch.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 5
var description = "\(n) is"

switch n {
case 2, 3, 5, 7:
    description += " a prime number, and also"
    fallthrough
default:
    description += " an integer."
}
print(description)
