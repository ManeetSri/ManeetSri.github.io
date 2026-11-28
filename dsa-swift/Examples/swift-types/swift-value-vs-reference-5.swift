// Generated from src/dsa/content/lessons/swift-types/swift-value-vs-reference.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct TaskValue {
    var done = false
}

class TaskObject {
    var done = false
}

var values = [TaskValue(), TaskValue()]
let backupValues = values
values[0].done = true
print("Value backup changed?", backupValues[0].done)

let objects = [TaskObject(), TaskObject()]
let backupObjects = objects
objects[0].done = true
print("Object backup changed?", backupObjects[0].done)
