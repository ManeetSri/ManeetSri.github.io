// Generated from src/dsa/content/lessons/swift-control-flow/swift-guard.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let orders = [12, 0, 7, -3, 20]
var shipped = 0

for quantity in orders {
    guard quantity > 0 else {
        print("Skipping an order of \(quantity)")
        continue
    }
    shipped += quantity
}
print("Items shipped: \(shipped)")
