// Generated from src/dsa/content/lessons/graph-traversals/gt-bidirectional.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A lock with 6 wheels: 1,000,000 combinations, each with 12 neighbours
let wheels = 6
let stateCount = 1_000_000

func neighbours(of state: Int) -> [Int] {
    var result: [Int] = []
    var place = 1
    for _ in 0..<wheels {
        let digit = (state / place) % 10
        result.append(state + ((digit + 1) % 10 - digit) * place)
        result.append(state + ((digit + 9) % 10 - digit) * place)
        place *= 10
    }
    return result
}

/// Plain BFS: returns the number of moves and how many states it marked as seen
func bfs(from start: Int, to target: Int) -> (moves: Int, seen: Int) {
    var distance = Array(repeating: -1, count: stateCount)
    distance[start] = 0
    var queue = [start]
    var head = 0
    while head < queue.count {
        let state = queue[head]
        head += 1
        if state == target { return (distance[state], queue.count) }
        for next in neighbours(of: state) where distance[next] == -1 {
            distance[next] = distance[state] + 1
            queue.append(next)
        }
    }
    return (-1, queue.count)
}

/// Bidirectional BFS: grow whichever frontier is smaller by one whole level, until they touch
func bidirectional(from start: Int, to target: Int) -> (moves: Int, seen: Int) {
    if start == target { return (0, 1) }
    var side = Array(repeating: 0, count: stateCount)   // 0: unseen, 1: seen from start, 2: from target
    side[start] = 1
    side[target] = 2
    var frontiers = [[start], [target]]                // frontiers[0] grows from start, [1] from target
    var seen = 2
    var levels = 0                                      // levels expanded so far, on both sides
    while !frontiers[0].isEmpty && !frontiers[1].isEmpty {
        let grow = frontiers[0].count <= frontiers[1].count ? 0 : 1
        let mine = grow + 1
        var next: [Int] = []
        for state in frontiers[grow] {
            for neighbour in neighbours(of: state) {
                if side[neighbour] == 3 - mine { return (levels + 1, seen) }   // the searches meet
                if side[neighbour] == 0 {
                    side[neighbour] = mine
                    seen += 1
                    next.append(neighbour)
                }
            }
        }
        frontiers[grow] = next
        levels += 1
    }
    return (-1, seen)
}

for target in [33, 1_234, 123_321] {
    let plain = bfs(from: 0, to: target)
    let both = bidirectional(from: 0, to: target)
    let code = String(repeating: "0", count: wheels - String(target).count) + String(target)
    print("000000 to \(code): \(plain.moves) moves; BFS saw \(plain.seen) states, bidirectional \(both.seen)")
}
