// Generated from src/dsa/content/lessons/swift-tooling/swift-assertions-defer.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func demo() {
    print("start")
    defer { print("first defer") }
    defer { print("second defer") }
    print("end of body")
}

demo()
