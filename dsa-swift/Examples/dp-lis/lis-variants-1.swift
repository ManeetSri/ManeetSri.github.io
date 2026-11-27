// Generated from src/dsa/content/lessons/dp-lis/lis-variants.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestBitonic(_ items: [Int]) -> Int {
    let n = items.count
    var rise = Array(repeating: 1, count: n)   // longest increasing run ending at i
    var fall = Array(repeating: 1, count: n)   // longest decreasing run starting at i
    for i in 0..<n {
        for j in 0..<i where items[j] < items[i] {
            rise[i] = max(rise[i], rise[j] + 1)
        }
    }
    for i in stride(from: n - 1, through: 0, by: -1) {
        for j in (i + 1)..<n where items[j] < items[i] {
            fall[i] = max(fall[i], fall[j] + 1)
        }
    }
    print("rise:", rise)
    print("fall:", fall)
    var best = 0
    for i in 0..<n {
        best = max(best, rise[i] + fall[i] - 1)   // the peak is in both halves
    }
    return best
}

print(longestBitonic([2, 7, 3, 9, 5, 6, 4, 1]))
print(longestBitonic([5, 4, 3, 2]))
