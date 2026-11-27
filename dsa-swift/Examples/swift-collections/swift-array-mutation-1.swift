// Generated from src/dsa/content/lessons/swift-collections/swift-array-mutation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var tasks = ["wake up"]
tasks.append("coffee")
tasks.append(contentsOf: ["code", "lunch"])
tasks += ["more code"]
print(tasks)
print(tasks.count)
