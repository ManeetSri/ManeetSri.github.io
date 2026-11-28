// Generated from src/dsa/content/lessons/swift-closures/swift-escaping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func withBorder(_ drawContent: () -> Void) {
    print("+------+")
    drawContent()
    print("+------+")
}

withBorder {
    print("| Hi!  |")
}
