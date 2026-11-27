// Generated from src/dsa/content/lessons/graph-traversals/gt-state-space.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A lock with four wheels of digits, starting at 0000. A move turns one wheel up or down by one.
/// The combination as four digits, with leading zeros
func code(_ state: Int) -> String {
    let digits = String(state)
    return String(repeating: "0", count: 4 - digits.count) + digits
}

/// The 8 combinations one move away. Each wheel is a place value: 1, 10, 100 or 1,000.
func neighbours(of state: Int) -> [Int] {
    var result: [Int] = []
    var place = 1
    for _ in 0..<4 {
        let digit = (state / place) % 10
        for change in [1, 9] {                          // up one, or down one (adding 9 wraps 0 to 9)
            let turned = (digit + change) % 10
            result.append(state + (turned - digit) * place)
        }
        place *= 10
    }
    return result
}

func fewestTurns(to target: String, blocked: [String]) -> Int {
    var forbidden = Array(repeating: false, count: 10_000)
    for combination in blocked {
        forbidden[Int(combination)!] = true
    }
    if forbidden[0] { return -1 }                       // stuck before the first move
    var turns = Array(repeating: -1, count: 10_000)     // -1: not seen yet
    turns[0] = 0
    var queue = [0]
    var head = 0
    let goal = Int(target)!
    while head < queue.count {
        let state = queue[head]
        head += 1
        if state == goal { return turns[state] }
        for next in neighbours(of: state) where turns[next] == -1 && !forbidden[next] {
            turns[next] = turns[state] + 1
            queue.append(next)
        }
    }
    return -1
}

print(neighbours(of: 0).map(code))
print(fewestTurns(to: "1234", blocked: []))
print(fewestTurns(to: "9999", blocked: []))
print(fewestTurns(to: "1111", blocked: ["1000", "0100", "0010", "0001"]))
print(fewestTurns(to: "5555", blocked: ["4555", "6555", "5455", "5655", "5545", "5565", "5554", "5556"]))
print(fewestTurns(to: "0000", blocked: []))
