// Generated from src/dsa/content/lessons/swift-collections/swift-collections-are-values.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var settings = ["sound": true]
let backup = settings
settings["sound"] = false
print(backup["sound"] ?? false, settings["sound"] ?? false)

let firstSet: Set = [1]
var secondSet = firstSet
secondSet.insert(2)
print(firstSet.count, secondSet.count)

let greeting = "Hello"
var shout = greeting
shout += "!"
print(greeting, shout)
