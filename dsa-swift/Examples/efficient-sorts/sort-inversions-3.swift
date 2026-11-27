// Generated from src/dsa/content/lessons/efficient-sorts/sort-inversions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Two people rank the same five films, 1 being their favourite
let films = ["Arrival", "Brave", "Coco", "Dune", "Elf"]
let ana = ["Coco", "Arrival", "Dune", "Brave", "Elf"]
let ben = ["Arrival", "Coco", "Brave", "Elf", "Dune"]

// Write Ben's list using Ana's positions: where does each of Ben's films sit in Ana's ranking?
var anaPosition: [String: Int] = [:]
for (position, film) in ana.enumerated() {
    anaPosition[film] = position
}
let relabelled = ben.map { anaPosition[$0]! }
print(relabelled)

var disagreements = 0
for i in relabelled.indices {
    for j in (i + 1)..<relabelled.count where relabelled[i] > relabelled[j] {
        disagreements += 1
    }
}
let pairs = films.count * (films.count - 1) / 2
print("They disagree on \(disagreements) of \(pairs) pairs")
