// Generated from src/dsa/content/lessons/swift-strings/swift-building-strings.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let names = ["Ada", "Grace", "Linus"]
var line = ""
line.reserveCapacity(64)
for name in names {
    line += name
    line += ";"
}
print(line)
