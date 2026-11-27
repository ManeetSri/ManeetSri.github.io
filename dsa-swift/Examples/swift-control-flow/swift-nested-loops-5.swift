// Generated from src/dsa/content/lessons/swift-control-flow/swift-nested-loops.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let size = 5

for row in 1...size {
    var line = ""
    for column in 1...size {
        let product = "\(row * column)"
        let padding = String(repeating: " ", count: 4 - product.count)
        line += padding + product
    }
    print(line)
}
