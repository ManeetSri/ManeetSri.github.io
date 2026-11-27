// Generated from src/dsa/content/lessons/swift-closures/swift-loop-or-hof.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let temps = [3, 5, 6, 2, 4, 7, 9, 1]

// A loop: the state is plain variables
var longest = 1
var current = 1
for i in 1..<temps.count {
    if temps[i] > temps[i - 1] {
        current += 1
    } else {
        current = 1
    }
    longest = max(longest, current)
}
print(longest)

// reduce: the state has to be squeezed into a tuple
let result = temps.dropFirst().reduce((longest: 1, current: 1, previous: temps[0])) { state, t in
    let current = t > state.previous ? state.current + 1 : 1
    return (max(state.longest, current), current, t)
}
print(result.longest)
