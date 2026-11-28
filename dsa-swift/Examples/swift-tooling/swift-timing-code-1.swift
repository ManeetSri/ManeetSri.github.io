// Generated from src/dsa/content/lessons/swift-tooling/swift-timing-code.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let elapsed = Duration.milliseconds(1500)
print(elapsed)
print(elapsed / .milliseconds(1))
print(Duration.seconds(1) + .milliseconds(250))
print(Duration.seconds(2) / Duration.milliseconds(250))
