// Generated from src/dsa/content/lessons/interview-playbook/int-swift-gotchas.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Player {
    let name: String
    let score: Int
}
let players = [Player(name: "Ana", score: 30), Player(name: "Bo", score: 25),
               Player(name: "Cy", score: 30), Player(name: "Di", score: 25)]
let byScore = players.sorted { $0.score > $1.score }          // stable: ties keep input order
print(byScore.map(\.name))
let reversedAscending = Array(players.sorted { $0.score < $1.score }.reversed())
print(reversedAscending.map(\.name))                          // reversing flips the ties too
let explicit = players.sorted { $0.score != $1.score ? $0.score > $1.score : $0.name < $1.name }
print(explicit.map(\.name))                                   // a tie-break states the order
