// Generated from src/dsa/content/lessons/swift-control-flow/swift-break-continue.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [4, 9, 15, 22, 31, 40]
var firstOver20 = -1

for n in numbers {
    if n > 20 {
        firstOver20 = n
        break
    }
    print("Checked \(n)")
}
print("First number over 20: \(firstOver20)")
