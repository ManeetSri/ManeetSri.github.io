// Generated from src/dsa/content/lessons/swift-control-flow/swift-while.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var countdown = 0

while countdown > 0 {
    print("while:", countdown)
    countdown -= 1
}

repeat {
    print("repeat:", countdown)
    countdown -= 1
} while countdown > 0
