// Generated from src/dsa/content/lessons/swift-generics/swift-array-literal.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Money: ExpressibleByIntegerLiteral {
    var pennies: Int

    init(integerLiteral pounds: Int) {
        pennies = pounds * 100
    }
}

let price: Money = 5
print(price.pennies)
