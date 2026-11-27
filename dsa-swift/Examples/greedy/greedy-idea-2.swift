// Generated from src/dsa/content/lessons/greedy/greedy-idea.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func mostItems(_ prices: [Int], budget: Int) -> [Int] {
    var left = budget
    var bought: [Int] = []
    for price in prices.sorted() {        // cheapest first
        if price > left { break }         // everything after this costs even more
        bought.append(price)
        left -= price
    }
    return bought
}

print(mostItems([40, 10, 25, 60, 5], budget: 70))
print(mostItems([30, 30, 30], budget: 89))
print(mostItems([100], budget: 70))
