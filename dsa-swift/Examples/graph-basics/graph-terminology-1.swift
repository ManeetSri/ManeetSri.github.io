// Generated from src/dsa/content/lessons/graph-basics/graph-terminology.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Undirected: each friendship touches two people
let friendships = [("Ana", "Ben"), ("Ana", "Cleo"), ("Ben", "Cleo"), ("Ben", "Dev"), ("Dev", "Eli")]
var degree: [String: Int] = [:]
for (a, b) in friendships {
    degree[a, default: 0] += 1
    degree[b, default: 0] += 1
}
for person in degree.keys.sorted() {
    print(person, degree[person]!)
}
print("sum of degrees:", degree.values.reduce(0, +), "edges:", friendships.count)

// Directed: each follow leaves one account and arrives at another
let follows = [("you", "swiftlang"), ("swiftlang", "apple"), ("swiftlang", "dana"), ("dana", "sam"), ("sam", "you")]
var inDegree: [String: Int] = [:]
var outDegree: [String: Int] = [:]
for (from, to) in follows {
    outDegree[from, default: 0] += 1
    inDegree[to, default: 0] += 1
}
for account in ["you", "swiftlang", "apple", "dana", "sam"] {
    print(account, "in:", inDegree[account, default: 0], "out:", outDegree[account, default: 0])
}
