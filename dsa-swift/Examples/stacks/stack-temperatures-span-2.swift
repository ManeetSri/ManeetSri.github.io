// Generated from src/dsa/content/lessons/stacks/stack-temperatures-span.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct StockSpanner {
    private var stack: [(price: Int, span: Int)] = []

    mutating func next(_ price: Int) -> Int {
        var span = 1                                   // today counts
        while let top = stack.last, top.price <= price {
            span += top.span                           // absorb the days it already covered
            stack.removeLast()
        }
        stack.append((price, span))
        return span
    }
}

var spanner = StockSpanner()
let prices = [100, 80, 60, 70, 60, 75, 85]
print(prices.map { spanner.next($0) })
