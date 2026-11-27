// Generated from src/dsa/content/lessons/swift-control-flow/swift-switch.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let distance = 7

switch distance {
case 0:
    print("You're here")
case 1...5:
    print("A short walk")
case 6...20:
    print("Take a bike")
default:
    print("Take the train")
}
