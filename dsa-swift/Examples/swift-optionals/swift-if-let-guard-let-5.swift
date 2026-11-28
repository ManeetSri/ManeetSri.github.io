// Generated from src/dsa/content/lessons/swift-optionals/swift-if-let-guard-let.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let entries = ["12", "seven", "30", "", "8"]
var total = 0
var skipped = 0

for entry in entries {
    guard let value = Int(entry) else {
        skipped += 1
        continue
    }
    total += value
}
print("Total: \(total), skipped: \(skipped)")
