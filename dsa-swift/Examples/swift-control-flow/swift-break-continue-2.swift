// Generated from src/dsa/content/lessons/swift-control-flow/swift-break-continue.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let guests = ["Ana", "Ben", "Cleo", "Dev"]
let lookingFor = "Cleo"
var found = false
var checks = 0

for guest in guests {
    checks += 1
    if guest == lookingFor {
        found = true
        break
    }
}
print(found ? "\(lookingFor) is on the list" : "\(lookingFor) isn't invited")
print("Checks needed: \(checks)")
