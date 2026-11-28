// Generated from src/dsa/content/lessons/swift-collections/swift-choosing-collection.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var line = ["Ada", "Grace", "Linus"]
var head = 0
line.append("Tim")

while head < line.count {
    print("serving \(line[head])")
    head += 1
}
