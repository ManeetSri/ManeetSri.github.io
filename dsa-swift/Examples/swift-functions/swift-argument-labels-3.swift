// Generated from src/dsa/content/lessons/swift-functions/swift-argument-labels.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func repeatText(_ text: String, times count: Int) -> String {
    var result = ""
    for _ in 0..<count {
        result += text
    }
    return result
}

print(repeatText("ab", times: 3))
