// Generated from src/dsa/content/lessons/dp-foundations/dp-reconstruct.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The cheapest climb (start on stair 0 or 1, climb 1 or 2, a toll on every stair you stand on),
/// and the stairs it stands on
func cheapestRoute(_ tolls: [Int]) -> (cost: Int, stairs: [Int]) {
    let n = tolls.count
    var reach = Array(repeating: 0, count: n + 1)   // reach[i]: the cheapest cost to arrive at position i
    var from = Array(repeating: -1, count: n + 1)   // from[i]: the stair that cheapest arrival came from
    for i in stride(from: 2, through: n, by: 1) {
        let oneUp = reach[i - 1] + tolls[i - 1]
        let twoUp = reach[i - 2] + tolls[i - 2]
        if oneUp <= twoUp {
            reach[i] = oneUp
            from[i] = i - 1
        } else {
            reach[i] = twoUp
            from[i] = i - 2
        }
    }
    // Follow the parent links from the landing back to a starting stair
    var stairs: [Int] = []
    var position = n
    while from[position] != -1 {
        position = from[position]
        stairs.append(position)
    }
    return (reach[n], stairs.reversed())
}

print(cheapestRoute([3, 8, 2, 9, 4, 1, 7]))
print(cheapestRoute([5, 1, 5, 1, 5]))
