// Generated from src/dsa/content/lessons/swift-functions/swift-defining-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var log: [String] = []

@discardableResult
func record(message: String) -> Int {
    log.append(message)
    return log.count
}

record(message: "Started")
record(message: "Loaded data")
let entries = record(message: "Finished")
print(entries)
