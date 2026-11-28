// Generated from src/dsa/content/lessons/swift-functions/swift-inout-swap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func double(_ number: inout Int) {
    number *= 2
}

var price = 15
double(&price)
print(price)
double(&price)
print(price)
