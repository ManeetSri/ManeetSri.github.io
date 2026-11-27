// Generated from src/dsa/content/lessons/swift-strings/swift-split-trim.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func trimmed(_ text: String) -> Substring {
    guard let start = text.firstIndex(where: { !$0.isWhitespace }),
          let end = text.lastIndex(where: { !$0.isWhitespace }) else {
        return ""
    }
    return text[start...end]
}

print("[" + trimmed("   hello world  ") + "]")
print("[" + trimmed("     ") + "]")
