// Generated from src/dsa/content/lessons/swift-strings/swift-split-trim.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let messy = "one, two;three  four"
print(messy.split(whereSeparator: { $0 == "," || $0 == ";" || $0 == " " }))

let text = "line one\nline two\tend"
print(text.split(whereSeparator: { $0.isWhitespace }))
