// Generated from src/dsa/content/lessons/range-queries/rq-offline.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// How many days in left...right have a price ≤ budget? Offline, with a Fenwick tree over days
struct Fenwick {
    private var tree: [Int]
    init(count: Int) { tree = [Int](repeating: 0, count: count + 1) }

    /// Adds delta at position index (0-based)
    mutating func add(_ index: Int, _ delta: Int) {
        var i = index + 1
        while i < tree.count {
            tree[i] += delta
            i += i & -i
        }
    }

    /// The total of positions 0..<count
    func prefix(_ count: Int) -> Int {
        var i = count
        var total = 0
        while i > 0 {
            total += tree[i]
            i -= i & -i
        }
        return total
    }
}

func cheapDays(prices: [Int], queries: [(left: Int, right: Int, budget: Int)]) -> [Int] {
    let days = prices.indices.sorted { prices[$0] < prices[$1] }             // cheapest day first
    let order = queries.indices.sorted { queries[$0].budget < queries[$1].budget }
    var marked = Fenwick(count: prices.count)                                 // 1 at each day ≤ budget
    var answers = [Int](repeating: 0, count: queries.count)
    var next = 0
    for q in order {
        let (left, right, budget) = queries[q]
        while next < days.count && prices[days[next]] <= budget {
            marked.add(days[next], 1)                                         // this day is now affordable
            next += 1
        }
        answers[q] = marked.prefix(right + 1) - marked.prefix(left)
        print("budget \(budget): \(next) days marked, \(left)...\(right) has \(answers[q])")
    }
    return answers
}

let prices = [5, 2, 8, 6, 3, 9, 1, 7]
let queries = [(left: 0, right: 7, budget: 5), (left: 2, right: 5, budget: 6), (left: 1, right: 3, budget: 1), (left: 4, right: 7, budget: 8)]
print("answers:", cheapDays(prices: prices, queries: queries))
