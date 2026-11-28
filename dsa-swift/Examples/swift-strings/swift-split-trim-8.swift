// Generated from src/dsa/content/lessons/swift-strings/swift-split-trim.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

let padded = "   hello world  \n"
print("[" + padded.trimmingCharacters(in: .whitespacesAndNewlines) + "]")
print("[" + "  hi  ".trimmingCharacters(in: .whitespaces) + "]")
