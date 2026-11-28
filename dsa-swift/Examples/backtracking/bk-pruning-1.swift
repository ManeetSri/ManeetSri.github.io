// Generated from src/dsa/content/lessons/backtracking/bk-pruning.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let weights = [12, 7, 11, 8, 9, 6, 5, 14, 3, 10, 4, 13, 2, 15, 9, 7, 6, 11, 8, 5]
let values  = [24, 13, 23, 15, 16, 11, 9, 28, 5, 19, 7, 25, 3, 30, 17, 12, 10, 21, 14, 8]
let capacity = 40

enum Bound { case none, allRemaining, fractional }

func bestValue(_ bound: Bound) -> (best: Int, nodes: Int) {
    // Most value per unit of weight first, so good answers turn up early
    let order = weights.indices.sorted { values[$0] * weights[$1] > values[$1] * weights[$0] }
    let n = order.count
    var remainingValue = Array(repeating: 0, count: n + 1)       // value of everything from position i on
    for i in stride(from: n - 1, through: 0, by: -1) {
        remainingValue[i] = remainingValue[i + 1] + values[order[i]]
    }

    // Fill `room` greedily from `position` on, with a fraction of the first item that doesn't fit
    func fractionalFill(_ position: Int, _ room: Int) -> Double {
        var room = room
        var total = 0.0
        for item in order[position...] {
            if weights[item] > room {
                return total + Double(values[item]) * Double(room) / Double(weights[item])
            }
            room -= weights[item]
            total += Double(values[item])
        }
        return total
    }

    var best = 0
    var nodes = 0
    func explore(_ position: Int, _ weight: Int, _ value: Int) {
        nodes += 1
        best = max(best, value)
        if position == n { return }
        switch bound {                                           // cut if even the bound can't beat best
        case .none:
            break
        case .allRemaining:
            if value + remainingValue[position] <= best { return }
        case .fractional:
            if Double(value) + fractionalFill(position, capacity - weight) <= Double(best) { return }
        }
        let item = order[position]
        if weight + weights[item] <= capacity {                  // feasibility: it must fit
            explore(position + 1, weight + weights[item], value + values[item])   // take it
        }
        explore(position + 1, weight, value)                     // leave it
    }

    explore(0, 0, 0)
    return (best, nodes)
}

print("no bound:            ", bestValue(.none))
print("all remaining values:", bestValue(.allRemaining))
print("fractional fill:     ", bestValue(.fractional))
