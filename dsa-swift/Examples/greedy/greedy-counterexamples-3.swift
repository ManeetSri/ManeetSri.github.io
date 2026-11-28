// Generated from src/dsa/content/lessons/greedy/greedy-counterexamples.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let roads: [Character: [(to: Character, length: Int)]] = [
    "A": [("B", 10), ("C", 1)],
    "B": [("D", 1)],
    "C": [("D", 100)],
]

// Greedy: from each place, take the longest road out
var place: Character = "A"
var greedyRoute = "A"
var greedyLength = 0
while place != "D", let next = roads[place]?.max(by: { $0.length < $1.length }) {
    greedyLength += next.length
    place = next.to
    greedyRoute.append(next.to)
}

// Exhaustive: try every route
func longest(from place: Character) -> Int {
    if place == "D" { return 0 }
    return (roads[place] ?? []).map { $0.length + longest(from: $0.to) }.max() ?? Int.min
}
print("greedy \(greedyRoute) = \(greedyLength), longest = \(longest(from: "A"))")
